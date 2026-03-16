-- ============================================================
-- Spalla Dashboard — WA Topics N8N Helper Functions
-- 2026-03-11
-- ============================================================

-- Expõe case.mentorados via função pública para o N8N consultar
-- N8N chama: POST /rest/v1/rpc/get_mentorado_by_group
CREATE OR REPLACE FUNCTION get_mentorado_by_group(p_group_jid TEXT)
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT jsonb_build_object('id', id, 'nome', nome)
  FROM "case".mentorados
  WHERE grupo_whatsapp_id = p_group_jid
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION get_mentorado_by_group(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION get_mentorado_by_group(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_mentorado_by_group(TEXT) TO service_role;

-- Marca mensagens da fila como processadas (batch update)
-- N8N chama: POST /rest/v1/rpc/mark_queue_done
CREATE OR REPLACE FUNCTION mark_queue_done(p_ids UUID[])
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE wa_message_queue
  SET status = 'done', processed_at = now()
  WHERE id = ANY(p_ids)
    AND status = 'processing';
$$;

GRANT EXECUTE ON FUNCTION mark_queue_done(UUID[]) TO service_role;
GRANT EXECUTE ON FUNCTION mark_queue_done(UUID[]) TO authenticated;

-- Busca batch de mensagens pendentes e marca como "processing" atomicamente
-- Evita race conditions entre múltiplas execuções do N8N
-- N8N chama: POST /rest/v1/rpc/fetch_and_lock_batch
CREATE OR REPLACE FUNCTION fetch_and_lock_batch(p_limit INT DEFAULT 10)
RETURNS SETOF wa_message_queue
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
    UPDATE wa_message_queue
    SET status = 'processing'
    WHERE id IN (
      SELECT id FROM wa_message_queue
      WHERE status = 'pending'
      ORDER BY created_at ASC
      LIMIT p_limit
      FOR UPDATE SKIP LOCKED
    )
    RETURNING *;
END;
$$;

GRANT EXECUTE ON FUNCTION fetch_and_lock_batch(INT) TO service_role;
GRANT EXECUTE ON FUNCTION fetch_and_lock_batch(INT) TO authenticated;

-- Atualiza contagem e summary de tópico de forma segura
CREATE OR REPLACE FUNCTION increment_topic_message_count(p_topic_id UUID, p_timestamp TIMESTAMPTZ)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE wa_topics
  SET
    message_count  = message_count + 1,
    last_message_at = p_timestamp,
    status          = CASE WHEN status = 'open' THEN 'active' ELSE status END,
    updated_at      = now()
  WHERE id = p_topic_id;
$$;

GRANT EXECUTE ON FUNCTION increment_topic_message_count(UUID, TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION increment_topic_message_count(UUID, TIMESTAMPTZ) TO authenticated;
