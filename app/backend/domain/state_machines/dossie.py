"""
Dossiê State Machines — LF-FASE2 Stories LF-2.5 + LF-2.6

DossieProducaoStateMachine: o pacote (1 produção = N documentos)
  iniciado → em_producao → em_revisao → aprovado → entregue → arquivado

DossieDocumentoStateMachine: cada documento individual.
  Trilha SCALE: oferta, posicionamento, funil (3 docs separados)
  Trilha CLINIC: integrado (1 doc com 4 pilares)
"""
from .base import StateMachine


class DossieProducaoStateMachine(StateMachine):
    name = "DossieProducao"
    table_name = "ds_producoes"
    state_field = "status"
    initial_state = "iniciado"

    states = {
        "iniciado", "em_producao", "em_revisao",
        "aprovado", "entregue", "arquivado",
    }

    transitions = {
        ("iniciado",    "start_production"): {"to": "em_producao"},
        ("em_producao", "request_review"):   {"to": "em_revisao"},
        ("em_revisao",  "approve"):          {"to": "aprovado"},
        ("em_revisao",  "changes_requested"): {"to": "em_producao"},
        ("aprovado",    "deliver"):          {"to": "entregue"},
        ("entregue",    "archive"):          {"to": "arquivado"},
        # Cancelamento de qualquer estado ativo
        ("iniciado",    "cancel"):  {"to": "arquivado"},
        ("em_producao", "cancel"):  {"to": "arquivado"},
        ("em_revisao",  "cancel"):  {"to": "arquivado"},
    }


class DossieDocumentoStateMachine(StateMachine):
    """
    Estados de UM documento dentro de uma produção de dossiê.

    Trilha SCALE:
      pendente → escrevendo → ag_qg → revisao_humana → aprovado → entregue

    Trilha CLINIC (integrado, 4 pilares):
      pendente → escrevendo → ag_qg_pilar1 → ag_qg_pilar2 →
      ag_qg_pilar3 → ag_qg_pilar4 → revisao_humana → aprovado → entregue

    O construtor recebe trilha e ajusta as transições.
    """
    name = "DossieDocumento"
    table_name = "ds_documentos"
    state_field = "status"
    initial_state = "pendente"

    SCALE_STATES = {
        "pendente", "escrevendo", "ag_qg",
        "revisao_humana", "aprovado", "entregue", "rejeitado",
    }

    CLINIC_STATES = {
        "pendente", "escrevendo",
        "ag_qg_pilar1", "ag_qg_pilar2", "ag_qg_pilar3", "ag_qg_pilar4",
        "revisao_humana", "aprovado", "entregue", "rejeitado",
    }

    SCALE_TRANSITIONS = {
        ("pendente",       "start_writing"):     {"to": "escrevendo"},
        ("escrevendo",     "submit_to_qg"):      {"to": "ag_qg"},
        ("ag_qg",          "qg_approved"):       {"to": "revisao_humana"},
        ("ag_qg",          "qg_rejected"):       {"to": "escrevendo"},
        ("revisao_humana", "human_approved"):    {"to": "aprovado"},
        ("revisao_humana", "changes_requested"): {"to": "escrevendo"},
        ("revisao_humana", "reject"):            {"to": "rejeitado"},
        ("aprovado",       "deliver"):           {"to": "entregue"},
        ("rejeitado",      "restart"):           {"to": "escrevendo"},
    }

    CLINIC_TRANSITIONS = {
        ("pendente",       "start_writing"):  {"to": "escrevendo"},
        ("escrevendo",     "submit_pilar1"):  {"to": "ag_qg_pilar1"},
        ("ag_qg_pilar1",   "approve_pilar1"): {"to": "ag_qg_pilar2"},
        ("ag_qg_pilar1",   "reject_pilar1"):  {"to": "escrevendo"},
        ("ag_qg_pilar2",   "approve_pilar2"): {"to": "ag_qg_pilar3"},
        ("ag_qg_pilar2",   "reject_pilar2"):  {"to": "escrevendo"},
        ("ag_qg_pilar3",   "approve_pilar3"): {"to": "ag_qg_pilar4"},
        ("ag_qg_pilar3",   "reject_pilar3"):  {"to": "escrevendo"},
        ("ag_qg_pilar4",   "approve_pilar4"): {"to": "revisao_humana"},
        ("ag_qg_pilar4",   "reject_pilar4"):  {"to": "escrevendo"},
        ("revisao_humana", "human_approved"): {"to": "aprovado"},
        ("revisao_humana", "changes_requested"): {"to": "escrevendo"},
        ("revisao_humana", "reject"):         {"to": "rejeitado"},
        ("aprovado",       "deliver"):        {"to": "entregue"},
        ("rejeitado",      "restart"):        {"to": "escrevendo"},
    }

    def __init__(self, row: dict, trilha: str = "scale"):
        super().__init__(row)
        self.trilha = (trilha or "scale").lower()
        if self.trilha == "clinic":
            self.states = self.CLINIC_STATES
            self.transitions = self.CLINIC_TRANSITIONS
        else:
            self.states = self.SCALE_STATES
            self.transitions = self.SCALE_TRANSITIONS
