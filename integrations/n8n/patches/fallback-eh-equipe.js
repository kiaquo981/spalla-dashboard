/**
 * FALLBACK: eh_equipe — Deterministic classification
 * 
 * Onde aplicar no N8N: Code node APÓS o [PATCH] Detector Tipo Mensagem,
 * ANTES do "Salvar Interação".
 * 
 * Lógica: Se GPT não retornou eh_equipe (null/undefined), usar heurísticas
 * baseadas em dados determinísticos (telefone, nome, from_me).
 * 
 * Equipe CASE:
 *   Heitor:  5527999473185
 *   Kaique:  5511964682447
 *   Lara:    5524992514909
 *   Queila:  5527988918032
 *   Thiago:  5511967755879
 */

const EQUIPE_PHONES = new Set([
  '5527999473185',  // Heitor
  '5511964682447',  // Kaique
  '5524992514909',  // Lara
  '5527988918032',  // Queila
  '5511967755879',  // Thiago
]);

const EQUIPE_NAMES = ['heitor', 'kaique', 'lara', 'queila', 'thiago', 'hugo'];

const items = $input.all();

for (const item of items) {
  const d = item.json;

  // Se GPT já classificou, manter
  if (d.eh_equipe === true || d.eh_equipe === false) continue;

  // Heurística 1: telefone do sender está na lista da equipe
  const phone = (d.sender_phone || '').replace(/\D/g, '');
  if (EQUIPE_PHONES.has(phone)) {
    d.eh_equipe = true;
    d._eh_equipe_source = 'phone_match';
    continue;
  }

  // Heurística 2: from_me = true (msg enviada pelo número do webhook)
  if (d.from_me === true) {
    d.eh_equipe = true;
    d._eh_equipe_source = 'from_me';
    continue;
  }

  // Heurística 3: nome do sender contém nome da equipe
  const name = (d.sender_name || '').toLowerCase();
  if (EQUIPE_NAMES.some(n => name.includes(n))) {
    d.eh_equipe = true;
    d._eh_equipe_source = 'name_match';
    continue;
  }

  // Default: não é equipe
  d.eh_equipe = false;
  d._eh_equipe_source = 'default';
}

return items;
