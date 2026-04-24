"""Domain State Machines — LF-FASE2."""
from .base import StateMachine, IllegalTransition, GuardFailed
from .task import TaskStateMachine
from .mentorado import MentoradoStateMachine
from .dossie import DossieProducaoStateMachine, DossieDocumentoStateMachine
from .descarrego import DescarregoStateMachine

__all__ = [
    "StateMachine",
    "IllegalTransition",
    "GuardFailed",
    "TaskStateMachine",
    "MentoradoStateMachine",
    "DossieProducaoStateMachine",
    "DossieDocumentoStateMachine",
    "DescarregoStateMachine",
]


REGISTRY = {
    "Task": TaskStateMachine,
    "Mentorado": MentoradoStateMachine,
    "DossieProducao": DossieProducaoStateMachine,
    "DossieDocumento": DossieDocumentoStateMachine,
    "Descarrego": DescarregoStateMachine,
}


def get_state_machine(aggregate_type: str, row: dict, **kwargs):
    cls = REGISTRY.get(aggregate_type)
    if not cls:
        raise ValueError(f"No state machine registered for '{aggregate_type}'")
    return cls(row, **kwargs) if kwargs else cls(row)
