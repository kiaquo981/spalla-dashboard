#!/usr/bin/env python3
"""
Spalla Pendencias Classifier
============================

Classifica pendências de WhatsApp da CASE usando Qwen 14B local (Mac mini via Tailscale).

Estados possíveis (status_pendencia):
  - aberta              → ainda precisa resposta
  - atendida            → conversa cobriu o tópico
  - compromisso_equipe  → equipe prometeu algo, não cumpriu
  - compromisso_mentee  → mentorado prometeu algo, não cumpriu
  - aviso               → comunicado/template, não pede resposta

Estratégia delta:
  - Pendências sem classificação OU stale (>1h E houve nova msg no grupo)
  - Cap de 30 por run (pra caber em 30min com Qwen 14B ~6s/call)
  - Fallback Haiku (OpenRouter) só se Qwen retornar confidence < 0.6

Uso:
  python3 classifier.py            # roda 1x
  python3 classifier.py --dry-run  # não salva no DB
  python3 classifier.py --limit N  # cap diferente
"""

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

# ---------- config ----------
ENV_PATH = Path(__file__).parent / ".env"
if ENV_PATH.exists():
    for line in ENV_PATH.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))

SB_URL = os.environ["SUPABASE_URL"]
SB_KEY = os.environ["SUPABASE_SERVICE_KEY"]
QWEN_URL = os.environ.get("QWEN_URL", "http://100.102.33.48:11434")
QWEN_MODEL = os.environ.get("QWEN_MODEL", "qwen2.5:14b-instruct-q4_K_M")
OR_KEY = os.environ.get("OPENROUTER_API_KEY", "")  # opcional, fallback

CONTEXT_BEFORE = 5     # mensagens anteriores
CONTEXT_AFTER = 10     # mensagens posteriores (mais importante: ver se foi atendida)
DEFAULT_LIMIT = 30
STALE_HOURS = 1        # reclassificar se >1h E houve nova msg no grupo
MAX_AGE_HOURS = 48     # só classifica pendências das últimas 48h (>48h vira "atendida" via cleanup)

VALID_STATUS = {"aberta", "atendida", "compromisso_equipe", "compromisso_mentee", "aviso"}


# ---------- supabase REST helpers ----------
def sb_get(path, params=None):
    """GET no PostgREST."""
    qs = urllib.parse.urlencode(params or {}, doseq=True)
    url = f"{SB_URL}/rest/v1/{path}" + (f"?{qs}" if qs else "")
    req = urllib.request.Request(url, headers={
        "apikey": SB_KEY,
        "Authorization": f"Bearer {SB_KEY}",
    })
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read())


def sb_patch(path, data, match):
    """PATCH no PostgREST. match = filtros tipo {'id': 'eq.123'}."""
    qs = urllib.parse.urlencode(match)
    url = f"{SB_URL}/rest/v1/{path}?{qs}"
    body = json.dumps(data).encode()
    req = urllib.request.Request(url, data=body, method="PATCH", headers={
        "apikey": SB_KEY,
        "Authorization": f"Bearer {SB_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    })
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.status


# ---------- LLM clients ----------
def call_qwen(prompt, system=None, timeout=60):
    """Chama Qwen no Mac mini. Retorna content string (espera JSON)."""
    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})

    body = json.dumps({
        "model": QWEN_MODEL,
        "messages": messages,
        "format": "json",
        "stream": False,
        "options": {"temperature": 0.1, "num_predict": 300},
    }).encode()

    req = urllib.request.Request(f"{QWEN_URL}/api/chat", data=body, headers={
        "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req, timeout=timeout) as r:
        d = json.loads(r.read())
    return d["message"]["content"], "qwen-14b"


def call_haiku(prompt, system=None, timeout=30):
    """Fallback OpenRouter Haiku. Retorna content string (espera JSON)."""
    if not OR_KEY:
        raise RuntimeError("OPENROUTER_API_KEY não setada")

    messages = []
    if system:
        messages.append({"role": "system", "content": system})
    messages.append({"role": "user", "content": prompt})

    body = json.dumps({
        "model": "anthropic/claude-haiku-4.5",
        "messages": messages,
        "temperature": 0.1,
        "max_tokens": 300,
        "response_format": {"type": "json_object"},
    }).encode()

    req = urllib.request.Request("https://openrouter.ai/api/v1/chat/completions", data=body, headers={
        "Authorization": f"Bearer {OR_KEY}",
        "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req, timeout=timeout) as r:
        d = json.loads(r.read())
    return d["choices"][0]["message"]["content"], "haiku-4.5"


# ---------- prompt ----------
SYSTEM_PROMPT = """Você é classificador semântico de pendências de WhatsApp de uma mentoria de negócios (CASE).

Cada análise recebe UMA mensagem alvo (que o sistema marcou como "precisa resposta") + contexto da conversa antes e depois. Você decide o estado real da pendência.

ESTADOS POSSÍVEIS:
- "aberta": a mensagem espera resposta e a outra parte ficou em silêncio total ou só falou de coisa não relacionada
- "atendida": a conversa fluiu sobre o tema, ou o autor original não voltou a cobrar — assunto naturalmente resolvido
- "compromisso_equipe": equipe prometeu algo CONCRETO (enviar dossiê, mandar link, fazer análise) e não há evidência de entrega
- "compromisso_mentee": mentorado prometeu algo CONCRETO (gravar conteúdo, postar, enviar dado) e não há evidência de cumprimento
- "aviso": comunicado puro/template (anúncio de aula, "bom dia pessoal", lembrete em massa) — não pede resposta

⚠️ REGRA CRÍTICA #1 — ENTREGA NÃO É COMPROMISSO:
Se a mensagem alvo JÁ ENTREGA o que se esperava, NUNCA marque como compromisso_equipe ou compromisso_mentee. Entrega fica "aberta" (aguardando feedback) ou "atendida".

Sinais de que a mensagem ALVO é ENTREGA (não promessa):
- Contém URL/link (docs.google.com, drive.google.com, youtube, tally, typeform, qualquer domínio)
- "segue", "segue o/a", "aqui está", "aqui vai", "olha só", "encaminhei", "mandei aí"
- Menção a arquivo/áudio/foto anexado ("áudio", "print", "foto", "pdf")
- Frase que apresenta algo ("esse é o", "este é o", "eis o")

Exemplo: "Oiee, bomm dia! Segue o seu dossiê ajustado: https://docs.google.com/..." → ENTREGA. Status: "aberta" (aguardando feedback do mentee) ou "atendida" se mentee já respondeu depois. NUNCA compromisso_equipe.

⚠️ REGRA CRÍTICA #2 — não seja literal:
A conversa de WhatsApp não é interrogatório. Se a mensagem alvo é uma PERGUNTA e a outra parte respondeu QUALQUER COISA relacionada ao tópico nas mensagens seguintes (mesmo que não seja a resposta exata), considere ATENDIDA.

Exemplos adicionais:
- Heitor: "quantos encontros combinou?" → Mentee: "Ele comprou hands-on de 20mil, 1 dia observer..." → ATENDIDA (conversa fluiu)
- Heitor: "manda o link do site" → Mentee: "claro, depois mando" → 2 dias sem link → COMPROMISSO_MENTEE
- Lara: "vou mandar o dossiê hoje" + SILÊNCIO 24h+ sem nenhuma mensagem da Lara com link → COMPROMISSO_EQUIPE
- Lara: "Segue o dossiê: [link]" → ABERTA (entregou, aguarda resposta do mentee) ou ATENDIDA (se mentee respondeu)
- Hugo: "Oieee, conseguimos puxar uma aula MUITO..." (sem pergunta direta) → AVISO
- Mentorado fez pergunta direta + sumiu 3+ dias + equipe não respondeu → ABERTA

REGRAS:
1. Lê CONTEXTO_DEPOIS por completo antes de decidir.
2. Se a outra parte escreveu QUALQUER mensagem relacionada ao tema → atendida.
3. Se autor voltou a falar de OUTRA coisa sem cobrar a resposta original → atendida (assunto morreu).
4. Compromisso = PROMESSA FUTURA ("vou mandar", "vou fazer") + NÃO há entrega nas próximas mensagens. Se a própria mensagem alvo já entrega (tem link/arquivo/"segue"), NÃO é compromisso.
5. Confidence: 0.9 se tem certeza, 0.7 se razoável, 0.5 se ambíguo.

OUTPUT obrigatório JSON:
{
  "status": "aberta|atendida|compromisso_equipe|compromisso_mentee|aviso",
  "motivo": "explicação curta (1 frase, max 120 char) do raciocínio",
  "confidence": 0.0-1.0
}"""


def build_prompt(target, before, after):
    def fmt(msg, marker=" "):
        autor = msg.get("autor_identificado") or ("EQUIPE" if msg.get("eh_equipe") else "MENTORADO")
        when = msg["created_at"][:16].replace("T", " ")
        return f"{marker} [{when}] {autor}: {msg['conteudo'][:300]}"

    parts = ["CONTEXTO ANTES (do mais antigo pro mais recente):"]
    parts += [fmt(m) for m in before] or ["  (nenhuma)"]
    parts.append("")
    parts.append(f"MENSAGEM ALVO (eh_equipe={target.get('eh_equipe')}, autor={target.get('autor_identificado','?')}):")
    parts.append(fmt(target, marker=">"))
    parts.append("")
    parts.append("CONTEXTO DEPOIS (do mais antigo pro mais recente):")
    parts += [fmt(m) for m in after] or ["  (nenhuma — mentorado/equipe não escreveram nada depois)"]
    parts.append("")
    parts.append("Classifique a MENSAGEM ALVO (linha com >).")
    return "\n".join(parts)


# ---------- core ----------
def fetch_pending(limit):
    """Busca pendências pra classificar: NULL nas últimas MAX_AGE_HOURS."""
    cutoff = (datetime.now(timezone.utc).timestamp() - MAX_AGE_HOURS * 3600)
    cutoff_iso = datetime.fromtimestamp(cutoff, tz=timezone.utc).isoformat(timespec="seconds")
    rows = sb_get("interacoes_mentoria", {
        "select": "id,mentorado_id,chat_id,conteudo,eh_equipe,autor_identificado,created_at",
        "requer_resposta": "eq.true",
        "respondido": "eq.false",
        "status_pendencia": "is.null",
        "created_at": f"gte.{cutoff_iso}",
        "order": "created_at.desc",
        "limit": str(limit),
    })
    return rows


def cleanup_old_pendencias():
    """Marca como 'atendida' tudo que ficou >MAX_AGE_HOURS sem classificação.
    Backlog antigo não tem como reforçar — vira ruído."""
    cutoff = (datetime.now(timezone.utc).timestamp() - MAX_AGE_HOURS * 3600)
    cutoff_iso = datetime.fromtimestamp(cutoff, tz=timezone.utc).isoformat(timespec="seconds")
    n = sb_patch_many("interacoes_mentoria", {
        "status_pendencia": "atendida",
        "motivo_classificador": f"limpeza_backlog_>{MAX_AGE_HOURS}h",
        "classificado_em": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "classificador_modelo": "backfill",
        "classificador_confidence": 1.0,
    }, {
        "requer_resposta": "eq.true",
        "respondido": "eq.false",
        "status_pendencia": "is.null",
        "created_at": f"lt.{cutoff_iso}",
    })
    return n


def cleanup_phantom_replied_unbounded():
    """Resolve pendências team→mentee onde a mentee respondeu DEPOIS no mesmo
    chat, SEM janela de 72h (a função SQL fix_phantom_pendencias tem janela).

    Cobre o caso: time pediu algo, mentee respondeu dias/semanas depois.
    Pendência fica órfã porque o trigger só pega janela 72h. Aqui resolvemos
    sem limite — se mentee respondeu em qualquer momento posterior, marca
    como atendida.
    """
    pending = sb_get("interacoes_mentoria", {
        "select": "id,chat_id,created_at",
        "requer_resposta": "eq.true",
        "respondido": "eq.false",
        "eh_equipe": "eq.true",
        "order": "created_at.desc",
        "limit": "500",
    })
    to_resolve = []
    for p in pending:
        chat_id = p.get("chat_id")
        if not chat_id:
            continue
        mentee_replies = sb_get("interacoes_mentoria", {
            "select": "id",
            "chat_id": f"eq.{chat_id}",
            "eh_equipe": "eq.false",
            "created_at": f"gt.{p['created_at']}",
            "limit": "1",
        })
        if mentee_replies:
            to_resolve.append(p["id"])

    if not to_resolve:
        return 0
    CHUNK = 50
    for i in range(0, len(to_resolve), CHUNK):
        ids = to_resolve[i:i+CHUNK]
        ids_filter = "(" + ",".join(str(x) for x in ids) + ")"
        sb_patch_many("interacoes_mentoria", {
            "respondido": True,
            "status_pendencia": "atendida",
            "motivo_classificador": "cleanup_unbounded_mentee_replied",
            "classificado_em": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            "classificador_modelo": "backfill_unbounded",
            "classificador_confidence": 1.0,
        }, {"id": f"in.{ids_filter}"})
    return len(to_resolve)


def sb_patch_many(path, data, match):
    """PATCH em batch via filtros. Retorna 0 se ok (Prefer=return=minimal)."""
    qs = urllib.parse.urlencode(match)
    url = f"{SB_URL}/rest/v1/{path}?{qs}"
    body = json.dumps(data).encode()
    req = urllib.request.Request(url, data=body, method="PATCH", headers={
        "apikey": SB_KEY,
        "Authorization": f"Bearer {SB_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal",
    })
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.status


def fetch_context(chat_id, target_created_at, target_id):
    """Pega contexto antes e depois da mensagem alvo no mesmo chat (grupo WhatsApp)."""
    if not chat_id:
        return [], []

    before = sb_get("interacoes_mentoria", {
        "select": "id,conteudo,eh_equipe,autor_identificado,created_at",
        "chat_id": f"eq.{chat_id}",
        "created_at": f"lt.{target_created_at}",
        "order": "created_at.desc",
        "limit": str(CONTEXT_BEFORE),
    })
    before = list(reversed(before))  # cronológico

    after = sb_get("interacoes_mentoria", {
        "select": "id,conteudo,eh_equipe,autor_identificado,created_at",
        "chat_id": f"eq.{chat_id}",
        "created_at": f"gt.{target_created_at}",
        "order": "created_at.asc",
        "limit": str(CONTEXT_AFTER),
    })
    return before, after


def classify(target, before, after):
    """Classifica via Qwen, fallback Haiku se confidence baixa."""
    prompt = build_prompt(target, before, after)

    try:
        content, model = call_qwen(prompt, system=SYSTEM_PROMPT, timeout=60)
        result = json.loads(content)
    except (urllib.error.URLError, json.JSONDecodeError, KeyError) as e:
        print(f"  [qwen ERR] {type(e).__name__}: {e}", file=sys.stderr)
        return None

    status = result.get("status")
    if status not in VALID_STATUS:
        print(f"  [qwen invalid status] {status!r} — pulando", file=sys.stderr)
        return None

    conf = float(result.get("confidence", 0.0))
    motivo = (result.get("motivo") or "")[:300]

    # Fallback Haiku se confidence baixa
    if conf < 0.6 and OR_KEY:
        try:
            content2, model2 = call_haiku(prompt, system=SYSTEM_PROMPT)
            result2 = json.loads(content2)
            if result2.get("status") in VALID_STATUS:
                status = result2["status"]
                motivo = (result2.get("motivo") or "")[:300]
                conf = float(result2.get("confidence", conf))
                model = f"haiku-4.5(after qwen conf={conf:.2f})"
        except Exception as e:
            print(f"  [haiku fallback ERR] {e}", file=sys.stderr)

    return {
        "status_pendencia": status,
        "motivo_classificador": motivo,
        "classificado_em": datetime.now(timezone.utc).isoformat(),
        "classificador_modelo": model,
        "classificador_confidence": round(conf, 2),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    started = time.time()
    print(f"[{datetime.now().isoformat(timespec='seconds')}] classifier start (limit={args.limit}, dry={args.dry_run})")

    if not args.dry_run:
        cleanup_old_pendencias()
        # Resolve pendências antigas onde mentee respondeu (sem janela 72h)
        n_resolved = cleanup_phantom_replied_unbounded()
        if n_resolved:
            print(f"  ✓ {n_resolved} pendências fantasma resolvidas (mentee respondeu depois)")

    pending = fetch_pending(args.limit)
    print(f"  → {len(pending)} pendências sem classificação (últimas {MAX_AGE_HOURS}h)")

    stats = {"ok": 0, "skip": 0, "err": 0, "by_status": {}}

    for i, target in enumerate(pending, 1):
        t0 = time.time()
        before, after = fetch_context(
            target.get("chat_id"),
            target["created_at"],
            target["id"],
        )
        result = classify(target, before, after)
        elapsed = time.time() - t0

        if result is None:
            stats["err"] += 1
            print(f"  [{i:>2}/{len(pending)}] id={target['id']} ERR ({elapsed:.1f}s)")
            continue

        status = result["status_pendencia"]
        stats["ok"] += 1
        stats["by_status"][status] = stats["by_status"].get(status, 0) + 1

        autor = target.get("autor_identificado") or ("EQUIPE" if target.get("eh_equipe") else "MENTORADO")
        preview = (target.get("conteudo") or "")[:60].replace("\n", " ")
        print(f"  [{i:>2}/{len(pending)}] id={target['id']} {autor:>8s} {status:>20s} c={result['classificador_confidence']:.2f} ({elapsed:.1f}s) | {preview}")

        if not args.dry_run:
            try:
                sb_patch("interacoes_mentoria", result, {"id": f"eq.{target['id']}"})
            except urllib.error.HTTPError as e:
                print(f"    [patch ERR] {e.code}: {e.read()[:200]}", file=sys.stderr)
                stats["err"] += 1

    total = time.time() - started
    print(f"[done {total:.1f}s] ok={stats['ok']} err={stats['err']} | by_status={stats['by_status']}")


if __name__ == "__main__":
    main()
