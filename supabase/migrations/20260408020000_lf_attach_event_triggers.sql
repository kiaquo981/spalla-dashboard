-- ============================================================
-- LF-FASE1: Attach emit_entity_event triggers to 12 key tables
-- Story: LF-1.3
--
-- Captura passiva de eventos. Zero alteração nas tabelas.
-- Cada trigger passa o aggregate_type canônico via TG_ARGV.
--
-- Tabelas que não existem no schema do ambiente são puladas
-- via DO block + information_schema lookup (idempotente).
-- ============================================================

DO $$
DECLARE
  rec RECORD;
  triggers TEXT[][] := ARRAY[
    -- [schema, table, aggregate_type]
    ['public', 'god_tasks',           'Task'],
    ['public', 'god_task_subtasks',   'TaskSubtask'],
    ['public', 'god_task_comments',   'TaskComment'],
    ['case',   'mentorados',          'Mentorado'],
    ['public', 'mentorado_context',   'Contexto'],
    ['public', 'ds_producoes',        'DossieProducao'],
    ['public', 'ds_documentos',       'DossieDocumento'],
    ['public', 'ds_ajustes',          'DossieAjuste'],
    ['public', 'pa_planos',           'PlanoAcao'],
    ['public', 'pa_fases',            'PlanoAcaoFase'],
    ['public', 'pa_acoes',            'PlanoAcaoItem'],
    ['public', 'calls_mentoria',      'Call'],
    ['public', 'wa_topics',           'WhatsAppTopic'],
    ['public', 'god_reminders',       'Reminder'],
    ['public', 'god_feedback',        'FeedbackInbox']
  ];
  i INT;
  sch TEXT; tbl TEXT; agg TEXT;
  trg_name TEXT;
BEGIN
  FOR i IN 1 .. array_length(triggers, 1) LOOP
    sch := triggers[i][1];
    tbl := triggers[i][2];
    agg := triggers[i][3];
    trg_name := 'trg_lf_events_' || tbl;

    -- Só anexa se a tabela existir
    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = sch AND table_name = tbl
    ) THEN
      EXECUTE format(
        'DROP TRIGGER IF EXISTS %I ON %I.%I',
        trg_name, sch, tbl
      );
      EXECUTE format(
        'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON %I.%I
         FOR EACH ROW EXECUTE FUNCTION emit_entity_event(%L)',
        trg_name, sch, tbl, agg
      );
      RAISE NOTICE 'Attached % to %.%', trg_name, sch, tbl;
    ELSE
      RAISE NOTICE 'Skipping %.% (table does not exist)', sch, tbl;
    END IF;
  END LOOP;
END $$;
