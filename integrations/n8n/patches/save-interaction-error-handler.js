/**
 * ERROR HANDLER: Salvar Interação → Dead Letter Queue
 * 
 * Onde aplicar no N8N: Error branch do node "Salvar Interação" (Supabase INSERT).
 * 
 * Quando o INSERT no Supabase falha, em vez de perder a mensagem,
 * salva na dead letter queue para reprocessamento posterior.
 */

const items = $input.all();
const results = [];

for (const item of items) {
  const error = item.json;
  
  // Tentar recuperar o payload original
  let rawPayload;
  try {
    rawPayload = $('Normalizar Webhook').first().json;
  } catch (e) {
    rawPayload = error;
  }

  results.push({
    json: {
      message_id: rawPayload.message_id || null,
      raw_payload: JSON.stringify(rawPayload),
      error_message: error.message || error.error || JSON.stringify(error).substring(0, 500),
      error_node: 'Salvar Interação',
      pipeline_stage: 'save',
      retry_count: 0,
      status: 'pending'
    }
  });
}

return results;

/**
 * NOTA: Conectar a saída deste node a um Postgres node com:
 * 
 * INSERT INTO wa_dead_letter_queue (message_id, raw_payload, error_message, error_node, pipeline_stage)
 * VALUES (
 *   '{{ $json.message_id }}',
 *   '{{ $json.raw_payload }}'::jsonb,
 *   '{{ $json.error_message }}',
 *   '{{ $json.error_node }}',
 *   '{{ $json.pipeline_stage }}'
 * );
 */
