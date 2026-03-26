"""
Spalla MCP Server — Exposes Supabase data as Goose/MCP tools
EPIC 6: Goose Agent Autonomous Operations

Install: pip install fastmcp httpx
Run: python mcp_server_spalla.py
Configure in Goose: goose configure → add MCP server → stdio → python mcp_server_spalla.py

Tools exposed:
  - get_mentorado(id) — Full mentorado profile
  - list_mentorados(filter) — List with optional filters
  - get_dossie(mentorado_id, tipo) — Get dossiê content
  - create_task(titulo, responsavel, mentorado_id) — Create god_task
  - update_task_status(id, status) — Update task status
  - save_dossie_section(mentorado_id, tipo, secao, conteudo) — Save generated section
  - get_transcricoes(mentorado_id) — Get source transcripts
  - run_fabric_pattern(pattern, input) — Run Fabric pattern
  - evaluate_dossie(dossie, sources, mentorado_id) — Run RAGAS quality gate
"""

import os
import json
import httpx

# Config from env
SPALLA_API_URL = os.environ.get('SPALLA_API_URL', 'http://localhost:8888')
SPALLA_API_KEY = os.environ.get('SPALLA_API_KEY', '')
SUPABASE_URL = os.environ.get('SUPABASE_URL', 'https://knusqfbvhsqworzyhvip.supabase.co')
SUPABASE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', '')

HEADERS = {
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
}

SPALLA_HEADERS = {
    'Authorization': f'Bearer {SPALLA_API_KEY}',
    'Content-Type': 'application/json',
}


def _supabase_get(path: str) -> list | dict:
    """GET from Supabase REST API"""
    resp = httpx.get(f'{SUPABASE_URL}/rest/v1/{path}', headers=HEADERS, timeout=15)
    resp.raise_for_status()
    return resp.json()


def _supabase_post(path: str, body: dict) -> list | dict:
    """POST to Supabase REST API"""
    resp = httpx.post(f'{SUPABASE_URL}/rest/v1/{path}', headers=HEADERS, json=body, timeout=15)
    resp.raise_for_status()
    return resp.json()


def _supabase_patch(path: str, body: dict) -> list | dict:
    """PATCH Supabase REST API"""
    resp = httpx.patch(f'{SUPABASE_URL}/rest/v1/{path}', headers=HEADERS, json=body, timeout=15)
    resp.raise_for_status()
    return resp.json()


def _spalla_post(path: str, body: dict) -> dict:
    """POST to Spalla backend API"""
    resp = httpx.post(f'{SPALLA_API_URL}{path}', headers=SPALLA_HEADERS, json=body, timeout=120)
    resp.raise_for_status()
    return resp.json()


# ===== MCP TOOL DEFINITIONS =====

try:
    from fastmcp import FastMCP
    mcp = FastMCP("spalla")
except ImportError:
    # Fallback: define tools as plain functions (usable via CLI)
    class _FakeMCP:
        def tool(self, *a, **kw):
            def decorator(fn):
                return fn
            return decorator
        def run(self):
            print("FastMCP not installed. Install: pip install fastmcp")
            print("Tools available as Python functions.")
    mcp = _FakeMCP()


@mcp.tool()
def get_mentorado(mentorado_id: int) -> str:
    """Get full mentorado profile by ID. Returns name, email, phone, status, cohort, CS assignment, financial data."""
    data = _supabase_get(f'mentorados?id=eq.{mentorado_id}&select=*&limit=1')
    if not data:
        return json.dumps({"error": "Mentorado not found"})
    return json.dumps(data[0], ensure_ascii=False, default=str)


@mcp.tool()
def list_mentorados(status: str = "ativo", limit: int = 50) -> str:
    """List mentorados with optional status filter. Status: ativo, pausado, concluido, todos."""
    query = 'mentorados?select=id,nome,email,telefone,status,cohort,cs_responsavel&order=nome'
    if status != "todos":
        query += f'&ativo=eq.{"true" if status == "ativo" else "false"}'
    query += f'&limit={min(limit, 100)}'
    data = _supabase_get(query)
    return json.dumps(data, ensure_ascii=False, default=str)


@mcp.tool()
def get_dossie(mentorado_id: int, tipo: str = "oferta") -> str:
    """Get dossiê document for a mentorado. tipo: oferta, posicionamento, funil."""
    data = _supabase_get(
        f'dossie_documents?mentorado_id=eq.{mentorado_id}&tipo=eq.{tipo}'
        f'&select=id,titulo,conteudo,status,created_at,updated_at&limit=1&order=created_at.desc'
    )
    if not data:
        return json.dumps({"error": f"No {tipo} dossiê found for mentorado {mentorado_id}"})
    return json.dumps(data[0], ensure_ascii=False, default=str)


@mcp.tool()
def create_task(titulo: str, responsavel: str = "", mentorado_id: int = None, prioridade: str = "normal") -> str:
    """Create a new task in god_tasks. Returns the created task."""
    task = {
        'titulo': titulo,
        'responsavel': responsavel,
        'prioridade': prioridade,
        'status': 'pendente',
        'fonte': 'goose_agent',
    }
    if mentorado_id:
        task['mentorado_id'] = mentorado_id
    data = _supabase_post('god_tasks', task)
    return json.dumps(data[0] if data else {"error": "Failed to create task"}, ensure_ascii=False, default=str)


@mcp.tool()
def update_task_status(task_id: int, status: str) -> str:
    """Update task status. Valid: pendente, em_andamento, concluida."""
    if status not in ('pendente', 'em_andamento', 'concluida'):
        return json.dumps({"error": "Invalid status"})
    data = _supabase_patch(f'god_tasks?id=eq.{task_id}', {'status': status})
    return json.dumps(data[0] if data else {"error": "Task not found"}, ensure_ascii=False, default=str)


@mcp.tool()
def save_dossie_section(mentorado_id: int, tipo: str, conteudo: str) -> str:
    """Save or update a dossiê document for a mentorado."""
    # Check if exists
    existing = _supabase_get(
        f'dossie_documents?mentorado_id=eq.{mentorado_id}&tipo=eq.{tipo}&select=id&limit=1'
    )
    if existing:
        data = _supabase_patch(
            f'dossie_documents?id=eq.{existing[0]["id"]}',
            {'conteudo': conteudo, 'status': 'rascunho'}
        )
    else:
        data = _supabase_post('dossie_documents', {
            'mentorado_id': mentorado_id,
            'tipo': tipo,
            'conteudo': conteudo,
            'status': 'rascunho',
            'fonte': 'goose_agent',
        })
    return json.dumps(data[0] if data else {"ok": True}, ensure_ascii=False, default=str)


@mcp.tool()
def get_transcricoes(mentorado_id: int) -> str:
    """Get source transcripts/documents for a mentorado (from storage_files)."""
    data = _supabase_get(
        f'storage_files?entity_type=eq.mentorado&entity_id=eq.{mentorado_id}'
        f'&select=id,filename,extracted_text,status&status=eq.concluido'
        f'&order=created_at.desc&limit=10'
    )
    if not data:
        return json.dumps({"message": "No transcripts found", "mentorado_id": mentorado_id})
    results = []
    for doc in data:
        results.append({
            'filename': doc.get('filename', ''),
            'text_preview': (doc.get('extracted_text', '') or '')[:500],
            'full_length': len(doc.get('extracted_text', '') or ''),
        })
    return json.dumps(results, ensure_ascii=False)


@mcp.tool()
def run_fabric_pattern(pattern: str, input_text: str, model: str = "claude-sonnet-4-20250514") -> str:
    """Run a Fabric AI pattern on input text. Available CASE patterns:
    case_extract_oferta, case_extract_posicionamento, case_extract_funil,
    case_analyze_call, case_lapidacao_perfil.
    Also supports any native Fabric pattern: summarize, extract_wisdom, etc."""
    result = _spalla_post('/api/fabric/run', {
        'pattern': pattern,
        'input': input_text,
        'model': model,
    })
    return json.dumps(result, ensure_ascii=False)


@mcp.tool()
def evaluate_dossie(dossie_text: str, source_texts: list, mentorado_id: int = None) -> str:
    """Run RAGAS quality evaluation on a generated dossiê.
    Returns scores (faithfulness, correctness, precision) and verdict (approved/needs_review/failed)."""
    result = _spalla_post('/api/dossie/evaluate', {
        'dossie': dossie_text,
        'sources': source_texts,
        'mentorado_id': mentorado_id,
    })
    return json.dumps(result, ensure_ascii=False)


if __name__ == '__main__':
    mcp.run()
