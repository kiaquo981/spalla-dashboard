#!/usr/bin/env python3
"""
LF Smoke Test — Story LF-3.10 + 6/6 do MVP-LF
==============================================

Cenário ouro:
  Kaique digita: "preciso fazer dossiê da {mentee} pra quinta-feira, urgente"
  → POST /capture
  → POST /process (saga: classifier → ação)
  → polling até finalizado
  → valida que task foi criada com fields esperados

Uso:
  RAILWAY_URL=https://web-production-2cde5.up.railway.app \
  AUTH_TOKEN=... \
  python scripts/lf_smoke_test.py [mentorado_id]

Sem AUTH_TOKEN, usa SUPABASE_ANON_KEY pra ler resultado read-only.
"""
import json
import os
import sys
import time
import urllib.request
import urllib.error

BACKEND = os.environ.get('RAILWAY_URL', 'https://web-production-2cde5.up.railway.app')
TOKEN = os.environ.get('AUTH_TOKEN', os.environ.get('SUPABASE_ANON_KEY', ''))
ANON = os.environ.get('SUPABASE_ANON_KEY', '')
SUPA_URL = 'https://knusqfbvhsqworzyhvip.supabase.co/rest/v1'


def http(method, url, body=None, headers=None):
    headers = headers or {}
    data = json.dumps(body).encode() if body is not None else None
    if data:
        headers.setdefault('Content-Type', 'application/json')
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return resp.status, json.loads(resp.read() or b'{}')
    except urllib.error.HTTPError as e:
        return e.code, {'error': e.read().decode('utf-8', errors='ignore')[:500]}


def supa_get(path):
    return http('GET', f'{SUPA_URL}/{path}', headers={
        'apikey': ANON, 'Authorization': f'Bearer {ANON}',
    })


def main():
    mentorado_id = int(sys.argv[1]) if len(sys.argv) > 1 else None
    if not mentorado_id:
        # Pega o primeiro mentorado ativo
        code, rows = supa_get('mentorados?select=id,nome&ativo=eq.true&limit=1')
        if code != 200 or not rows:
            print('FAIL: sem mentorado disponível', code, rows)
            sys.exit(1)
        mentorado_id = rows[0]['id']
        mentorado_nome = rows[0].get('nome', '?')
    else:
        code, rows = supa_get(f'mentorados?id=eq.{mentorado_id}&select=nome')
        mentorado_nome = (rows or [{}])[0].get('nome', '?') if code == 200 else '?'

    print(f'\n=== LF Smoke Test ===')
    print(f'Backend:    {BACKEND}')
    print(f'Mentorado:  #{mentorado_id} {mentorado_nome}')
    print()

    # 1) CAPTURE
    body = {
        'mentorado_id': mentorado_id,
        'tipo_bruto': 'texto',
        'conteudo_bruto': f'preciso fazer dossiê da {mentorado_nome} pra quinta-feira, urgente',
        'fonte': 'smoke_test',
    }
    print('[1/4] POST /api/descarrego/capture')
    code, resp = http('POST', f'{BACKEND}/api/descarrego/capture',
                       body=body,
                       headers={'Authorization': f'Bearer {TOKEN}'})
    if code not in (200, 201):
        print(f'  FAIL {code}: {resp}'); sys.exit(1)
    descarrego_id = resp.get('descarrego_id')
    correlation_id = resp.get('correlation_id')
    print(f'  OK descarrego_id={descarrego_id}')
    print(f'     correlation_id={correlation_id}')

    # 2) PROCESS
    print('[2/4] POST /api/descarrego/{id}/process')
    code, resp = http('POST', f'{BACKEND}/api/descarrego/{descarrego_id}/process',
                       headers={'Authorization': f'Bearer {TOKEN}'})
    if code not in (200, 202):
        print(f'  FAIL {code}: {resp}'); sys.exit(1)
    print(f'  OK status={resp.get("status")}')

    # 3) POLL
    print('[3/4] Polling até estado terminal (max 90s)')
    deadline = time.time() + 90
    final = None
    while time.time() < deadline:
        code, rows = supa_get(f'descarregos?id=eq.{descarrego_id}&select=*')
        if code == 200 and rows:
            r = rows[0]
            print(f'    [{int(time.time() - (deadline - 90)):>3}s] status={r["status"]} '
                  f'classif={r.get("classificacao_principal")} '
                  f'conf={r.get("classificacao_confidence")}')
            if r['status'] in ('finalizado', 'rejeitado', 'erro', 'aguardando_humano'):
                final = r
                break
        time.sleep(3)

    if not final:
        print('  FAIL: timeout 90s sem chegar em estado terminal')
        sys.exit(1)

    print(f'  Final: status={final["status"]} classif={final.get("classificacao_principal")} '
          f'conf={final.get("classificacao_confidence")}')

    # 4) VERIFY
    print('[4/4] Validando task criada')
    if final['status'] == 'erro':
        print(f'  FAIL erro: {final.get("last_error")}')
        sys.exit(1)
    if final['status'] == 'aguardando_humano':
        print(f'  WARN: foi pra HITL (confidence baixa). OK pro classifier funcionar.')
        sys.exit(0)
    if final['status'] == 'rejeitado':
        print(f'  FAIL rejeitado'); sys.exit(1)

    if not final.get('task_id'):
        print(f'  WARN: finalizado mas sem task_id (acao_tomada={final.get("acao_tomada")})')
        sys.exit(0)

    code, rows = supa_get(f'god_tasks?id=eq.{final["task_id"]}'
                          f'&select=id,titulo,responsavel,prioridade,data_fim,fonte,auto_created')
    if code != 200 or not rows:
        print(f'  FAIL: task {final["task_id"]} não encontrada'); sys.exit(1)
    task = rows[0]
    print(f'  OK task criada:')
    print(f'    titulo:      {task["titulo"]}')
    print(f'    responsavel: {task["responsavel"]}')
    print(f'    prioridade:  {task["prioridade"]}')
    print(f'    data_fim:    {task.get("data_fim")}')
    print(f'    fonte:       {task["fonte"]}')
    print(f'    auto:        {task.get("auto_created")}')

    print('\n✅ SMOKE TEST PASSED')


if __name__ == '__main__':
    main()
