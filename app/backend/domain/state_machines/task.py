"""
TaskStateMachine — LF-FASE2 Story LF-2.3 + LF-2.10

8 estados:
  pendente | em_andamento | em_revisao | bloqueada | pausada
  concluida | cancelada | arquivada

Eventos:
  start, complete, block, unblock, pause, resume, cancel,
  archive, request_review, approve, changes_requested, reopen

Especie-aware guards (LF-2.10):
  - quest: complete só se todos children concluídos
  - any: start só se depends_on todos resolvidos
  - recorrente_template / triggered_template: não executam (são templates)
"""
from .base import StateMachine, GuardFailed


def _depends_on_resolved(sm) -> bool:
    """
    Guard: só permite start se depends_on estiver vazio OU se todos os
    referenciados estiverem em estado terminal (concluida/cancelada/arquivada).

    Em runtime real, o callsite é responsável por hidratar
    sm.row['_dependencies_resolved'] consultando o DB. Default = True
    se a flag não foi setada (mantém compatibilidade com tasks antigas).
    """
    deps = sm.row.get("depends_on") or []
    if not deps:
        return True
    return bool(sm.row.get("_dependencies_resolved", True))


def _quest_children_complete(sm) -> bool:
    """
    Guard: quest só conclui se todos os children estiverem em estado terminal.
    Callsite hidrata sm.row['_children_complete'] se for quest.
    """
    if sm.row.get("especie") != "quest":
        return True
    return bool(sm.row.get("_children_complete", True))


def _is_template(sm) -> bool:
    return sm.row.get("especie") in (
        "recorrente_template", "triggered_template"
    )


def _not_template(sm) -> bool:
    return not _is_template(sm)


class TaskStateMachine(StateMachine):
    name = "Task"
    table_name = "god_tasks"
    state_field = "status"
    initial_state = "pendente"

    states = {
        "pendente", "em_andamento", "em_revisao", "bloqueada",
        "pausada", "concluida", "cancelada", "arquivada",
    }

    transitions = {
        # pendente
        ("pendente", "start"):    {"to": "em_andamento",
                                    "guard": lambda sm: _not_template(sm) and _depends_on_resolved(sm)},
        ("pendente", "block"):    {"to": "bloqueada"},
        ("pendente", "cancel"):   {"to": "cancelada"},
        ("pendente", "complete"): {"to": "concluida",
                                    "guard": _quest_children_complete},

        # em_andamento
        ("em_andamento", "complete"):       {"to": "concluida",
                                              "guard": _quest_children_complete},
        ("em_andamento", "request_review"): {"to": "em_revisao"},
        ("em_andamento", "block"):          {"to": "bloqueada"},
        ("em_andamento", "pause"):          {"to": "pausada"},
        ("em_andamento", "cancel"):         {"to": "cancelada"},

        # em_revisao
        ("em_revisao", "approve"):           {"to": "concluida",
                                               "guard": _quest_children_complete},
        ("em_revisao", "changes_requested"): {"to": "em_andamento"},
        ("em_revisao", "cancel"):            {"to": "cancelada"},

        # bloqueada
        ("bloqueada", "unblock"): {"to": "em_andamento",
                                    "guard": _depends_on_resolved},
        ("bloqueada", "cancel"):  {"to": "cancelada"},

        # pausada
        ("pausada", "resume"): {"to": "em_andamento"},
        ("pausada", "cancel"): {"to": "cancelada"},

        # concluida
        ("concluida", "archive"):  {"to": "arquivada"},
        ("concluida", "reopen"):   {"to": "em_andamento"},

        # cancelada
        ("cancelada", "archive"):  {"to": "arquivada"},
        ("cancelada", "reopen"):   {"to": "pendente"},
    }


