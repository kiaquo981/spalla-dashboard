"""
GPT-4o Classifier — LF-FASE3 Story LF-3.5

Recebe texto (transcrição de áudio ou texto direto) e classifica em:
  task | contexto | feedback | reembolso | bloqueio | duvida | celebracao | outro

Retorna JSON estruturado com campos extras se for task.
"""
import json
import os
import urllib.request
import urllib.error


CLASSIFIER_PROMPT = """Você é um classificador de "descarregos" de mentoria de marketing/vendas.

Recebe um input de um consultor sênior (Kaique ou time) e classifica o que ele quer fazer com aquilo.

Tipos válidos:
- task: ação concreta a ser tomada (criar, fazer, enviar, executar, gravar, escrever)
- lembrete: algo a lembrar/cobrar em data futura (follow-up, cobrança, deadline)
- contexto: informação a guardar sobre o mentorado (sobre o negócio, situação, histórico)
- feedback: opinião do mentorado sobre algo (positivo ou negativo)
- reembolso: solicitação ou menção de reembolso/cancelamento de contrato
- bloqueio: mentorado está travado/parado em algo, precisa destrave
- escalacao: precisa envolver Kaique diretamente (decisão importante, conflito, caso especial)
- plano_acao: item de plano de ação do mentorado (meta, entregável, milestone)
- dossie: informação relevante para produção de dossiê (dados de oferta, posicionamento, funil)
- duvida: pergunta a responder
- celebracao: vitória, conquista, marco atingido
- outro: nada acima

Responsáveis válidos: kaique, mariza, queila, gobbi, hugo, jordana

Retorne APENAS JSON válido, sem markdown:
{
  "primary_type": "task",
  "subtype": "dossie|conteudo|reuniao|envio|operacional|follow_up|cobranca|...",
  "confidence": 0.0,
  "summary": "1-2 frases resumindo",
  "urgencia": "normal|alta|critica",
  "task": {
    "titulo": "verbo + objeto curto",
    "descricao": "contexto adicional",
    "responsavel": "kaique",
    "prazo_dias": 0,
    "prioridade": "normal"
  },
  "lembrete": {
    "titulo": "o que lembrar",
    "prazo_dias": 3,
    "responsavel": "kaique"
  },
  "dossie_ref": {
    "tipo_dossie": "oferta|posicionamento|funil",
    "secao": "seção do dossiê afetada"
  },
  "alertas": []
}

Inclua apenas os campos relevantes ao tipo (task, lembrete, dossie_ref).
Se primary_type = escalacao, sempre inclua "urgencia" e "alertas" com motivo.
Confidence baixa (<0.7) para inputs ambíguos. Alta (>=0.85) só pra coisas claras.
"""


def classify_descarrego(
    text: str,
    mentorado_context: dict | None = None,
    recent_interactions: list | None = None,
    previous_classifications: list | None = None,
) -> dict:
    """
    Chama GPT-4o-mini com o texto + contexto enriquecido do mentorado.
    Retorna o dict parseado, ou levanta exceção em falha grave.

    Args:
        text: texto bruto ou transcrição
        mentorado_context: dados do mentorado (nome, fase, trilha, etc)
        recent_interactions: últimas 5 interações (resumos de calls/WA)
        previous_classifications: últimos 5 descarregos classificados (feedback loop)
    """
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY não configurada")

    if not text or not text.strip():
        return {
            "primary_type": "outro",
            "confidence": 0.0,
            "summary": "(input vazio)",
            "alertas": ["empty_input"],
        }

    user_msg = f"INPUT DO CONSULTOR:\n{text.strip()}"
    if mentorado_context:
        user_msg += f"\n\nCONTEXTO DO MENTORADO:\n{json.dumps(mentorado_context, ensure_ascii=False)[:1500]}"
    if recent_interactions:
        interactions_text = "\n".join(
            f"- [{i.get('tipo', '?')}] {i.get('resumo', '')[:200]}"
            for i in recent_interactions[:5]
        )
        user_msg += f"\n\nÚLTIMAS INTERAÇÕES:\n{interactions_text}"
    if previous_classifications:
        prev_text = "\n".join(
            f"- {c.get('primary_type', '?')} ({c.get('confidence', 0):.0%}): {c.get('summary', '')[:100]}"
            for c in previous_classifications[:5]
        )
        user_msg += f"\n\nCLASSIFICAÇÕES ANTERIORES (pra contexto):\n{prev_text}"

    payload = {
        "model": "gpt-4o-mini",
        "messages": [
            {"role": "system", "content": CLASSIFIER_PROMPT},
            {"role": "user", "content": user_msg},
        ],
        "temperature": 0.2,
        "response_format": {"type": "json_object"},
    }

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="ignore")
        raise RuntimeError(f"OpenAI HTTP {e.code}: {body[:300]}")
    except Exception as e:
        raise RuntimeError(f"OpenAI request failed: {e}")

    try:
        content = data["choices"][0]["message"]["content"]
        parsed = json.loads(content)
    except (KeyError, json.JSONDecodeError) as e:
        raise RuntimeError(f"OpenAI returned invalid JSON: {e}")

    # Normaliza campos esperados
    parsed.setdefault("primary_type", "outro")
    parsed.setdefault("confidence", 0.0)
    parsed.setdefault("summary", "")
    parsed.setdefault("alertas", [])

    return parsed
