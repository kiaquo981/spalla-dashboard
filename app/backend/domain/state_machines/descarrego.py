"""
DescarregoStateMachine — LF-FASE2 Story LF-2.7

Pipeline de captura → transcrição → classificação → ação.

Estados:
  capturado, transcricao_pendente, transcrito,
  classificacao_pendente, classificado,
  aguardando_humano, executando_acao_automatica,
  executando_acao_manual, finalizado, rejeitado, erro
"""
from .base import StateMachine


def _is_text_input(sm) -> bool:
    return sm.row.get("tipo_bruto") == "texto"


def _has_audio_or_video(sm) -> bool:
    return sm.row.get("tipo_bruto") in ("audio", "video", "gravacao")


def _high_confidence(sm) -> bool:
    conf = sm.row.get("classificacao_confidence") or 0
    return float(conf) >= 0.8


class DescarregoStateMachine(StateMachine):
    name = "Descarrego"
    table_name = "descarregos"
    state_field = "status"
    initial_state = "capturado"

    states = {
        "capturado", "transcricao_pendente", "transcrito",
        "classificacao_pendente", "classificado",
        "aguardando_humano",
        "executando_acao_automatica", "executando_acao_manual",
        "finalizado", "rejeitado", "erro",
    }

    transitions = {
        # Captura → próxima etapa depende do tipo
        ("capturado", "needs_transcription"): {
            "to": "transcricao_pendente",
            "guard": _has_audio_or_video,
        },
        ("capturado", "skip_transcription"): {
            "to": "transcrito",
            "guard": _is_text_input,
        },
        ("capturado", "fail"): {"to": "erro"},

        # Transcrição
        ("transcricao_pendente", "transcribed"): {"to": "transcrito"},
        ("transcricao_pendente", "fail"):        {"to": "erro"},

        # Pós-transcrição → classificação
        ("transcrito", "classify"): {"to": "classificacao_pendente"},
        ("transcrito", "fail"):     {"to": "erro"},

        # Classificação
        ("classificacao_pendente", "classified"): {"to": "classificado"},
        ("classificacao_pendente", "fail"):       {"to": "erro"},

        # Decisão pós-classificação
        ("classificado", "auto_execute"): {
            "to": "executando_acao_automatica",
            "guard": _high_confidence,
        },
        ("classificado", "request_human"): {"to": "aguardando_humano"},

        # HITL
        ("aguardando_humano", "human_approved"): {"to": "executando_acao_manual"},
        ("aguardando_humano", "human_rejected"): {"to": "rejeitado"},

        # Execução
        ("executando_acao_automatica", "action_done"):  {"to": "finalizado"},
        ("executando_acao_automatica", "action_failed"): {"to": "erro"},
        ("executando_acao_manual",     "action_done"):  {"to": "finalizado"},
        ("executando_acao_manual",     "action_failed"): {"to": "erro"},

        # Recovery
        ("erro", "retry"): {"to": "capturado"},
    }
