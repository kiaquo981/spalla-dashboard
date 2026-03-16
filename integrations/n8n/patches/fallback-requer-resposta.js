/**
 * FALLBACK: requer_resposta — Deterministic classification
 * 
 * Onde aplicar no N8N: Code node APÓS o fallback-eh-equipe,
 * ANTES do "Salvar Interação".
 * 
 * Lógica: Se GPT não retornou requer_resposta (null/undefined),
 * usar heurísticas baseadas no conteúdo e classificação.
 * 
 * Princípio: MELHOR FALSO POSITIVO QUE FALSO NEGATIVO.
 * Se em dúvida, marcar como requer_resposta=true.
 * Pendência extra no dashboard < mensagem ignorada.
 */

const items = $input.all();

for (const item of items) {
  const d = item.json;

  // Se GPT já classificou, manter
  if (d.requer_resposta === true || d.requer_resposta === false) continue;

  // Regra 0: mensagens da equipe NÃO requerem resposta
  if (d.eh_equipe === true) {
    d.requer_resposta = false;
    d._requer_resposta_source = 'is_equipe';
    continue;
  }

  const conteudo = (d.conteudo || d.content || '').toLowerCase();
  const tipo = (d.tipo_interacao || d.classificacao || '').toLowerCase();

  // Regra 1: contém interrogação → provavelmente precisa de resposta
  if (conteudo.includes('?')) {
    d.requer_resposta = true;
    d._requer_resposta_source = 'has_question_mark';
    continue;
  }

  // Regra 2: tipo é dúvida, bloqueio ou solicitação
  if (['duvida', 'bloqueio', 'solicitacao', 'pedido'].some(t => tipo.includes(t))) {
    d.requer_resposta = true;
    d._requer_resposta_source = 'tipo_match';
    continue;
  }

  // Regra 3: classificação social/informativo → não requer
  if (['social', 'informativo', 'saudacao', 'agradecimento'].some(t => tipo.includes(t))) {
    d.requer_resposta = false;
    d._requer_resposta_source = 'social_tipo';
    continue;
  }

  // Regra 4: contém palavras-chave de pedido de ajuda
  const HELP_KEYWORDS = ['ajuda', 'como faz', 'não sei', 'nao sei', 'dúvida', 'duvida',
    'preciso', 'urgente', 'problema', 'não consigo', 'nao consigo', 'travado', 'parado'];
  if (HELP_KEYWORDS.some(kw => conteudo.includes(kw))) {
    d.requer_resposta = true;
    d._requer_resposta_source = 'keyword_match';
    continue;
  }

  // Default: conservador — marcar como requer resposta
  // Melhor ter pendência extra do que ignorar mentorado
  d.requer_resposta = false;
  d._requer_resposta_source = 'default_no';
}

return items;
