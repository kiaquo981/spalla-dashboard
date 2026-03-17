"""
Spalla Dashboard — Server with Zoom, Google Calendar & Supabase Integration
Serves static files + proxies APIs
"""

import http.server
import http.client
import json
import urllib.request
import urllib.error
import urllib.parse
import os
import sys
import time
import base64
import threading
import hmac
import hashlib
import secrets
import unicodedata
import re
from datetime import datetime, timedelta, timezone

try:
    import jwt
except ImportError:
    jwt = None  # Will handle gracefully if not installed

try:
    import bcrypt as _bcrypt
except ImportError:
    _bcrypt = None  # Falls back to SHA-256 if not installed

# ===== SENTRY ERROR MONITORING =====
try:
    import sentry_sdk
    _sentry_dsn = os.environ.get('SENTRY_DSN', '')
    if _sentry_dsn:
        sentry_sdk.init(dsn=_sentry_dsn, traces_sample_rate=0.1)
        print('[Sentry] Initialized successfully')
    else:
        print('[Sentry] SENTRY_DSN not set — error monitoring disabled')
except ImportError:
    print('[Sentry] sentry-sdk not installed — pip install sentry-sdk')


PORT = int(os.environ.get('PORT', 8888))

# ===== CONFIG =====
EVOLUTION_BASE = os.environ.get('EVOLUTION_BASE', 'https://evolution.manager01.feynmanproject.com')
EVOLUTION_API_KEY = os.environ.get('EVOLUTION_API_KEY', '')

# Zoom Server-to-Server OAuth
ZOOM_ACCOUNT_ID = os.environ.get('ZOOM_ACCOUNT_ID', '')
ZOOM_CLIENT_ID = os.environ.get('ZOOM_CLIENT_ID', '')
ZOOM_CLIENT_SECRET = os.environ.get('ZOOM_CLIENT_SECRET', '')

# Google Service Account
GOOGLE_SA_PATH = os.path.expanduser('~/.config/google/credentials.json')

# Supabase
SUPABASE_URL = os.environ.get('SUPABASE_URL', '')
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY', '')
SUPABASE_SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', '')

# Calendar ID
GOOGLE_CALENDAR_ID = os.environ.get('GOOGLE_CALENDAR_ID', 'primary')

# ===== HETZNER S3 CONFIG =====
S3_ACCESS_KEY = os.environ.get('S3_ACCESS_KEY', '')
S3_SECRET_KEY = os.environ.get('S3_SECRET_KEY', '')
S3_BUCKET     = os.environ.get('S3_BUCKET', 'case-evolution-media')
S3_ENDPOINT   = os.environ.get('S3_ENDPOINT', 'hel1.your-objectstorage.com')
S3_REGION     = os.environ.get('S3_REGION', 'eu-central')

# ===== JWT AUTH CONFIG =====
JWT_SECRET = os.environ.get('JWT_SECRET')
if not JWT_SECRET:
    _is_production = os.environ.get('RAILWAY_ENVIRONMENT') or os.environ.get('RAILWAY_SERVICE_ID')
    if _is_production:
        print('[FATAL] JWT_SECRET environment variable is required in production')
        print('[FATAL] Set it in Railway: railway variables set JWT_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")')
        sys.exit(1)
    JWT_SECRET = secrets.token_hex(32)
    print('[WARNING] JWT_SECRET not set — generated ephemeral key (dev only, tokens will not survive restarts)')
JWT_ALGORITHM = 'HS256'
ACCESS_TOKEN_EXPIRY_MINUTES = 60
REFRESH_TOKEN_EXPIRY_DAYS = 7
# ===== AUTH FUNCTIONS (Supabase-backed) =====
def hash_password(password):
    """Hash password using bcrypt (falls back to SHA-256 if bcrypt unavailable)"""
    if _bcrypt:
        return _bcrypt.hashpw(password.encode(), _bcrypt.gensalt()).decode()
    return hashlib.sha256(password.encode()).hexdigest()

def _is_legacy_sha256(stored_hash):
    """Check if hash is a legacy SHA-256 (64 hex chars)"""
    return len(stored_hash) == 64 and all(c in '0123456789abcdef' for c in stored_hash)

def verify_password(password, stored_hash):
    """Verify password — supports both bcrypt and legacy SHA-256"""
    if _is_legacy_sha256(stored_hash):
        if hashlib.sha256(password.encode()).hexdigest() == stored_hash:
            return 'migrate'  # Signal to upgrade hash
        return False
    if _bcrypt:
        try:
            return _bcrypt.checkpw(password.encode(), stored_hash.encode())
        except Exception:
            return False
    return hashlib.sha256(password.encode()).hexdigest() == stored_hash

def create_jwt_token(email, user_id, expiry_minutes=ACCESS_TOKEN_EXPIRY_MINUTES):
    """Create JWT access token"""
    if not jwt:
        return None
    payload = {
        'email': email,
        'user_id': user_id,
        'role': 'team',
        'exp': datetime.now(timezone.utc) + timedelta(minutes=expiry_minutes),
        'iat': datetime.now(timezone.utc)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def create_refresh_token(email, user_id):
    """Create JWT refresh token (long-lived)"""
    if not jwt:
        return None
    payload = {
        'email': email,
        'user_id': user_id,
        'type': 'refresh',
        'exp': datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRY_DAYS),
        'iat': datetime.now(timezone.utc)
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def verify_jwt_token(token):
    """Verify and decode JWT token"""
    if not jwt:
        return None
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

# Auth users stored in Supabase table 'auth_users'

def generate_presigned_url(key, expires=3600):
    """Generate AWS Signature V4 presigned URL for Hetzner S3"""
    host = S3_ENDPOINT
    algorithm = 'AWS4-HMAC-SHA256'
    now = datetime.now(timezone.utc)
    amz_date = now.strftime('%Y%m%dT%H%M%SZ')
    datestamp = now.strftime('%Y%m%d')

    # Debug: log S3 config
    print(f'[S3 Debug] BUCKET={S3_BUCKET}, ENDPOINT={S3_ENDPOINT}, REGION={S3_REGION}, KEY={key}')

    # Canonical request
    method = 'GET'
    canonical_uri = f'/{S3_BUCKET}/{key}'
    credential_scope = f'{datestamp}/{S3_REGION}/s3/aws4_request'

    canonical_querystring = f'X-Amz-Algorithm={algorithm}&X-Amz-Credential={urllib.parse.quote(f"{S3_ACCESS_KEY}/{credential_scope}", safe="")}&X-Amz-Date={amz_date}&X-Amz-Expires={expires}&X-Amz-SignedHeaders=host'

    canonical_headers = f'host:{host}\n'
    signed_headers = 'host'

    payload_hash = hashlib.sha256(b'').hexdigest()

    canonical_request = f'{method}\n{canonical_uri}\n{canonical_querystring}\n{canonical_headers}\n{signed_headers}\n{payload_hash}'

    # String to sign
    canonical_request_hash = hashlib.sha256(canonical_request.encode()).hexdigest()
    string_to_sign = f'{algorithm}\n{amz_date}\n{credential_scope}\n{canonical_request_hash}'

    # Calculate signature
    kDate = hmac.new(f'AWS4{S3_SECRET_KEY}'.encode(), datestamp.encode(), hashlib.sha256).digest()
    kRegion = hmac.new(kDate, S3_REGION.encode(), hashlib.sha256).digest()
    kService = hmac.new(kRegion, b's3', hashlib.sha256).digest()
    kSigning = hmac.new(kService, b'aws4_request', hashlib.sha256).digest()
    signature = hmac.new(kSigning, string_to_sign.encode(), hashlib.sha256).hexdigest()

    # Build URL
    url = f'https://{host}{canonical_uri}?{canonical_querystring}&X-Amz-Signature={signature}'
    return url

# ===== SUPABASE CONNECTION POOL =====
SUPABASE_HOST = 'knusqfbvhsqworzyhvip.supabase.co'
_supa_lock = threading.Lock()
_supa_conn = None


def _get_supa_conn():
    """Retorna conexão HTTPS persistente com Supabase"""
    global _supa_conn
    if _supa_conn is not None:
        return _supa_conn
    _supa_conn = http.client.HTTPSConnection(SUPABASE_HOST, timeout=15)
    return _supa_conn


def _reset_supa_conn():
    """Fecha e reseta a conexão Supabase"""
    global _supa_conn
    try:
        if _supa_conn:
            _supa_conn.close()
    except Exception:
        pass
    _supa_conn = None


def log_info(source, msg):
    """Log info message with timestamp"""
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f'[{ts}] [{source}] {msg}')


def log_error(source, msg, exc=None):
    """Log error message with timestamp"""
    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    if exc:
        print(f'[{ts}] [{source}] ERROR: {msg} — {exc}')
    else:
        print(f'[{ts}] [{source}] ERROR: {msg}')


# ===== ZOOM TOKEN CACHE =====
_zoom_token = {'access_token': None, 'expires_at': 0}


def get_zoom_token():
    """Get Zoom access token via Server-to-Server OAuth"""
    global _zoom_token
    if _zoom_token['access_token'] and time.time() < _zoom_token['expires_at'] - 60:
        return _zoom_token['access_token']

    if not ZOOM_ACCOUNT_ID or not ZOOM_CLIENT_ID or not ZOOM_CLIENT_SECRET:
        return None

    creds = base64.b64encode(f'{ZOOM_CLIENT_ID}:{ZOOM_CLIENT_SECRET}'.encode()).decode()
    url = f'https://zoom.us/oauth/token?grant_type=account_credentials&account_id={ZOOM_ACCOUNT_ID}'
    req = urllib.request.Request(url, data=b'', method='POST')
    req.add_header('Authorization', f'Basic {creds}')
    req.add_header('Content-Type', 'application/x-www-form-urlencoded')

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
            _zoom_token['access_token'] = data['access_token']
            _zoom_token['expires_at'] = time.time() + data.get('expires_in', 3600)
            return data['access_token']
    except Exception as e:
        print(f'[Zoom] Token error: {e}')
        return None


def create_zoom_meeting(topic, start_time, duration=60, invitees=None):
    """Create a Zoom meeting and return join_url + meeting_id"""
    token = get_zoom_token()
    if not token:
        return {'error': 'Zoom credentials not configured'}

    body = json.dumps({
        'topic': topic,
        'type': 2,  # Scheduled meeting
        'start_time': start_time,  # ISO 8601
        'duration': duration,
        'timezone': 'America/Sao_Paulo',
        'settings': {
            'join_before_host': True,
            'waiting_room': False,
            'auto_recording': 'cloud',
            'meeting_invitees': [{'email': e} for e in (invitees or [])],
        }
    }).encode()

    req = urllib.request.Request('https://api.zoom.us/v2/users/me/meetings', data=body, method='POST')
    req.add_header('Authorization', f'Bearer {token}')
    req.add_header('Content-Type', 'application/json')

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
            return {
                'meeting_id': data.get('id'),
                'join_url': data.get('join_url'),
                'start_url': data.get('start_url'),
                'password': data.get('password'),
                'topic': data.get('topic'),
            }
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        print(f'[Zoom] Create meeting error: {err}')
        return {'error': f'Zoom API error: {e.code}', 'detail': err}
    except Exception as e:
        return {'error': str(e)}


# ===== GOOGLE CALENDAR =====
_gcal_service = None


def get_gcal_service():
    """Initialize Google Calendar API service using service account"""
    global _gcal_service
    if _gcal_service:
        return _gcal_service

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        if not os.path.exists(GOOGLE_SA_PATH):
            print(f'[GCal] Service account not found at {GOOGLE_SA_PATH}')
            return None

        SCOPES = ['https://www.googleapis.com/auth/calendar']
        credentials = service_account.Credentials.from_service_account_file(
            GOOGLE_SA_PATH, scopes=SCOPES
        )

        # If GOOGLE_CALENDAR_ID is not the service account's own calendar,
        # we need to impersonate the user (requires domain-wide delegation)
        # For now, use the service account's own calendar or a shared one
        _gcal_service = build('calendar', 'v3', credentials=credentials)
        return _gcal_service
    except Exception as e:
        print(f'[GCal] Init error: {e}')
        return None


def create_calendar_event(summary, start_iso, end_iso, description='', attendees=None, location=''):
    """Create a Google Calendar event"""
    service = get_gcal_service()
    if not service:
        return {'error': 'Google Calendar not configured'}

    event = {
        'summary': summary,
        'description': description,
        'start': {
            'dateTime': start_iso,
            'timeZone': 'America/Sao_Paulo',
        },
        'end': {
            'dateTime': end_iso,
            'timeZone': 'America/Sao_Paulo',
        },
        'reminders': {
            'useDefault': False,
            'overrides': [
                {'method': 'popup', 'minutes': 30},
                {'method': 'email', 'minutes': 60},
            ],
        },
    }

    if location:
        event['location'] = location

    if attendees:
        event['attendees'] = [{'email': e} for e in attendees if e]

    try:
        result = service.events().insert(
            calendarId=GOOGLE_CALENDAR_ID,
            body=event,
            sendUpdates='all'  # Send email invites
        ).execute()
        return {
            'event_id': result.get('id'),
            'html_link': result.get('htmlLink'),
            'status': result.get('status'),
        }
    except Exception as e:
        print(f'[GCal] Create event error: {e}')
        return {'error': str(e)}


def list_calendar_events(time_min=None, time_max=None, max_results=50):
    """List upcoming calendar events"""
    service = get_gcal_service()
    if not service:
        return {'error': 'Google Calendar not configured'}

    if not time_min:
        time_min = datetime.now(timezone.utc).isoformat() + 'Z'

    try:
        result = service.events().list(
            calendarId=GOOGLE_CALENDAR_ID,
            timeMin=time_min,
            timeMax=time_max,
            maxResults=max_results,
            singleEvents=True,
            orderBy='startTime'
        ).execute()
        return {'events': result.get('items', [])}
    except Exception as e:
        return {'error': str(e)}


# ===== GOOGLE SHEETS SYNC =====
PAYMENTS_SHEET_ID = '1YY6t5ZxRPTLyCHC-EVkyem10caEJw4TuBy3AR14r0ao'
PAYMENTS_TAB = 'Acompanhamento Pagamentos'
CONTRACTS_SHEET_ID = '1-Yi5G-bUJanRtmfugFgmVz_DRSV-HOEaP-sSAJqUIxY'
CONTRACTS_TAB = 'Dossiê Estratégico Mentorados'

_sheets_service = None
_sheets_last_sync = None
_sheets_last_result = None


def get_sheets_service():
    """Initialize Google Sheets API service using service account"""
    global _sheets_service
    if _sheets_service:
        return _sheets_service

    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        if not os.path.exists(GOOGLE_SA_PATH):
            log_error('Sheets', f'Service account not found at {GOOGLE_SA_PATH}')
            return None

        SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
        credentials = service_account.Credentials.from_service_account_file(
            GOOGLE_SA_PATH, scopes=SCOPES
        )
        _sheets_service = build('sheets', 'v4', credentials=credentials)
        return _sheets_service
    except Exception as e:
        log_error('Sheets', 'Init error', e)
        return None


def _normalize_name(name):
    """Normalize name for matching: remove accents, 'Dra.', 'Dr.', lowercase, strip"""
    if not name:
        return ''
    # Remove Dra./Dr. prefix
    n = re.sub(r'^(Dra?\.?\s*)', '', name.strip(), flags=re.IGNORECASE)
    # Remove accents
    n = unicodedata.normalize('NFD', n)
    n = ''.join(c for c in n if unicodedata.category(c) != 'Mn')
    return n.lower().strip()


def _name_tokens(name):
    """Get set of name tokens for fuzzy matching"""
    return set(_normalize_name(name).split())


def _match_name(sheet_name, mentorados):
    """Match a sheet name to a mentorado. Returns mentorado dict or None."""
    norm = _normalize_name(sheet_name)
    if not norm:
        return None

    # Exact normalized match
    for m in mentorados:
        if _normalize_name(m['nome']) == norm:
            return m

    # Token overlap: at least 2 tokens in common, or all tokens of shorter name match
    sheet_tokens = _name_tokens(sheet_name)
    if len(sheet_tokens) < 1:
        return None

    best_match = None
    best_score = 0
    for m in mentorados:
        m_tokens = _name_tokens(m['nome'])
        overlap = sheet_tokens & m_tokens
        if len(overlap) >= 2 or (len(overlap) >= 1 and len(overlap) == min(len(sheet_tokens), len(m_tokens))):
            score = len(overlap) / max(len(sheet_tokens | m_tokens), 1)
            if score > best_score:
                best_score = score
                best_match = m

    return best_match if best_score >= 0.4 else None


def read_payments_sheet():
    """Read payments sheet and return list of dicts (one per row)"""
    service = get_sheets_service()
    if not service:
        return []

    try:
        result = service.spreadsheets().values().get(
            spreadsheetId=PAYMENTS_SHEET_ID,
            range=f"'{PAYMENTS_TAB}'"
        ).execute()
        rows = result.get('values', [])
        if len(rows) < 2:
            return []

        headers = [h.strip().lower() for h in rows[0]]
        data = []
        for row in rows[1:]:
            d = {}
            for i, h in enumerate(headers):
                d[h] = row[i].strip() if i < len(row) and row[i] else ''
            if d.get('nome') or d.get('mentorado') or d.get('mentorada'):
                data.append(d)
        log_info('Sheets', f'Read {len(data)} rows from payments sheet')
        return data
    except Exception as e:
        log_error('Sheets', 'Error reading payments sheet', e)
        return []


def read_contracts_sheet():
    """Read contracts sheet and return list of dicts (one per row)"""
    service = get_sheets_service()
    if not service:
        return []

    try:
        result = service.spreadsheets().values().get(
            spreadsheetId=CONTRACTS_SHEET_ID,
            range=f"'{CONTRACTS_TAB}'"
        ).execute()
        rows = result.get('values', [])
        if len(rows) < 2:
            return []

        headers = [h.strip().lower() for h in rows[0]]
        data = []
        for row in rows[1:]:
            d = {}
            for i, h in enumerate(headers):
                d[h] = row[i].strip() if i < len(row) and row[i] else ''
            if d.get('nome') or d.get('mentorado') or d.get('mentorada'):
                data.append(d)
        log_info('Sheets', f'Read {len(data)} rows from contracts sheet')
        return data
    except Exception as e:
        log_error('Sheets', 'Error reading contracts sheet', e)
        return []


def _parse_status_financeiro(row):
    """Parse financial status from a payments row"""
    # Look for common column names
    for key in ('status', 'status financeiro', 'status_financeiro', 'situação', 'situacao'):
        val = row.get(key, '').lower().strip()
        if val:
            if any(w in val for w in ('atrasa', 'inadimpl', 'pendente', 'devendo')):
                return 'atrasado'
            if any(w in val for w in ('quita', 'pago', 'encerrad')):
                return 'quitado'
            if any(w in val for w in ('dia', 'ok', 'regular', 'ativ')):
                return 'em_dia'
    return None


def _parse_dia_pagamento(row):
    """Parse payment day from a payments row"""
    for key in ('dia', 'dia pagamento', 'dia_pagamento', 'vencimento', 'dia vencimento'):
        val = row.get(key, '').strip()
        if val:
            # Extract first number found
            match = re.search(r'(\d{1,2})', val)
            if match:
                day = int(match.group(1))
                if 1 <= day <= 31:
                    return day
    return None


def _parse_contrato(row):
    """Parse contract status from a contracts row"""
    # Column M is typically index 12 (0-based), but we use headers
    for key in ('contrato', 'contrato assinado', 'contrato_assinado', 'status contrato'):
        val = row.get(key, '').lower().strip()
        if val:
            if any(w in val for w in ('sim', 'yes', 'assinado', 'ok', 'true', '1')):
                return True
            if any(w in val for w in ('não', 'nao', 'no', 'false', '0', 'pendente', 'falta')):
                return False
    return None


def sync_sheets_to_supabase():
    """Sync Google Sheets data to Supabase mentorados table"""
    global _sheets_last_sync, _sheets_last_result

    log_info('Sheets', 'Starting sync...')
    start_time = time.time()

    # Fetch mentorados from Supabase
    mentorados = supabase_request('GET', 'mentorados?select=id,nome&ativo=eq.true&cohort=not.eq.tese&order=nome')
    if isinstance(mentorados, dict) and 'error' in mentorados:
        log_error('Sheets', f'Failed to fetch mentorados: {mentorados}')
        _sheets_last_result = {'error': mentorados['error'], 'timestamp': datetime.now().isoformat()}
        return _sheets_last_result

    if not mentorados:
        _sheets_last_result = {'error': 'No mentorados found', 'timestamp': datetime.now().isoformat()}
        return _sheets_last_result

    # Read both sheets
    payments = read_payments_sheet()
    contracts = read_contracts_sheet()

    updated = 0
    unmatched_payments = []
    unmatched_contracts = []
    updates_log = []

    # Process payments sheet
    for row in payments:
        name = row.get('nome') or row.get('mentorado') or row.get('mentorada') or ''
        m = _match_name(name, mentorados)
        if not m:
            if name.strip():
                unmatched_payments.append(name)
            continue

        patch = {}
        status = _parse_status_financeiro(row)
        if status:
            patch['status_financeiro'] = status
        dia = _parse_dia_pagamento(row)
        if dia:
            patch['dia_pagamento'] = dia

        if patch:
            result = supabase_request('PATCH', f"mentorados?id=eq.{m['id']}", patch)
            if not (isinstance(result, dict) and 'error' in result):
                updated += 1
                updates_log.append({'id': m['id'], 'nome': m['nome'], 'fields': patch})

    # Process contracts sheet
    for row in contracts:
        name = row.get('nome') or row.get('mentorado') or row.get('mentorada') or ''
        m = _match_name(name, mentorados)
        if not m:
            if name.strip():
                unmatched_contracts.append(name)
            continue

        contrato = _parse_contrato(row)
        if contrato is not None:
            patch = {'contrato_assinado': contrato}
            result = supabase_request('PATCH', f"mentorados?id=eq.{m['id']}", patch)
            if not (isinstance(result, dict) and 'error' in result):
                updated += 1
                updates_log.append({'id': m['id'], 'nome': m['nome'], 'fields': patch})

    elapsed = round(time.time() - start_time, 2)
    _sheets_last_sync = datetime.now().isoformat()
    _sheets_last_result = {
        'success': True,
        'updated': updated,
        'payments_rows': len(payments),
        'contracts_rows': len(contracts),
        'unmatched_payments': unmatched_payments,
        'unmatched_contracts': unmatched_contracts,
        'updates': updates_log,
        'elapsed_seconds': elapsed,
        'timestamp': _sheets_last_sync,
    }
    log_info('Sheets', f'Sync complete: {updated} updates in {elapsed}s')
    if unmatched_payments:
        log_info('Sheets', f'Unmatched payments: {unmatched_payments}')
    if unmatched_contracts:
        log_info('Sheets', f'Unmatched contracts: {unmatched_contracts}')

    return _sheets_last_result


# ===== SHEETS SYNC SCHEDULER =====
def _sheets_sync_loop():
    """Background thread: sync every 6 hours"""
    time.sleep(30)  # Initial delay
    while True:
        try:
            sync_sheets_to_supabase()
        except Exception as e:
            log_error('Sheets', 'Scheduler sync failed', e)
        time.sleep(6 * 3600)  # 6 hours


# ===== SUPABASE HELPERS =====
def supabase_request(method, path, body=None, _retries=3, _backoff=1.0):
    """Make a request to Supabase REST API with retry logic and connection pooling"""
    key = SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY
    if not key:
        return {'error': 'Supabase key not configured'}

    headers = {
        'apikey': key,
        'Authorization': f'Bearer {key}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
    }
    data = json.dumps(body).encode() if body else None
    url = f'/rest/v1/{path}'
    last_error = None

    for attempt in range(_retries):
        try:
            with _supa_lock:
                conn = _get_supa_conn()
                conn.request(method, url, body=data, headers=headers)
                resp = conn.getresponse()
                resp_body = resp.read()
                status = resp.status

            if status in (200, 201):
                return json.loads(resp_body) if resp_body else {}

            elif status in (503, 429, 500, 502, 504):
                last_error = {'error': f'Supabase {status}: {resp_body.decode()}'}
                if attempt < _retries - 1:
                    wait = _backoff * (2 ** attempt)
                    log_info('Supabase', f'Erro {status}, tentativa {attempt+1}/{_retries}, aguardando {wait}s...')
                    time.sleep(wait)
                    with _supa_lock:
                        _reset_supa_conn()
                    continue
            else:
                return {'error': f'Supabase {status}: {resp_body.decode()}'}

        except (http.client.RemoteDisconnected, ConnectionResetError,
                BrokenPipeError, OSError, http.client.CannotSendRequest) as e:
            last_error = {'error': str(e)}
            log_info('Supabase', f'Erro de conexão na tentativa {attempt+1}/{_retries}: {e}')
            with _supa_lock:
                _reset_supa_conn()
            if attempt < _retries - 1:
                wait = _backoff * (2 ** attempt)
                time.sleep(wait)
                continue
        except Exception as e:
            log_error('Supabase', 'Erro inesperado', e)
            return {'error': str(e)}

    log_error('Supabase', f'Todas as {_retries} tentativas falharam', None)
    return last_error or {'error': 'Max retries exceeded'}


def get_mentees_with_email():
    """Fetch mentorados with email from Supabase"""
    return supabase_request('GET', 'mentorados?select=id,nome,email,instagram,fase_jornada,cohort&email=not.is.null&order=nome')


def insert_scheduled_call(data):
    """Insert a call into calls_mentoria"""
    return supabase_request('POST', 'calls_mentoria', data)


# ===== CUSTOM HTTP SERVER (fix SO_REUSEADDR) =====
class ReuseAddrHTTPServer(http.server.HTTPServer):
    allow_reuse_address = True


# ===== HTTP HANDLER =====
class ProxyHandler(http.server.SimpleHTTPRequestHandler):

    def _read_body(self):
        length = int(self.headers.get('Content-Length', 0))
        return self.rfile.read(length) if length > 0 else b''

    def _send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False, default=str).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Content-Length', len(body))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, apikey, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        self.end_headers()

    def do_GET(self):
        if self.path == '/api/auth/me':
            self._handle_auth_me()
        elif self.path.startswith('/api/evolution/'):
            self._proxy_evolution('GET')
        elif self.path == '/api/mentees':
            self._handle_get_mentees()
        elif self.path.startswith('/api/calendar/events'):
            self._handle_list_events()
        elif self.path == '/api/calls/upcoming':
            self._handle_upcoming_calls()
        elif self.path.startswith('/api/media/presign'):
            self._handle_media_presign()
        elif self.path.startswith('/api/media/stream'):
            self._handle_media_stream()
        elif self.path == '/api/evolution/instance-uuid':
            self._handle_instance_uuid()
        elif self.path == '/api/sheets/status':
            self._handle_sheets_status()
        elif self.path.startswith('/api/financial/logs/'):
            self._handle_financial_get_logs()
        elif self.path == '/api/health':
            self._send_json({
                'status': 'ok',
                'zoom_configured': bool(ZOOM_ACCOUNT_ID and ZOOM_CLIENT_ID),
                'gcal_configured': os.path.exists(GOOGLE_SA_PATH),
                'supabase_configured': bool(SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY),
                'sheets_configured': get_sheets_service() is not None,
            })
        else:
            super().do_GET()

    def end_headers(self):
        # Disable browser cache for JS/HTML/CSS files
        if hasattr(self, 'path') and any(ext in self.path for ext in ('.js', '.html', '.css', '.jpg', '.png')):
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
        super().end_headers()

    def do_POST(self):
        if self.path == '/api/auth/register':
            self._handle_auth_register()
        elif self.path == '/api/auth/login':
            self._handle_auth_login()
        elif self.path == '/api/auth/refresh':
            self._handle_auth_refresh()
        elif self.path == '/api/auth/reset-password':
            self._handle_auth_reset_password()
        elif self.path == '/api/auth/change-password':
            self._handle_auth_change_password()
        elif self.path.startswith('/api/evolution/'):
            self._proxy_evolution('POST')
        elif self.path == '/api/schedule-call':
            self._handle_schedule_call()
        elif self.path == '/api/zoom/create-meeting':
            self._handle_create_zoom_meeting()
        elif self.path == '/api/calendar/create-event':
            self._handle_create_calendar_event()
        elif self.path == '/api/sheets/sync':
            self._handle_sheets_sync()
        elif self.path == '/api/ds/update-stage':
            self._handle_ds_update_stage()
        elif self.path == '/api/financial/update-status':
            self._handle_financial_update_status()
        elif self.path == '/api/financial/add-note':
            self._handle_financial_add_note()
        else:
            self._send_json({'error': 'Not found'}, 404)

    def do_PUT(self):
        if self.path.startswith('/api/evolution/'):
            self._proxy_evolution('PUT')
        else:
            self._send_json({'error': 'Not found'}, 404)

    def do_DELETE(self):
        if self.path.startswith('/api/evolution/'):
            self._proxy_evolution('DELETE')
        else:
            self._send_json({'error': 'Not found'}, 404)

    # ===== SCHEDULE CALL (main orchestrator) =====
    def _handle_schedule_call(self):
        """
        Full scheduling flow:
        1. Create Zoom meeting
        2. Create Google Calendar event with Zoom link
        3. Store in Supabase calls_mentoria
        """
        try:
            body = json.loads(self._read_body())
        except Exception:
            self._send_json({'error': 'Invalid JSON'}, 400)
            return

        mentorado_nome = body.get('mentorado', '')
        mentorado_id = body.get('mentorado_id', '')
        email = body.get('email', '')
        tipo = body.get('tipo', 'acompanhamento')
        data = body.get('data', '')  # YYYY-MM-DD
        horario = body.get('horario', '10:00')  # HH:MM
        duracao = body.get('duracao', 60)
        notas = body.get('notas', '')

        if not mentorado_nome or not data:
            self._send_json({'error': 'mentorado and data are required'}, 400)
            return

        # Build datetime
        start_dt = f'{data}T{horario}:00'
        end_dt_obj = datetime.fromisoformat(start_dt) + timedelta(minutes=duracao)
        end_dt = end_dt_obj.isoformat()

        topic = f'Call {tipo.title()} — {mentorado_nome}'
        result = {'mentorado': mentorado_nome, 'data': data, 'horario': horario, 'tipo': tipo}

        # Step 1: Create Zoom meeting
        zoom_result = create_zoom_meeting(
            topic=topic,
            start_time=start_dt,
            duration=duracao,
            invitees=[email] if email else None
        )
        if zoom_result.get('join_url'):
            result['zoom'] = zoom_result
            zoom_url = zoom_result['join_url']
        else:
            result['zoom'] = zoom_result  # May have error
            zoom_url = ''
            print(f'[Schedule] Zoom creation failed: {zoom_result}')

        # Step 2: Create Google Calendar event
        description = f'Tipo: {tipo}\n'
        if notas:
            description += f'Notas: {notas}\n'
        if zoom_url:
            description += f'\nZoom: {zoom_url}\n'

        attendees = []
        if email:
            attendees.append(email)

        gcal_result = create_calendar_event(
            summary=topic,
            start_iso=start_dt,
            end_iso=end_dt,
            description=description,
            attendees=attendees,
            location=zoom_url
        )
        result['calendar'] = gcal_result

        # Step 3: Store in Supabase
        if mentorado_id:
            # Map tipo to valid tipo_call values: diagnostico, planejamento, acompanhamento, fechamento
            tipo_call_map = {
                'acompanhamento': 'acompanhamento',
                'conselho': 'acompanhamento',
                'qa': 'acompanhamento',
                'onboarding': 'diagnostico',
                'estrategia': 'planejamento',
            }
            call_data = {
                'mentorado_id': int(mentorado_id),
                'data_call': f'{data}T{horario}:00+00:00',
                'tipo': tipo,
                'tipo_call': tipo_call_map.get(tipo, 'acompanhamento'),
                'duracao_minutos': duracao,
                'zoom_meeting_id': str(zoom_result.get('meeting_id', '')),
                'zoom_topic': topic,
                'status': 'processando',
                'observacoes_equipe': notas or None,
                'link_gravacao': zoom_url or None,
            }
            supa_result = insert_scheduled_call(call_data)
            result['supabase'] = supa_result if not isinstance(supa_result, list) else {'inserted': True, 'id': supa_result[0].get('id') if supa_result else None}

        self._send_json(result)
        print(f'[Schedule] Call scheduled: {topic} on {data} {horario}')

    # ===== INDIVIDUAL ENDPOINTS =====
    def _handle_create_zoom_meeting(self):
        try:
            body = json.loads(self._read_body())
            result = create_zoom_meeting(
                topic=body.get('topic', 'Call Mentoria'),
                start_time=body.get('start_time', ''),
                duration=body.get('duration', 60),
                invitees=body.get('invitees', [])
            )
            self._send_json(result)
        except Exception as e:
            self._send_json({'error': str(e)}, 500)

    def _handle_create_calendar_event(self):
        try:
            body = json.loads(self._read_body())
            result = create_calendar_event(
                summary=body.get('summary', ''),
                start_iso=body.get('start', ''),
                end_iso=body.get('end', ''),
                description=body.get('description', ''),
                attendees=body.get('attendees', []),
                location=body.get('location', '')
            )
            self._send_json(result)
        except Exception as e:
            self._send_json({'error': str(e)}, 500)

    # ===== MEDIA PRESIGN (S3) =====
    def _handle_media_presign(self):
        """Generate presigned URL for Hetzner S3 media"""
        params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        key = params.get('key', [''])[0]

        if not key:
            self._send_json({'error': 'key parameter required'}, 400)
            return

        try:
            url = generate_presigned_url(key)
            # FULL DEBUG: log the complete URL
            print(f'[Presign] Key: {key}')
            print(f'[Presign] Generated URL length: {len(url)}')
            print(f'[Presign] Full URL: {url}')
            self._send_json({'url': url, 'bucket': S3_BUCKET, 'endpoint': S3_ENDPOINT})
        except Exception as e:
            print(f'[S3] Presign error: {e}')
            self._send_json({'error': str(e)}, 500)

    def _handle_media_stream(self):
        """Stream media directly from Hetzner S3 (proxy to avoid CORS)"""
        params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        key = params.get('key', [''])[0]

        if not key:
            self._send_json({'error': 'key parameter required'}, 400)
            return

        try:
            # Try with the key as provided
            url = generate_presigned_url(key)
            print(f'[Stream] Attempting to stream S3 key: {key}')

            req = urllib.request.Request(url)
            response = urllib.request.urlopen(req, timeout=30)

            # Get content type and size
            content_type = response.headers.get('Content-Type', 'application/octet-stream')
            content_length = response.headers.get('Content-Length')

            # Send response
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            if content_length:
                self.send_header('Content-Length', content_length)
            # Allow CORS from frontend
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'public, max-age=3600')
            self.end_headers()

            # Stream the file
            chunk_size = 8192
            while True:
                chunk = response.read(chunk_size)
                if not chunk:
                    break
                self.wfile.write(chunk)

            print(f'[Stream] Successfully streamed {key}')

        except urllib.error.HTTPError as he:
            # If 403/404, try to find the correct instanceId
            if he.code in [403, 404]:
                print(f'[Stream] Key not found: {key}, status {he.code}. Attempting to discover correct UUID...')
                try:
                    # Extract parts from original key
                    parts = key.split('/')
                    if len(parts) >= 3:
                        chat_id = parts[1]  # The wrong instanceId
                        remote_jid = parts[2]  # The chatId
                        message_type = parts[3] if len(parts) > 3 else 'audioMessage'

                        # Try to find correct instanceId by listing bucket
                        # Build list URL
                        list_url = f'https://{S3_ENDPOINT}/{S3_BUCKET}/?prefix=evolution-api/&delimiter=/'
                        presigned_list = generate_presigned_url('evolution-api/')

                        # For now, just respond with helpful debug info
                        print(f'[Stream] Parts: chat_id={chat_id}, remote_jid={remote_jid}, message_type={message_type}')
                        self._send_json({'error': f'File not found at {key}. May need UUID discovery.'}, 404)
                        return
                except Exception as e2:
                    print(f'[Stream] Discovery error: {e2}')

            self._send_json({'error': f'HTTP {he.code}: {he.reason}'}, he.code)

        except Exception as e:
            print(f'[Stream] Error: {e}')
            self._send_json({'error': str(e)}, 500)

    def _handle_instance_uuid(self):
        """Get the actual UUID of the Evolution instance from S3 bucket"""
        try:
            # List objects in bucket to find the instanceId pattern
            # S3 path is: evolution-api/{UUID}/{chatId}/{messageType}
            # We can extract the UUID from the first match
            presigned_url = generate_presigned_url('evolution-api/')
            print(f'[Instance UUID] Fetching bucket list from: {presigned_url}')

            # For now, return hardcoded based on what we found
            # TODO: Implement actual bucket listing via S3 API
            self._send_json({
                'instance': EVOLUTION_CONFIG['INSTANCE'],
                'note': 'UUID discovery not yet automated. Please check S3 bucket manually.',
                's3_bucket': S3_BUCKET,
                's3_endpoint': S3_ENDPOINT,
            })

        except Exception as e:
            print(f'[Instance UUID] Error: {e}')
            self._send_json({'error': str(e)}, 500)

    def _handle_get_mentees(self):
        result = get_mentees_with_email()
        self._send_json(result if isinstance(result, list) else [result])

    def _handle_list_events(self):
        result = list_calendar_events()
        self._send_json(result)

    def _handle_upcoming_calls(self):
        # Get ALL calls (not just scheduled), ordered by date DESC to show latest first
        result = supabase_request('GET', "calls_mentoria?select=*&order=data_call.desc&limit=500")
        self._send_json(result if isinstance(result, list) else [result] if result else [])

    # ===== EVOLUTION PROXY =====
    def _proxy_evolution(self, method):
        target_path = self.path[len('/api/evolution'):]
        if '..' in target_path:
            self._send_json({'error': 'Invalid path'}, 400)
            return
        url = f'{EVOLUTION_BASE}{target_path}'
        body = self._read_body() if method in ('POST', 'PUT') else None

        req = urllib.request.Request(url, data=body, method=method)
        req.add_header('Content-Type', 'application/json')
        req.add_header('apikey', EVOLUTION_API_KEY)

        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                resp_body = resp.read()
                self.send_response(resp.status)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Length', len(resp_body))
                self.end_headers()
                self.wfile.write(resp_body)
        except urllib.error.HTTPError as e:
            error_body = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Length', len(error_body))
            self.end_headers()
            self.wfile.write(error_body)
        except Exception as e:
            error_msg = json.dumps({'error': str(e)}).encode()
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Length', len(error_msg))
            self.end_headers()
            self.wfile.write(error_msg)

    # ===== SHEETS HANDLERS =====
    def _handle_sheets_status(self):
        self._send_json({
            'sheets_configured': get_sheets_service() is not None,
            'last_sync': _sheets_last_sync,
            'last_result': _sheets_last_result,
            'payments_sheet': PAYMENTS_SHEET_ID,
            'contracts_sheet': CONTRACTS_SHEET_ID,
        })

    # ===== DOSSIÊ PRODUCTION SYSTEM =====

    # CR-C1: Role-based auth — only team members can mutate pipeline
    DS_ALLOWED_ROLES = ('admin', 'team')

    def _ds_check_auth(self):
        """Verify JWT token + role for DS endpoints. Returns payload or None (sends 401/403)."""
        auth_header = self.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            self._send_json({'error': 'Missing or invalid token'}, 401)
            return None
        payload = verify_jwt_token(auth_header[7:])
        if not payload or payload.get('type') == 'refresh':
            self._send_json({'error': 'Invalid or expired token'}, 401)
            return None
        # Check role — require explicit role in JWT, no fallback
        role = payload.get('role')
        if not role or role not in self.DS_ALLOWED_ROLES:
            self._send_json({'error': 'Insufficient permissions — JWT must contain role (admin or team)'}, 403)
            return None
        return payload

    # CR-M1: State machine — valid stage transitions
    DS_VALID_TRANSITIONS = {
        'pendente': ('producao_ia',),
        'producao_ia': ('revisao_mariza',),
        'revisao_mariza': ('revisao_kaique', 'producao_ia'),  # can send back
        'revisao_kaique': ('revisao_queila', 'revisao_mariza'),  # can send back
        'revisao_queila': ('aprovado', 'revisao_kaique'),  # can send back
        'aprovado': ('enviado',),
        'enviado': ('finalizado', 'ajustes'),
        'finalizado': (),
        'ajustes': ('revisao_mariza',),
    }

    def _handle_ds_update_stage(self):
        """Update ds_documentos stage and create ds_eventos audit trail.
        POST /api/ds/update-stage
        Body: { mentorado_slug: str, dossie_tipo: str, estagio: str }
        Requires: Bearer JWT token with role in DS_ALLOWED_ROLES
        Returns: 200 {ok, mentorado, tipo, estagio, responsavel}
        Errors: 400 (validation), 401 (auth), 403 (role), 404 (not found), 409 (invalid transition), 500 (server)
        """
        auth = self._ds_check_auth()
        if not auth:
            return

        try:
            body = json.loads(self._read_body())
        except Exception:
            self._send_json({'error': 'Invalid JSON'}, 400)
            return

        slug = body.get('mentorado_slug', '')
        tipo = body.get('dossie_tipo', '')
        estagio = body.get('estagio', '')

        if not slug or not tipo or not estagio:
            self._send_json({'error': 'mentorado_slug, dossie_tipo, and estagio are required'}, 400)
            return

        valid_tipos = ('oferta', 'funil', 'conteudo')
        if tipo not in valid_tipos:
            self._send_json({'error': f'dossie_tipo must be one of {valid_tipos}'}, 400)
            return

        valid_estagios = tuple(self.DS_VALID_TRANSITIONS.keys())
        if estagio not in valid_estagios:
            self._send_json({'error': f'estagio must be one of {valid_estagios}'}, 400)
            return

        # Sanitize slug: only allow alphanumeric, spaces, hyphens, accented chars
        safe_slug = re.sub(r'[^a-zA-ZÀ-ÿ0-9\s\-]', '', slug).strip()
        if not safe_slug or len(safe_slug) < 2:
            self._send_json({'error': 'Invalid mentorado_slug'}, 400)
            return

        # Find mentorado (slug is sanitized, safe for ILIKE)
        mentee = supabase_request('GET',
            f'mentorados?nome=ilike.*{urllib.parse.quote(safe_slug)}*&select=id,nome&limit=5')
        if isinstance(mentee, dict) and mentee.get('error'):
            self._send_json({'error': f'Database error looking up mentorado: {mentee["error"]}'}, 500)
            return
        if not mentee:
            self._send_json({'error': f'Mentorado not found: {safe_slug}'}, 404)
            return
        if len(mentee) > 1:
            names = [m['nome'] for m in mentee]
            self._send_json({'error': f'Ambiguous slug — {len(mentee)} matches: {names}. Be more specific.'}, 400)
            return
        mentorado_id = mentee[0]['id']
        mentorado_nome = mentee[0]['nome']

        # CR-M2: Find document via active producao (not cancelled/finalizado)
        docs = supabase_request('GET',
            f'ds_documentos?mentorado_id=eq.{mentorado_id}&tipo=eq.{tipo}'
            f'&producao_id=not.is.null&select=id,producao_id,estagio_atual'
            f'&order=created_at.desc&limit=1')
        if isinstance(docs, dict) and docs.get('error'):
            self._send_json({'error': f'Database error looking up document: {docs["error"]}'}, 500)
            return
        if not docs:
            self._send_json({'error': f'Document not found: {mentorado_nome} / {tipo}'}, 404)
            return
        doc = docs[0]

        # CR-M1: Validate state transition
        current_stage = doc['estagio_atual']
        allowed_next = self.DS_VALID_TRANSITIONS.get(current_stage, ())
        if estagio not in allowed_next:
            self._send_json({
                'error': f'Invalid transition: {current_stage} → {estagio}',
                'allowed': list(allowed_next),
            }, 409)
            return

        # Determine next responsavel
        responsavel_map = {
            'producao_ia': 'Mariza',
            'revisao_mariza': 'Mariza',
            'revisao_kaique': 'Kaique',
            'revisao_queila': 'Queila',
        }
        responsavel = responsavel_map.get(estagio)

        # Update document stage
        update = {'estagio_atual': estagio, 'estagio_desde': datetime.now(timezone.utc).isoformat()}
        if estagio == 'producao_ia':
            update['data_producao_ia'] = datetime.now(timezone.utc).isoformat()
        if responsavel:
            update['responsavel_atual'] = responsavel

        result = supabase_request('PATCH', f'ds_documentos?id=eq.{doc["id"]}', update)
        if isinstance(result, dict) and result.get('error'):
            self._send_json({'error': f'Failed to update document: {result["error"]}'}, 500)
            return

        # Create audit event
        evt_result = supabase_request('POST', 'ds_eventos', {
            'producao_id': doc['producao_id'],
            'documento_id': doc['id'],
            'mentorado_id': mentorado_id,
            'tipo_evento': 'estagio_change',
            'de_valor': current_stage,
            'para_valor': estagio,
            'responsavel': responsavel or 'pipeline-auto',
            'descricao': f'{tipo} → {estagio} (via API)',
        })
        audit_ok = not (isinstance(evt_result, dict) and evt_result.get('error'))
        if not audit_ok:
            log_error('DS', 'Failed to create audit event', evt_result['error'])

        self._send_json({
            'ok': True,
            'mentorado': mentorado_nome,
            'tipo': tipo,
            'estagio': estagio,
            'responsavel': responsavel,
            'audit_event': audit_ok,
        })

    def _handle_sheets_sync(self):
        try:
            result = sync_sheets_to_supabase()
            self._send_json(result)
        except Exception as e:
            log_error('Sheets', 'Manual sync failed', e)
            self._send_json({'error': str(e)}, 500)

    # ===== AUTH HANDLERS =====
    def _handle_auth_register(self):
        """Register new user (Supabase-backed)"""
        try:
            body = json.loads(self._read_body())
            email = body.get('email', '').strip().lower()
            password = body.get('password', '').strip()
            full_name = body.get('fullName', body.get('full_name', '')).strip()

            if not email or not password:
                self._send_json({'error': 'Email and password required'}, 400)
                return

            if len(password) < 6:
                self._send_json({'error': 'Password must be at least 6 characters'}, 400)
                return

            # Check if email already exists
            existing = supabase_request('GET', f'auth_users?email=eq.{email}&select=id')
            if isinstance(existing, list) and len(existing) > 0:
                self._send_json({'error': 'Email already exists'}, 409)
                return

            password_hash = hash_password(password)
            result = supabase_request('POST', 'auth_users', {
                'email': email,
                'password_hash': password_hash,
                'full_name': full_name,
            })

            if isinstance(result, dict) and result.get('error'):
                self._send_json({'error': 'Registration failed'}, 500)
                return

            user = result[0] if isinstance(result, list) else result
            user_id = user.get('id')

            access_token = create_jwt_token(email, user_id)
            refresh_token = create_refresh_token(email, user_id)

            self._send_json({
                'success': True,
                'user': {'id': user_id, 'email': email, 'full_name': full_name},
                'access_token': access_token,
                'refresh_token': refresh_token,
                'expires_in': ACCESS_TOKEN_EXPIRY_MINUTES * 60
            }, 201)
        except Exception as e:
            log_error('AUTH', f'Registration failed: {e}')
            self._send_json({'error': 'Registration failed'}, 500)

    def _handle_auth_me(self):
        """Validate token and return current user data"""
        try:
            auth_header = self.headers.get('Authorization', '')
            if not auth_header.startswith('Bearer '):
                self._send_json({'error': 'Missing or invalid token'}, 401)
                return

            token = auth_header[7:]
            payload = verify_jwt_token(token)
            if not payload or payload.get('type') == 'refresh':
                self._send_json({'error': 'Invalid or expired token'}, 401)
                return

            user_id = payload.get('user_id')
            email = payload.get('email')

            # Fetch fresh user data from DB
            result = supabase_request('GET', f'auth_users?id=eq.{user_id}&select=id,email,full_name')
            if isinstance(result, list) and len(result) > 0:
                self._send_json({'user': result[0]})
            else:
                self._send_json({'user': {'id': user_id, 'email': email}})
        except Exception as e:
            log_error('AUTH', f'Token validation failed: {e}')
            self._send_json({'error': 'Token validation failed'}, 401)

    def _handle_auth_login(self):
        """Login user and issue JWT (Supabase-backed)"""
        try:
            body = json.loads(self._read_body())
            email = body.get('email', '').strip().lower()
            password = body.get('password', '').strip()

            if not email or not password:
                self._send_json({'error': 'Email and password required'}, 400)
                return

            result = supabase_request('GET', f'auth_users?email=eq.{email}&select=id,email,full_name,password_hash')
            if not isinstance(result, list) or len(result) == 0:
                self._send_json({'error': 'Invalid email or password'}, 401)
                return

            row = result[0]
            pw_result = verify_password(password, row['password_hash'])
            if not pw_result:
                self._send_json({'error': 'Invalid email or password'}, 401)
                return

            user_id = row['id']
            db_email = row['email']

            # Lazy migration: upgrade legacy SHA-256 hash to bcrypt
            if pw_result == 'migrate' and _bcrypt:
                new_hash = hash_password(password)
                supabase_request('PATCH', f'auth_users?id=eq.{user_id}', {'password_hash': new_hash})
                print(f'[AUTH] Migrated password hash for user {user_id} to bcrypt')
            full_name = row.get('full_name', '')

            access_token = create_jwt_token(db_email, user_id)
            refresh_token = create_refresh_token(db_email, user_id)

            self._send_json({
                'success': True,
                'user': {'id': user_id, 'email': db_email, 'full_name': full_name},
                'access_token': access_token,
                'refresh_token': refresh_token,
                'expires_in': ACCESS_TOKEN_EXPIRY_MINUTES * 60
            }, 200)
        except Exception as e:
            log_error('AUTH', f'Login failed: {e}')
            self._send_json({'error': 'Login failed'}, 500)

    def _handle_auth_refresh(self):
        """Refresh JWT token"""
        try:
            body = json.loads(self._read_body())
            refresh_token = body.get('refresh_token', '').strip()

            if not refresh_token:
                self._send_json({'error': 'Refresh token required'}, 400)
                return

            payload = verify_jwt_token(refresh_token)
            if not payload or payload.get('type') != 'refresh':
                self._send_json({'error': 'Invalid or expired refresh token'}, 401)
                return

            email = payload.get('email')
            user_id = payload.get('user_id')

            new_access_token = create_jwt_token(email, user_id)
            new_refresh_token = create_refresh_token(email, user_id)

            # Fetch fresh user data
            user_data = supabase_request('GET', f'auth_users?id=eq.{user_id}&select=id,email,full_name')
            user = user_data[0] if isinstance(user_data, list) and len(user_data) > 0 else {'id': user_id, 'email': email}

            self._send_json({
                'success': True,
                'user': user,
                'access_token': new_access_token,
                'refresh_token': new_refresh_token,
                'expires_in': ACCESS_TOKEN_EXPIRY_MINUTES * 60
            }, 200)
        except Exception as e:
            log_error('AUTH', f'Token refresh failed: {e}')
            self._send_json({'error': 'Token refresh failed'}, 500)

    def _handle_auth_change_password(self):
        """Handle password change for logged-in users"""
        try:
            # Verify JWT token
            auth_header = self.headers.get('Authorization', '')
            if not auth_header.startswith('Bearer '):
                self._send_json({'error': 'Token obrigatorio'}, 401)
                return

            token = auth_header[7:]
            payload = verify_jwt_token(token)
            if not payload:
                self._send_json({'error': 'Token invalido ou expirado'}, 401)
                return

            user_id = payload.get('user_id')
            body = json.loads(self._read_body())
            current_password = body.get('current_password', '')
            new_password = body.get('new_password', '')

            if not current_password or not new_password:
                self._send_json({'error': 'Senha atual e nova senha obrigatorias'}, 400)
                return

            if len(new_password) < 6:
                self._send_json({'error': 'Nova senha deve ter no minimo 6 caracteres'}, 400)
                return

            # Get current hash
            result = supabase_request('GET', f'auth_users?id=eq.{user_id}&select=id,password_hash')
            if not isinstance(result, list) or len(result) == 0:
                self._send_json({'error': 'Usuario nao encontrado'}, 404)
                return

            stored_hash = result[0]['password_hash']
            pw_check = verify_password(current_password, stored_hash)
            if not pw_check:
                self._send_json({'error': 'Senha atual incorreta'}, 401)
                return

            # Hash new password with bcrypt
            new_hash = hash_password(new_password)
            supabase_request('PATCH', f'auth_users?id=eq.{user_id}', {'password_hash': new_hash})

            self._send_json({'success': True, 'message': 'Senha alterada com sucesso'}, 200)
        except Exception as e:
            log_error('AUTH', f'Change password error: {e}')
            self._send_json({'error': 'Erro ao alterar senha'}, 500)

    def _handle_auth_reset_password(self):
        """Handle password reset request — returns generic message to prevent email enumeration"""
        try:
            body = json.loads(self._read_body())
            email = body.get('email', '').strip().lower()

            if not email:
                self._send_json({'error': 'Email obrigatorio'}, 400)
                return

            # Check if user exists (but always return same message)
            users = supabase_request('GET', f'auth_users?email=eq.{email}&select=id,email')
            if isinstance(users, list) and len(users) > 0:
                # TODO: Send actual reset email when email service is configured
                log_error('AUTH', f'Password reset requested for: {email} (user found, email not sent — no email service configured)')
            else:
                log_error('AUTH', f'Password reset requested for: {email} (user not found)')

            # Always return success to prevent email enumeration
            self._send_json({
                'success': True,
                'message': 'Se o email existir no sistema, as instrucoes de recuperacao serao enviadas.'
            }, 200)
        except Exception as e:
            log_error('AUTH', f'Reset password error: {e}')
            self._send_json({'error': 'Erro ao processar solicitacao'}, 500)

    # ===== FINANCIAL ENDPOINTS (CFO Payments View) =====

    CFO_ALLOWED_USERS = ['kaique', 'heitor', 'hugo', 'queila', 'lara']
    VALID_FINANCIAL_STATUSES = ['em_dia', 'atrasado', 'quitado', 'pago', 'sem_contrato', 'pendente']

    def _verify_cfo_access(self):
        """Verify JWT and check if user is in CFO allowed list. Returns (user_id, full_name) or None."""
        auth_header = self.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            self._send_json({'error': 'Missing or invalid token'}, 401)
            return None
        token = auth_header[7:]
        payload = verify_jwt_token(token)
        if not payload:
            self._send_json({'error': 'Invalid or expired token'}, 401)
            return None
        user_id = payload.get('user_id')
        # Fetch user full_name to check permission
        result = supabase_request('GET', f'auth_users?id=eq.{user_id}&select=id,full_name')
        if not isinstance(result, list) or len(result) == 0:
            self._send_json({'error': 'User not found'}, 404)
            return None
        full_name = result[0].get('full_name', '')
        if not any(full_name.lower().startswith(u) for u in self.CFO_ALLOWED_USERS):
            self._send_json({'error': 'Access denied: not authorized for financial operations'}, 403)
            return None
        return (user_id, full_name)

    def _handle_financial_update_status(self):
        """POST /api/financial/update-status — Change mentorado payment status"""
        try:
            cfo_user = self._verify_cfo_access()
            if not cfo_user:
                return
            user_id, full_name = cfo_user

            body = json.loads(self._read_body())
            mentorado_id = body.get('mentorado_id')
            new_status = body.get('new_status', '').strip()
            observacao = body.get('observacao', '').strip()

            if not mentorado_id or not new_status:
                self._send_json({'error': 'mentorado_id and new_status required'}, 400)
                return
            if new_status not in self.VALID_FINANCIAL_STATUSES:
                self._send_json({'error': f'Invalid status. Must be one of: {", ".join(self.VALID_FINANCIAL_STATUSES)}'}, 400)
                return

            # Get current status
            current = supabase_request('GET', f'mentorados?id=eq.{mentorado_id}&select=id,status_financeiro,contrato_assinado')
            if not isinstance(current, list) or len(current) == 0:
                self._send_json({'error': 'Mentorado not found'}, 404)
                return
            old_status = current[0].get('status_financeiro', 'em_dia')

            # Update mentorados table
            update_data = {'status_financeiro': new_status}
            if new_status == 'sem_contrato':
                update_data['contrato_assinado'] = False
            elif new_status in ('em_dia', 'quitado', 'pago') and not current[0].get('contrato_assinado'):
                update_data['contrato_assinado'] = True

            result = supabase_request('PATCH', f'mentorados?id=eq.{mentorado_id}', update_data)
            if isinstance(result, dict) and result.get('error'):
                self._send_json({'error': f'Failed to update: {result["error"]}'}, 500)
                return

            # Insert audit log
            log_entry = {
                'mentorado_id': mentorado_id,
                'old_status': old_status,
                'new_status': new_status,
                'action_type': 'status_change',
                'observacao': observacao or None,
                'changed_by': full_name,
            }
            supabase_request('POST', 'god_financial_logs', log_entry)

            self._send_json({'success': True, 'old_status': old_status, 'new_status': new_status})
        except Exception as e:
            log_error('FINANCIAL', f'Update status failed: {e}')
            self._send_json({'error': 'Update status failed'}, 500)

    def _handle_financial_add_note(self):
        """POST /api/financial/add-note — Add financial observation for a mentorado"""
        try:
            cfo_user = self._verify_cfo_access()
            if not cfo_user:
                return
            user_id, full_name = cfo_user

            body = json.loads(self._read_body())
            mentorado_id = body.get('mentorado_id')
            observacao = body.get('observacao', '').strip()

            if not mentorado_id or not observacao:
                self._send_json({'error': 'mentorado_id and observacao required'}, 400)
                return

            log_entry = {
                'mentorado_id': mentorado_id,
                'action_type': 'note',
                'observacao': observacao,
                'changed_by': full_name,
            }
            result = supabase_request('POST', 'god_financial_logs', log_entry)
            if isinstance(result, dict) and result.get('error'):
                self._send_json({'error': f'Failed to add note: {result["error"]}'}, 500)
                return

            self._send_json({'success': True})
        except Exception as e:
            log_error('FINANCIAL', f'Add note failed: {e}')
            self._send_json({'error': 'Add note failed'}, 500)

    def _handle_financial_get_logs(self):
        """GET /api/financial/logs/<mentorado_id> — Get financial action logs"""
        try:
            cfo_user = self._verify_cfo_access()
            if not cfo_user:
                return

            # Extract mentorado_id from path: /api/financial/logs/123
            parts = self.path.split('/')
            if len(parts) < 5:
                self._send_json({'error': 'mentorado_id required in path'}, 400)
                return
            mentorado_id = parts[4].split('?')[0]  # strip query params

            result = supabase_request('GET', f'god_financial_logs?mentorado_id=eq.{mentorado_id}&order=created_at.desc&limit=50')
            if isinstance(result, dict) and result.get('error'):
                self._send_json({'error': result['error']}, 500)
                return

            self._send_json({'logs': result if isinstance(result, list) else []})
        except Exception as e:
            log_error('FINANCIAL', f'Get logs failed: {e}')
            self._send_json({'error': 'Get logs failed'}, 500)

    def log_message(self, format, *args):
        path = str(args[0]) if args else ''
        if '/api/' in path:
            print(f'[API] {args[0]}')


if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    # Print status
    print(f'[Spalla] Server running at http://localhost:{PORT}')
    print(f'[Spalla] Zoom:     {"✓ configured" if ZOOM_ACCOUNT_ID else "✗ set ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET"}')
    print(f'[Spalla] GCal:     {"✓ service account found" if os.path.exists(GOOGLE_SA_PATH) else "✗ no service account"}')
    print(f'[Spalla] Supabase: {"✓ configured" if SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY else "✗ set SUPABASE_SERVICE_KEY"}')
    print(f'[Spalla] Evolution: {"✓ configured" if EVOLUTION_API_KEY else "✗ set EVOLUTION_API_KEY"}')
    print(f'[Spalla] JWT:      {"✓ secret from env" if os.environ.get("JWT_SECRET") else "⚠ ephemeral key (set JWT_SECRET)"}')
    print(f'[Spalla] Bcrypt:   {"✓ installed" if _bcrypt else "⚠ not installed (using SHA-256)"}')
    print(f'[Spalla] Proxy:    /api/evolution/*')
    print(f'[Spalla] Sheets:   {"✓ service account found" if os.path.exists(GOOGLE_SA_PATH) else "✗ no service account"}')
    print(f'[Spalla] Endpoints:')
    print(f'  POST /api/schedule-call    — Full scheduling (Zoom + Calendar + DB)')
    print(f'  POST /api/zoom/create-meeting')
    print(f'  POST /api/calendar/create-event')
    print(f'  POST /api/sheets/sync      — Manual Google Sheets sync')
    print(f'  GET  /api/sheets/status    — Sheets sync status')
    print(f'  GET  /api/mentees          — Mentorados with email')
    print(f'  GET  /api/calendar/events   — Upcoming calendar events')
    print(f'  GET  /api/calls/upcoming    — Scheduled calls from DB')
    print(f'  GET  /api/health')

    # Start sheets sync background thread
    sync_thread = threading.Thread(target=_sheets_sync_loop, daemon=True)
    sync_thread.start()
    print(f'[Spalla] Sheets sync: background thread started (every 6h, first in 30s)')

    server = ReuseAddrHTTPServer(('', PORT), ProxyHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[Spalla] Server stopped')
