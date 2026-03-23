#!/usr/bin/env python3
"""
seed_biblioteca.py — Carrega os dossiês da Danyella Truiz no Spalla Biblioteca

Uso:
    python3 seed_biblioteca.py

Requer:
    pip install python-dotenv requests

Variáveis de ambiente (ou .env na raiz do projeto):
    SUPABASE_URL=https://...supabase.co
    SUPABASE_SERVICE_KEY=service_role_key
"""

import os
import re
import sys
import json
import uuid
import unicodedata
import http.client
from pathlib import Path

# --- Carrega .env se existir ---
try:
    from dotenv import load_dotenv
    root = Path(__file__).parent.parent
    load_dotenv(root / '.env')
except ImportError:
    pass

SUPABASE_URL = os.environ.get('SUPABASE_URL', '')
SUPABASE_SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', '')

if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
    print('❌ SUPABASE_URL e SUPABASE_SERVICE_KEY precisam estar definidos.')
    sys.exit(1)

SUPABASE_HOST = SUPABASE_URL.replace('https://', '').replace('http://', '').rstrip('/')

# --- Dossiers da Danyella ---
DOSSIERS_DIR = Path(
    os.path.expanduser(
        '~/Downloads/DANYELLA_TRUIZ_DOSSIERES_FINAL_2026-03-05'
    )
)

DOCS_TO_SEED = [
    {
        'file': '01-DOSSIÊ-OFERTA-DANYELLA-FINAL.md',
        'tipo': 'dossie',
        'titulo': 'Dossiê de Oferta',
        'subtitulo': 'Contexto de mercado, storytelling, público-alvo, tese e arquitetura da oferta',
        'versao': 'gold',
        'tags': ['oferta', 'storytelling', 'público', 'tese'],
        'deep_link_slug': 'danyella-truiz-oferta',
    },
    {
        'file': '02-DOSSIÊ-POSICIONAMENTO-CONTEUDO-DANYELLA-GOLD.md',
        'tipo': 'dossie',
        'titulo': 'Dossiê de Posicionamento e Conteúdo',
        'subtitulo': 'Estratégia Instagram, calendário de conteúdo, scripts de destaques e stories',
        'versao': 'gold',
        'tags': ['posicionamento', 'instagram', 'conteúdo', 'stories'],
        'deep_link_slug': 'danyella-truiz-posicionamento',
    },
    {
        'file': '03-DOSSIÊ-FUNIL-VENDAS-DANYELLA-GOLD.md',
        'tipo': 'dossie',
        'titulo': 'Dossiê de Funil de Vendas',
        'subtitulo': 'Scripts de qualificação e venda, funis, objeções e cronograma executivo',
        'versao': 'gold',
        'tags': ['funil', 'scripts', 'vendas', 'objeções'],
        'deep_link_slug': 'danyella-truiz-funil-vendas',
    },
]

# Scripts extraídos do dossiê 03 como documentos separados tipo 'roteiro'
ROTEIROS_TO_EXTRACT = [
    {
        'source_file': '03-DOSSIÊ-FUNIL-VENDAS-DANYELLA-GOLD.md',
        'section_title': 'Script 1: Call de Qualificação (30 min)',
        'tipo': 'roteiro',
        'titulo': 'Script — Call de Qualificação',
        'subtitulo': 'Roteiro completo para call de qualificação de 30 minutos (funil de vendas)',
        'versao': 'gold',
        'tags': ['call', 'qualificação', 'roteiro', 'vendas'],
        'deep_link_slug': 'danyella-truiz-script-qualificacao',
    },
    {
        'source_file': '03-DOSSIÊ-FUNIL-VENDAS-DANYELLA-GOLD.md',
        'section_title': 'Script 2: Call de Venda (45 min)',
        'tipo': 'roteiro',
        'titulo': 'Script — Call de Venda',
        'subtitulo': 'Roteiro completo para call de vendas de 45 minutos com tratamento de objeções',
        'versao': 'gold',
        'tags': ['call', 'venda', 'roteiro', 'objeções'],
        'deep_link_slug': 'danyella-truiz-script-venda',
    },
    {
        'source_file': '03-DOSSIÊ-FUNIL-VENDAS-DANYELLA-GOLD.md',
        'section_title': 'Script 3: WhatsApp — Follow-up (Depois da Call de Venda)',
        'tipo': 'roteiro',
        'titulo': 'Script — WhatsApp Follow-up Pós-Call',
        'subtitulo': 'Templates de mensagem WhatsApp para follow-up após call de vendas',
        'versao': 'gold',
        'tags': ['whatsapp', 'follow-up', 'mensagem', 'roteiro'],
        'deep_link_slug': 'danyella-truiz-script-whatsapp-followup',
    },
]


def slugify(text: str) -> str:
    text = unicodedata.normalize('NFKD', text)
    text = text.encode('ascii', 'ignore').decode('ascii')
    text = re.sub(r'[^\w\s-]', '', text.lower())
    text = re.sub(r'[-\s]+', '-', text).strip('-')
    return text


def parse_sections(md: str) -> list[dict]:
    """Extrai índice de seções (H2/H3) do markdown."""
    sections = []
    order = 0
    for m in re.finditer(r'^(#{2,3})\s+(.+?)$', md, re.MULTILINE):
        nivel = len(m.group(1))
        titulo = m.group(2).strip().strip('*').strip()
        ancora = slugify(titulo)[:80]
        sections.append({
            'id': str(uuid.uuid4()),
            'ancora': ancora,
            'titulo': titulo,
            'nivel': nivel,
            'ordem': order,
        })
        order += 1
    return sections


def extract_section_content(md: str, section_title: str) -> str:
    """Extrai o conteúdo de uma seção H2 até a próxima H2."""
    # Remove asteriscos do título para comparar
    clean_title = section_title.strip().strip('*')
    pattern = re.compile(
        r'^## \*?\*?' + re.escape(clean_title) + r'\*?\*?.*?$',
        re.MULTILINE | re.IGNORECASE,
    )
    match = pattern.search(md)
    if not match:
        print(f'  ⚠️  Seção "{section_title}" não encontrada no arquivo')
        return ''

    start = match.start()
    # Encontra o próximo H2 depois do início da seção
    next_h2 = re.search(r'^## ', md[match.end():], re.MULTILINE)
    if next_h2:
        end = match.end() + next_h2.start()
    else:
        end = len(md)

    return md[start:end].strip()


def supa_request(method: str, path: str, body=None) -> dict:
    """Faz request para Supabase REST API."""
    headers = {
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
    }
    data = json.dumps(body).encode() if body else None
    conn = http.client.HTTPSConnection(SUPABASE_HOST, timeout=30)
    conn.request(method, f'/rest/v1/{path}', body=data, headers=headers)
    resp = conn.getresponse()
    body_raw = resp.read()
    conn.close()
    if resp.status in (200, 201):
        return {'ok': True, 'data': json.loads(body_raw) if body_raw else {}}
    return {'ok': False, 'status': resp.status, 'body': body_raw.decode()}


def get_mentee_id(nome: str):
    """Busca o ID do mentorado pelo nome."""
    result = supa_request('GET', f'mentorados?select=id,nome&nome=ilike.*{nome}*&limit=5')
    if result['ok'] and result['data']:
        rows = result['data']
        if len(rows) == 1:
            return rows[0]['id']
        # Mostra opções se ambíguo
        print(f'  Encontrados {len(rows)} mentorados:')
        for r in rows:
            print(f'    [{r["id"]}] {r["nome"]}')
        print('  Usando o primeiro: ', rows[0]['nome'])
        return rows[0]['id']
    return None


def delete_existing(mentee_id: int):
    """Remove documentos existentes do mentorado (limpa antes de re-seed)."""
    result = supa_request('DELETE', f'sp_documentos?mentee_id=eq.{mentee_id}')
    if result['ok']:
        print('  🗑️  Documentos anteriores removidos')
    else:
        print(f'  ⚠️  Delete retornou: {result}')


def insert_doc(doc: dict) -> bool:
    result = supa_request('POST', 'sp_documentos', doc)
    if result['ok']:
        print(f'  ✅ Inserido: {doc["titulo"]}')
        return True
    print(f'  ❌ Falha ao inserir "{doc["titulo"]}": {result}')
    return False


def main():
    print('\n🌱 Spalla Biblioteca — Seed Script')
    print('=' * 50)

    # Verifica diretório
    if not DOSSIERS_DIR.exists():
        print(f'❌ Diretório não encontrado: {DOSSIERS_DIR}')
        sys.exit(1)

    # Busca mentorado
    print('\n🔍 Buscando Danyella Truiz no Supabase...')
    mentee_id = get_mentee_id('Danyella')
    if mentee_id:
        print(f'  ✅ mentee_id = {mentee_id}')
    else:
        print('  ⚠️  Mentorado não encontrado — inserindo com mentee_id = NULL')
        print('     (Você pode atualizar depois via SQL)')

    # Remove seed anterior
    if mentee_id:
        print('\n🗑️  Limpando seed anterior...')
        delete_existing(mentee_id)

    inserted = 0
    total = len(DOCS_TO_SEED) + len(ROTEIROS_TO_EXTRACT)

    # --- Insere dossiês completos ---
    print(f'\n📚 Inserindo {len(DOCS_TO_SEED)} dossiês completos...')
    for spec in DOCS_TO_SEED:
        filepath = DOSSIERS_DIR / spec['file']
        if not filepath.exists():
            print(f'  ⚠️  Arquivo não encontrado: {filepath}')
            continue

        md = filepath.read_text(encoding='utf-8')
        secoes = parse_sections(md)

        doc = {
            'mentee_id': mentee_id,
            'tipo': spec['tipo'],
            'titulo': spec['titulo'],
            'subtitulo': spec.get('subtitulo'),
            'conteudo_md': md,
            'secoes': secoes,
            'versao': spec['versao'],
            'tags': spec.get('tags', []),
            'deep_link_slug': spec.get('deep_link_slug'),
        }
        if insert_doc(doc):
            inserted += 1
        print(f'     ({len(secoes)} seções, {len(md):,} chars)')

    # --- Extrai roteiros como docs separados ---
    print(f'\n🎬 Extraindo {len(ROTEIROS_TO_EXTRACT)} roteiros...')
    for spec in ROTEIROS_TO_EXTRACT:
        filepath = DOSSIERS_DIR / spec['source_file']
        if not filepath.exists():
            print(f'  ⚠️  Arquivo não encontrado: {filepath}')
            continue

        md_full = filepath.read_text(encoding='utf-8')
        conteudo = extract_section_content(md_full, spec['section_title'])
        if not conteudo:
            continue

        secoes = parse_sections(conteudo)
        doc = {
            'mentee_id': mentee_id,
            'tipo': spec['tipo'],
            'titulo': spec['titulo'],
            'subtitulo': spec.get('subtitulo'),
            'conteudo_md': conteudo,
            'secoes': secoes,
            'versao': spec['versao'],
            'tags': spec.get('tags', []),
            'deep_link_slug': spec.get('deep_link_slug'),
        }
        if insert_doc(doc):
            inserted += 1
        print(f'     ({len(secoes)} seções, {len(conteudo):,} chars)')

    print(f'\n🎉 Seed concluído: {inserted}/{total} documentos inseridos')
    if mentee_id is None:
        print('\n💡 Para linkar ao mentorado depois:')
        print('   UPDATE sp_documentos SET mentee_id = <ID> WHERE mentee_id IS NULL;')


if __name__ == '__main__':
    main()
