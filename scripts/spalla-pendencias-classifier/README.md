# Spalla Pendências Classifier

Worker local que rota a cada 30min via `launchd` no Mac do Kaique, classificando pendências de WhatsApp da CASE usando Qwen 14B local (Mac mini via Tailscale).

## Localização real (ativa)

```
~/code/spalla-pendencias-classifier/
├── classifier.py
├── run.sh
└── .env  (NÃO commitado — tem SUPABASE_SERVICE_KEY)
```

Esta pasta em `scripts/` é **espelho versionado** do código pra fonte de verdade ficar no repo. Mudanças vivem aqui mas precisam ser copiadas pra cópia ativa.

## Sync

```bash
# Após editar aqui, sync pra cópia ativa:
cp scripts/spalla-pendencias-classifier/classifier.py ~/code/spalla-pendencias-classifier/classifier.py
cp scripts/spalla-pendencias-classifier/run.sh        ~/code/spalla-pendencias-classifier/run.sh
```

## Launchd plist

Vive em `~/Library/LaunchAgents/com.kaique.spalla-pendencias-classifier.plist`. StartInterval 1800s (30min).

```bash
# Status
launchctl list | grep spalla-pendencias

# Logs (rotação diária)
ls ~/Library/Logs/spalla-pendencias-classifier/
tail -f ~/Library/Logs/spalla-pendencias-classifier/$(date +%Y-%m-%d).log

# Disparo manual
~/code/spalla-pendencias-classifier/run.sh
```

## O que faz

1. **`cleanup_old_pendencias()`** — pendências sem classificação há >48h viram `atendida` (backlog antigo não tem como reforçar).
2. **`cleanup_phantom_replied_unbounded()`** ⭐ NOVO — pendências team→mentee onde a mentee respondeu em qualquer momento posterior são marcadas como `atendida`. Sem janela de 72h. Resolve o caso "mentee respondeu 8 dias depois mas a pendência ficou crítica no painel" (visto 2026-05-05).
3. **`fetch_pending()`** + classificação Qwen — pendências novas (últimas 48h) são classificadas em `aberta` / `atendida` / `compromisso_equipe` / `compromisso_mentee` / `aviso`.
4. Fallback Haiku via OpenRouter se Qwen confidence <0.6.

## Fonte de verdade SQL

A função `fix_phantom_pendencias_unbounded()` espelha o `cleanup_phantom_replied_unbounded()` no Supabase (migration 79). Ambos podem ser chamados; o classifier Python usa o REST API direto (mais robusto sem dependência de RPC).

## Migration history

- 41 — auto_mark_responded() trigger original (resposta team→team)
- 56 — fix v2: janela 72h
- 78 — trigger gêmeo auto_mark_responded_by_mentee + fix_phantom_pendencias() (janela 72h)
- 79 — fix_phantom_pendencias_unbounded() (sem janela)
