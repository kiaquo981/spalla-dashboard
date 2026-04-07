"""
FSM unit tests — LF-FASE2 Story LF-2.9
Run: python -m app.backend.domain.state_machines.test_fsm
Or:  cd app/backend && python -m domain.state_machines.test_fsm
"""
import sys

try:
    from . import (
        TaskStateMachine, MentoradoStateMachine,
        DossieProducaoStateMachine, DossieDocumentoStateMachine,
        DescarregoStateMachine, IllegalTransition, GuardFailed,
    )
except ImportError:
    from app.backend.domain.state_machines import (
        TaskStateMachine, MentoradoStateMachine,
        DossieProducaoStateMachine, DossieDocumentoStateMachine,
        DescarregoStateMachine, IllegalTransition, GuardFailed,
    )


passed = 0
failed = 0


def assert_eq(actual, expected, label):
    global passed, failed
    if actual == expected:
        passed += 1
        print(f"  ✓ {label}")
    else:
        failed += 1
        print(f"  ✗ {label}: expected {expected!r}, got {actual!r}")


def assert_raises(fn, exc, label):
    global passed, failed
    try:
        fn()
        failed += 1
        print(f"  ✗ {label}: expected {exc.__name__}, no exception raised")
    except exc:
        passed += 1
        print(f"  ✓ {label}")
    except Exception as e:
        failed += 1
        print(f"  ✗ {label}: expected {exc.__name__}, got {type(e).__name__}: {e}")


# ============================================================
# TaskStateMachine
# ============================================================
print("\n=== TaskStateMachine ===")
sm = TaskStateMachine({"id": "t1", "status": "pendente"})
assert_eq(sm.current_state, "pendente", "initial state")
assert_eq(set(sm.allowed_events()), {"start", "block", "cancel", "complete"}, "allowed from pendente")

sm.transition("start", persist=False)
assert_eq(sm.current_state, "em_andamento", "pendente → em_andamento via start")

sm.transition("request_review", persist=False)
assert_eq(sm.current_state, "em_revisao", "em_andamento → em_revisao")

sm.transition("approve", persist=False)
assert_eq(sm.current_state, "concluida", "em_revisao → concluida via approve")

sm.transition("archive", persist=False)
assert_eq(sm.current_state, "arquivada", "concluida → arquivada")

# Illegal: arquivada → start
sm2 = TaskStateMachine({"id": "t2", "status": "arquivada"})
assert_raises(lambda: sm2.transition("start", persist=False),
              IllegalTransition, "illegal: arquivada → start blocked")

# Block / unblock cycle
sm3 = TaskStateMachine({"id": "t3", "status": "em_andamento"})
sm3.transition("block", persist=False)
assert_eq(sm3.current_state, "bloqueada", "block")
sm3.transition("unblock", persist=False)
assert_eq(sm3.current_state, "em_andamento", "unblock")

# LF-2.10: especie-aware guards
print("\n=== TaskStateMachine — espécie guards ===")

# Template não pode dar start
sm_tpl = TaskStateMachine({"id": "tpl", "status": "pendente",
                            "especie": "recorrente_template"})
assert_raises(lambda: sm_tpl.transition("start", persist=False),
              GuardFailed, "template blocks start")

# Task com depends_on não-resolvido bloqueia start
sm_dep = TaskStateMachine({"id": "td", "status": "pendente",
                            "especie": "one_time",
                            "depends_on": ["other-uuid"],
                            "_dependencies_resolved": False})
assert_raises(lambda: sm_dep.transition("start", persist=False),
              GuardFailed, "unresolved deps block start")

# Mesma task com flag resolved=True permite start
sm_dep2 = TaskStateMachine({"id": "td2", "status": "pendente",
                             "especie": "one_time",
                             "depends_on": ["other-uuid"],
                             "_dependencies_resolved": True})
sm_dep2.transition("start", persist=False)
assert_eq(sm_dep2.current_state, "em_andamento", "resolved deps allow start")

# Quest com children pendentes não pode complete
sm_q = TaskStateMachine({"id": "q1", "status": "em_andamento",
                          "especie": "quest",
                          "_children_complete": False})
assert_raises(lambda: sm_q.transition("complete", persist=False),
              GuardFailed, "quest with open children blocks complete")

# Quest com children completos pode complete
sm_q2 = TaskStateMachine({"id": "q2", "status": "em_andamento",
                           "especie": "quest",
                           "_children_complete": True})
sm_q2.transition("complete", persist=False)
assert_eq(sm_q2.current_state, "concluida", "quest with all children done completes")

# ============================================================
# MentoradoStateMachine
# ============================================================
print("\n=== MentoradoStateMachine ===")
m = MentoradoStateMachine({"id": "1", "fase_jornada": "lead"})
assert_eq(m.current_state, "lead", "initial fase=lead")

m.transition("contract_signed", persist=False)
assert_eq(m.current_state, "onboarding", "lead → onboarding")

m.transition("kickoff_done", persist=False)
m.transition("strategy_validated", persist=False)
m.transition("hypothesis_validated", persist=False)
m.transition("ready_to_scale", persist=False)
m.transition("cycle_complete", persist=False)
assert_eq(m.current_state, "concluido", "full happy path → concluido")

m.transition("renew", persist=False)
assert_eq(m.current_state, "onboarding", "renew restart")

assert_raises(lambda: MentoradoStateMachine({"id":"x","fase_jornada":"lead"})
              .transition("ready_to_scale", persist=False),
              IllegalTransition, "illegal: lead → ready_to_scale blocked")

# ============================================================
# DossieProducaoStateMachine
# ============================================================
print("\n=== DossieProducaoStateMachine ===")
dp = DossieProducaoStateMachine({"id": "p1", "status": "iniciado"})
dp.transition("start_production", persist=False)
dp.transition("request_review", persist=False)
dp.transition("changes_requested", persist=False)
assert_eq(dp.current_state, "em_producao", "review→changes loop back")
dp.transition("request_review", persist=False)
dp.transition("approve", persist=False)
dp.transition("deliver", persist=False)
assert_eq(dp.current_state, "entregue", "happy path entregue")

# ============================================================
# DossieDocumentoStateMachine — SCALE vs CLINIC
# ============================================================
print("\n=== DossieDocumentoStateMachine SCALE ===")
ds_scale = DossieDocumentoStateMachine({"id": "d1", "status": "pendente"}, trilha="scale")
ds_scale.transition("start_writing", persist=False)
ds_scale.transition("submit_to_qg", persist=False)
ds_scale.transition("qg_approved", persist=False)
ds_scale.transition("human_approved", persist=False)
ds_scale.transition("deliver", persist=False)
assert_eq(ds_scale.current_state, "entregue", "SCALE happy path")

print("\n=== DossieDocumentoStateMachine CLINIC ===")
ds_clinic = DossieDocumentoStateMachine({"id": "d2", "status": "pendente"}, trilha="clinic")
ds_clinic.transition("start_writing", persist=False)
ds_clinic.transition("submit_pilar1", persist=False)
ds_clinic.transition("approve_pilar1", persist=False)
assert_eq(ds_clinic.current_state, "ag_qg_pilar2", "clinic moves to pilar2")
ds_clinic.transition("approve_pilar2", persist=False)
ds_clinic.transition("approve_pilar3", persist=False)
ds_clinic.transition("approve_pilar4", persist=False)
assert_eq(ds_clinic.current_state, "revisao_humana", "all 4 pilares done")
ds_clinic.transition("human_approved", persist=False)
ds_clinic.transition("deliver", persist=False)
assert_eq(ds_clinic.current_state, "entregue", "CLINIC happy path")

# Trilha isolation
assert_raises(lambda: ds_scale.transition("submit_pilar1", persist=False),
              IllegalTransition, "SCALE rejects CLINIC events")

# ============================================================
# DescarregoStateMachine — guards
# ============================================================
print("\n=== DescarregoStateMachine ===")
# Texto pula transcrição
d_text = DescarregoStateMachine({
    "id": "x1", "status": "capturado", "tipo_bruto": "texto"
})
d_text.transition("skip_transcription", persist=False)
assert_eq(d_text.current_state, "transcrito", "texto → skip → transcrito")

# Áudio precisa transcrição
d_audio = DescarregoStateMachine({
    "id": "x2", "status": "capturado", "tipo_bruto": "audio"
})
d_audio.transition("needs_transcription", persist=False)
assert_eq(d_audio.current_state, "transcricao_pendente", "audio → transcricao_pendente")

# Guard: texto NÃO pode chamar needs_transcription
assert_raises(lambda: DescarregoStateMachine({"id":"x3","status":"capturado","tipo_bruto":"texto"})
              .transition("needs_transcription", persist=False),
              GuardFailed, "guard blocks texto from transcription")

# High confidence → auto execute
d_auto = DescarregoStateMachine({
    "id": "x4", "status": "classificado", "tipo_bruto": "audio",
    "classificacao_confidence": 0.95
})
d_auto.transition("auto_execute", persist=False)
assert_eq(d_auto.current_state, "executando_acao_automatica", "high confidence auto-exec")

# Low confidence → guard fails for auto, request_human ok
d_low = DescarregoStateMachine({
    "id": "x5", "status": "classificado", "tipo_bruto": "audio",
    "classificacao_confidence": 0.5
})
assert_raises(lambda: d_low.transition("auto_execute", persist=False),
              GuardFailed, "low confidence blocks auto_execute")
d_low.transition("request_human", persist=False)
assert_eq(d_low.current_state, "aguardando_humano", "low confidence → human")

# HITL approve
d_low.transition("human_approved", persist=False)
d_low.transition("action_done", persist=False)
assert_eq(d_low.current_state, "finalizado", "HITL happy path")

# ============================================================
print(f"\n{'=' * 50}")
print(f"Results: {passed} passed, {failed} failed")
print(f"{'=' * 50}")
sys.exit(0 if failed == 0 else 1)
