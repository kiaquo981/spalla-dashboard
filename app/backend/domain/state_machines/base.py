"""
Base StateMachine — LF-FASE2 Story LF-2.2

Lightweight FSM com guards, hooks e emissão de eventos via entity_events.
Sem dependências externas (puro stdlib + supabase client opcional via setter).

Modelo:
  - states: set[str]
  - initial_state: str
  - transitions: dict[(state, event)] -> {to, guard?, on_enter?, on_exit?}

Uso:
    sm = TaskStateMachine(task_row)
    sm.set_db(supabase_client)  # opcional
    sm.transition('start', actor='user', correlation_id=uuid)
"""
from __future__ import annotations

import uuid
import json
from datetime import datetime, timezone
from typing import Any, Callable, Optional


class IllegalTransition(Exception):
    """Tentativa de evento inválido para o estado atual."""
    pass


class GuardFailed(Exception):
    """Guard impediu a transição."""
    pass


class StateMachine:
    name: str = "Aggregate"
    initial_state: str = "created"
    states: set[str] = set()
    transitions: dict[tuple[str, str], dict[str, Any]] = {}
    state_field: str = "status"  # nome da coluna no DB
    table_name: str = ""
    table_schema: str = "public"
    pk_field: str = "id"

    def __init__(self, row: dict):
        self.row = dict(row or {})
        self._db = None  # supabase client (setter)

    # ------------------------------------------------------------
    # Setup
    # ------------------------------------------------------------
    def set_db(self, supabase_client):
        self._db = supabase_client
        return self

    @property
    def current_state(self) -> str:
        return self.row.get(self.state_field) or self.initial_state

    @property
    def aggregate_id(self) -> str:
        return str(self.row.get(self.pk_field, ""))

    # ------------------------------------------------------------
    # Core
    # ------------------------------------------------------------
    def can(self, event: str) -> bool:
        return (self.current_state, event) in self.transitions

    def allowed_events(self) -> list[str]:
        return [e for (s, e) in self.transitions.keys() if s == self.current_state]

    def transition(
        self,
        event: str,
        actor: Optional[str] = None,
        correlation_id: Optional[str] = None,
        causation_id: Optional[str] = None,
        payload: Optional[dict] = None,
        persist: bool = True,
    ) -> dict:
        """Executa transição. Retorna o novo state ou levanta exceção."""
        from_state = self.current_state
        key = (from_state, event)

        if key not in self.transitions:
            raise IllegalTransition(
                f"{self.name}: event '{event}' not allowed from state '{from_state}'. "
                f"Allowed: {self.allowed_events()}"
            )

        spec = self.transitions[key]
        to_state = spec["to"]

        # Guard
        guard: Optional[Callable] = spec.get("guard")
        if guard and not guard(self):
            raise GuardFailed(
                f"{self.name}: guard failed for {from_state} --[{event}]--> {to_state}"
            )

        # on_exit (do estado antigo)
        on_exit: Optional[Callable] = spec.get("on_exit")
        if on_exit:
            on_exit(self)

        # Atualiza estado in-memory
        self.row[self.state_field] = to_state
        self.row["updated_at"] = datetime.now(timezone.utc).isoformat()

        # on_enter (do estado novo)
        on_enter: Optional[Callable] = spec.get("on_enter")
        if on_enter:
            on_enter(self)

        # Persiste no DB (se cliente disponível)
        if persist and self._db is not None:
            self._persist()

        # Emite evento explícito (além do que o trigger captura)
        # Apenas se persistido e DB disponível — evita duplicação em testes
        if persist and self._db is not None:
            self._emit_event(
                event_type=f"{self.name}{event[0].upper() + event[1:]}",
                payload={
                    "from": from_state,
                    "to": to_state,
                    "event": event,
                    **(payload or {}),
                },
                actor=actor,
                correlation_id=correlation_id,
                causation_id=causation_id,
            )

        return {"from": from_state, "to": to_state, "event": event}

    # ------------------------------------------------------------
    # DB integration (override se quiser)
    # ------------------------------------------------------------
    def _persist(self):
        if not self._db or not self.table_name:
            return
        update_data = {
            self.state_field: self.current_state,
            "updated_at": self.row["updated_at"],
        }
        try:
            (
                self._db.table(self.table_name)
                .update(update_data)
                .eq(self.pk_field, self.aggregate_id)
                .execute()
            )
        except Exception as e:
            print(f"[FSM] persist failed for {self.name}#{self.aggregate_id}: {e}")
            raise

    def _emit_event(
        self,
        event_type: str,
        payload: dict,
        actor: Optional[str] = None,
        correlation_id: Optional[str] = None,
        causation_id: Optional[str] = None,
    ):
        if not self._db:
            return
        try:
            self._db.table("entity_events").insert(
                {
                    "aggregate_type": self.name,
                    "aggregate_id": self.aggregate_id,
                    "event_type": event_type,
                    "payload": payload,
                    "metadata": {
                        "source": "fsm",
                        "actor": actor or "system",
                        "table": self.table_name,
                    },
                    "correlation_id": correlation_id,
                    "causation_id": causation_id,
                }
            ).execute()
        except Exception as e:
            # Nunca derruba a transição
            print(f"[FSM] emit_event failed: {e}")

    # ------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------
    @classmethod
    def new_correlation_id(cls) -> str:
        return str(uuid.uuid4())

    def to_dict(self) -> dict:
        return {
            "aggregate_type": self.name,
            "aggregate_id": self.aggregate_id,
            "current_state": self.current_state,
            "allowed_events": self.allowed_events(),
        }
