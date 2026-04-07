"""
MentoradoStateMachine — LF-FASE2 Story LF-2.4

Lifecycle do mentorado: lead → onboarding → ... → concluido / encerrado.
state_field = 'fase_jornada' (não é 'status').

Estados canônicos (UBIQUITOUS-LANGUAGE.md):
  lead, onboarding, concepcao, validacao, otimizacao,
  escala, concluido, encerrado
"""
from .base import StateMachine


class MentoradoStateMachine(StateMachine):
    name = "Mentorado"
    table_name = "mentorados"
    table_schema = "case"
    state_field = "fase_jornada"
    initial_state = "lead"

    states = {
        "lead", "onboarding", "concepcao", "validacao",
        "otimizacao", "escala", "concluido", "encerrado",
    }

    transitions = {
        # lead → contrato assinado
        ("lead", "contract_signed"): {"to": "onboarding"},
        ("lead", "lost"):            {"to": "encerrado"},

        # onboarding (D+0 a D+30)
        ("onboarding", "kickoff_done"): {"to": "concepcao"},
        ("onboarding", "cancel"):       {"to": "encerrado"},

        # concepcao (estratégia + primeiro dossiê)
        ("concepcao", "strategy_validated"): {"to": "validacao"},
        ("concepcao", "cancel"):             {"to": "encerrado"},

        # validacao (testando hipóteses)
        ("validacao", "hypothesis_validated"): {"to": "otimizacao"},
        ("validacao", "cancel"):                {"to": "encerrado"},

        # otimizacao
        ("otimizacao", "ready_to_scale"): {"to": "escala"},
        ("otimizacao", "cancel"):          {"to": "encerrado"},

        # escala
        ("escala", "cycle_complete"): {"to": "concluido"},
        ("escala", "cancel"):          {"to": "encerrado"},

        # concluido (terminal — pode renovar)
        ("concluido", "renew"): {"to": "onboarding"},

        # encerrado é terminal-terminal (apenas reativação manual fora do FSM)
    }
