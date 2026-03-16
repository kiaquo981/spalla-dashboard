/**
 * FALLBACK: GPT Classifier — Conservative classification on AI failure
 * 
 * Onde aplicar no N8N: Error branch do [PATCH] Detector Tipo Mensagem,
 * ou como Code node de fallback quando GPT retorna erro/timeout/JSON inválido.
 * 
 * Quando o GPT falha (timeout, rate limit, JSON mal-formado), em vez de
 * retornar [] (perder a mensagem), retornar classificação conservadora.
 * 
 * Flag classification_fallback=true marca para tracking/debug.
 */

const items = $input.all();

for (const item of items) {
  const d = item.json;

  // Se já tem classificação válida, pular
  if (d.classificacao && d.eh_equipe !== undefined && d.requer_resposta !== undefined) {
    continue;
  }

  // Classificação conservadora — garante que msg não desaparece
  d.classificacao = d.classificacao || 'NAO_CLASSIFICADO';
  d.tipo_interacao = d.tipo_interacao || 'mensagem';
  d.sentimento = d.sentimento || 'neutro';
  d.prioridade = d.prioridade || 'normal';
  d.score_engajamento = d.score_engajamento || 5;
  d.classification_fallback = true;
  d._fallback_reason = 'gpt_failure';
  d._fallback_timestamp = new Date().toISOString();

  // eh_equipe e requer_resposta serão tratados pelos fallback nodes seguintes
  // (fallback-eh-equipe.js e fallback-requer-resposta.js)
}

return items;
