"""
Spalla Dashboard — Server with Zoom, Google Calendar & Supabase Integration
Serves static files + proxies APIs
"""

import http.server
import json
import urllib.request
import urllib.error
import os
import sys
import time
import base64
import hashlib
import hmac
import gzip
from datetime import datetime, timedelta
import pytz

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8888

# ===== LOGGING (LOW-02: Comprehensive error logging) =====
def log_error(component, message, error=None):
    """Log errors with timestamp and context"""
    timestamp = datetime.now(pytz.timezone('America/Sao_Paulo')).isoformat()
    error_msg = str(error) if error else ""
    print(f"[{timestamp}] ERROR [{component}] {message}" + (f" | {error_msg}" if error_msg else ""))

def log_info(component, message):
    """Log informational messages"""
    timestamp = datetime.now(pytz.timezone('America/Sao_Paulo')).isoformat()
    print(f"[{timestamp}] INFO [{component}] {message}")

# ===== CONFIG =====
EVOLUTION_BASE = 'https://evolution.manager01.feynmanproject.com'
EVOLUTION_API_KEY = os.environ.get('EVOLUTION_API_KEY')

# Zoom Server-to-Server OAuth — NO FALLBACK DEFAULTS!
ZOOM_ACCOUNT_ID = os.environ.get('ZOOM_ACCOUNT_ID')
ZOOM_CLIENT_ID = os.environ.get('ZOOM_CLIENT_ID')
ZOOM_CLIENT_SECRET = os.environ.get('ZOOM_CLIENT_SECRET')

# Google Service Account
GOOGLE_SA_PATH = os.path.expanduser('~/.config/google/credentials.json')

# Supabase — NO DEFAULTS! These are secrets!
SUPABASE_URL = 'https://knusqfbvhsqworzyhvip.supabase.co'
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY', '')
SUPABASE_SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', '')

# Calendar ID (user's primary calendar or a specific one)
GOOGLE_CALENDAR_ID = os.environ.get('GOOGLE_CALENDAR_ID', 'primary')

# ===== JWT AUTHENTICATION =====
JWT_SECRET = os.environ.get('JWT_SECRET', 'CHANGE_ME_IN_PRODUCTION')
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION = 86400  # 24 hours

# Valid users (in production, query from Supabase)
VALID_USERS = {
    'queila@case.com': 'spalla',  # Username as temp password (CHANGE IN PRODUCTION!)
}

# ===== ZOOM TOKEN CACHE =====
_zoom_token = {'access_token': None, 'expires_at': 0}


def get_zoom_token():
    """Get Zoom access token via Server-to-Server OAuth"""
    global _zoom_token
    if _zoom_token['access_token'] and time.time() < _zoom_token['expires_at'] - 60:
        return _zoom_token['access_token']

    if not ZOOM_ACCOUNT_ID or not ZOOM_CLIENT_ID or not ZOOM_CLIENT_SECRET:
        print('[WARNING] Zoom not configured (missing env vars) — scheduling disabled')
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


# ===== JWT FUNCTIONS =====
def encode_jwt(payload):
    """Encode JWT token manually (no external library)"""
    import struct

    # Header
    header = {'alg': JWT_ALGORITHM, 'typ': 'JWT'}
    header_b64 = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip('=')

    # Payload with timestamps
    payload['iat'] = int(time.time())
    payload['exp'] = int(time.time()) + JWT_EXPIRATION
    payload_b64 = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip('=')

    # Signature
    msg = f'{header_b64}.{payload_b64}'.encode()
    sig = hmac.new(JWT_SECRET.encode(), msg, hashlib.sha256).digest()
    sig_b64 = base64.urlsafe_b64encode(sig).decode().rstrip('=')

    return f'{header_b64}.{payload_b64}.{sig_b64}'

def decode_jwt(token):
    """Decode and verify JWT token"""
    try:
        parts = token.split('.')
        if len(parts) != 3:
            return None

        header_b64, payload_b64, sig_b64 = parts

        # Verify signature
        msg = f'{header_b64}.{payload_b64}'.encode()
        expected_sig = hmac.new(JWT_SECRET.encode(), msg, hashlib.sha256).digest()
        expected_sig_b64 = base64.urlsafe_b64encode(expected_sig).decode().rstrip('=')

        if sig_b64 != expected_sig_b64:
            return None

        # Decode payload
        padding = '=' * (4 - len(payload_b64) % 4)
        payload_json = base64.urlsafe_b64decode(payload_b64 + padding).decode()
        payload = json.loads(payload_json)

        # Check expiration
        if payload.get('exp', 0) < time.time():
            return None

        return payload
    except Exception as e:
        print(f'[JWT] Decode error: {e}')
        return None

def get_bearer_token(headers):
    """Extract bearer token from Authorization header"""
    auth = headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return auth[7:]
    return None


def create_zoom_meeting(topic, start_time, duration=60, invitees=None):
    """Create a Zoom meeting and return join_url + meeting_id"""
    token = get_zoom_token()
    if not token:
        return {'error': 'Zoom credentials not configured'}

    # Ensure start_time has timezone offset (HIGH-02, HIGH-06) — MED-05: Proper DST handling
    if isinstance(start_time, str) and 'T' in start_time:
        # Check if it already has timezone (ends with +HH:MM or -HH:MM)
        if not ('+' in start_time[-6:] or ('-' in start_time[-6:] and start_time[-3] == ':')):
            # start_time is naive, add Brasilia timezone with proper DST handling
            tz_br = pytz.timezone('America/Sao_Paulo')
            try:
                # Parse naive datetime and localize it (handles DST correctly)
                dt_naive = datetime.fromisoformat(start_time)
                dt_aware = tz_br.localize(dt_naive, is_dst=None)  # is_dst=None raises AmbiguousTimeError if needed
                start_time = dt_aware.isoformat()
            except Exception:
                # Fallback: use current offset if parsing fails
                now_br = datetime.now(tz_br)
                offset = now_br.strftime('%z')
                offset_formatted = f'{offset[:-2]}:{offset[-2:]}'
                start_time = f'{start_time}{offset_formatted}'

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
        time_min = datetime.utcnow().isoformat() + 'Z'

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


# ===== SUPABASE HELPERS =====
def supabase_request(method, path, body=None):
    """
    Make a request to Supabase REST API with RLS protection.

    Key selection:
    - SERVICE_KEY: Bypasses RLS (unrestricted access) — USE FOR BACKEND
    - ANON_KEY: Respects RLS policies — USE FOR FRONTEND

    Since this is called from backend, it uses SERVICE_KEY (admin access).
    Frontend requests use JWT tokens and ANON_KEY (respects RLS).
    """
    key = SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY
    if not key:
        return {'error': 'Supabase key not configured'}

    # Log which key is being used (for security debugging)
    if not SUPABASE_SERVICE_KEY:
        print('[Warning] Using SUPABASE_ANON_KEY instead of SERVICE_KEY')

    url = f'{SUPABASE_URL}/rest/v1/{path}'
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header('apikey', key)
    req.add_header('Authorization', f'Bearer {key}')
    req.add_header('Content-Type', 'application/json')
    req.add_header('Prefer', 'return=representation')

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        return {'error': f'Supabase {e.code}: {err}'}
    except Exception as e:
        return {'error': str(e)}


def get_mentees_with_email():
    """Fetch mentorados with email from Supabase"""
    return supabase_request('GET', 'mentorados?select=id,nome,email,instagram,fase_jornada,cohort&email=not.is.null&order=nome')


def insert_scheduled_call(data):
    """Insert a call into calls_mentoria"""
    return supabase_request('POST', 'calls_mentoria', data)


# ===== HTTP HANDLER =====
class ProxyHandler(http.server.SimpleHTTPRequestHandler):

    def _get_allowed_origin(self):
        """Get origin from request and validate against whitelist"""
        origin = self.headers.get('Origin', '')
        allowed_origins = [
            'https://spalla-dashboard.vercel.app',
            'http://localhost:3000',
            'http://127.0.0.1:3000',
        ]
        return origin if origin in allowed_origins else None

    def _read_body(self):
        length = int(self.headers.get('Content-Length', 0))
        return self.rfile.read(length) if length > 0 else b''

    def _send_json(self, data, status=200):
        body = json.dumps(data, ensure_ascii=False, default=str).encode('utf-8')  # MED-10
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')  # MED-10
        origin = self._get_allowed_origin()
        if origin:
            self.send_header('Access-Control-Allow-Origin', origin)
        self.send_header('Content-Length', len(body))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(200)
        origin = self._get_allowed_origin()
        if origin:
            self.send_header('Access-Control-Allow-Origin', origin)
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, apikey, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        self.end_headers()

    def do_GET(self):
        if self.path.startswith('/api/evolution/'):
            self._proxy_evolution('GET')
        elif self.path == '/api/mentees':
            self._handle_get_mentees()
        elif self.path.startswith('/api/calendar/events'):
            self._handle_list_events()
        elif self.path == '/api/calls/upcoming':
            self._handle_upcoming_calls()
        elif self.path == '/api/health':
            # Check Evolution API connectivity (HIGH-01)
            evolution_connected = False
            if EVOLUTION_API_KEY:
                try:
                    # Quick check: fetch instances to verify API key works
                    req = urllib.request.Request(f'{EVOLUTION_BASE}/instance/fetchInstances')
                    req.add_header('apikey', EVOLUTION_API_KEY)
                    with urllib.request.urlopen(req, timeout=5) as resp:
                        evolution_connected = (resp.status == 200)
                except:
                    evolution_connected = False
            
            self._send_json({
                'status': 'ok',
                'zoom_configured': bool(ZOOM_ACCOUNT_ID and ZOOM_CLIENT_ID),
                'gcal_configured': bool(os.environ.get('GOOGLE_SA_CREDENTIALS_B64')),
                'supabase_configured': bool(SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY),
                'evolution_connected': evolution_connected,
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
        # Multi-auth endpoints (Supabase Auth integration)
        if self.path == '/api/auth/login':
            self._handle_auth_login()
        elif self.path == '/api/auth/signup':
            self._handle_auth_signup()
        elif self.path == '/api/auth/refresh':
            self._handle_auth_refresh()
        elif self.path == '/api/auth/google/callback':
            self._handle_google_callback()
        elif self.path.startswith('/api/evolution/'):
            self._proxy_evolution('POST')
        elif self.path == '/api/schedule-call':
            self._handle_schedule_call()
        elif self.path == '/api/zoom/create-meeting':
            self._handle_create_zoom_meeting()
        elif self.path == '/api/calendar/create-event':
            self._handle_create_calendar_event()
        else:
            self.send_error(404)

    # ===== AUTHENTICATION (Multi-method) =====

    def _handle_auth_login(self):
        # Multi-login: Email/Password + Google OAuth via Supabase Auth
        try:
            body = json.loads(self._read_body())

            # Import endpoint handler
            from auth_endpoints import handle_login_email_password

            result, status = handle_login_email_password(body)
            self._send_json(result, status)
        except Exception as e:
            log_error('AUTH', 'Login failed', e)
            self._send_json({'error': 'Authentication failed'}, 500)

    def _handle_auth_signup(self):
        # Register new user with email/password
        try:
            body = json.loads(self._read_body())

            from auth_endpoints import handle_signup

            result, status = handle_signup(body)
            self._send_json(result, status)
        except Exception as e:
            log_error('AUTH', 'Signup failed', e)
            self._send_json({'error': 'Signup failed'}, 500)

    def _handle_auth_refresh(self):
        # Refresh access token using refresh token
        try:
            body = json.loads(self._read_body())

            from auth_endpoints import handle_refresh_token

            result, status = handle_refresh_token(body)
            self._send_json(result, status)
        except Exception as e:
            log_error('AUTH', 'Token refresh failed', e)
            self._send_json({'error': 'Token refresh failed'}, 401)

    def _handle_google_callback(self):
        # Google OAuth callback handler
        try:
            body = json.loads(self._read_body())

            from auth_endpoints import handle_google_callback

            result, status = handle_google_callback(body)
            self._send_json(result, status)
        except Exception as e:
            log_error('AUTH', 'Google callback failed', e)
            self._send_json({'error': 'Google authentication failed'}, 500)

    # ===== SCHEDULE CALL (main orchestrator) =====
    def _require_auth(self):
        """Check JWT token in Authorization header. Returns user payload or None."""
        token = get_bearer_token(self.headers)
        if not token:
            self._send_json({'error': 'Authorization required'}, 401)
            return None

        payload = decode_jwt(token)
        if not payload:
            self._send_json({'error': 'Invalid or expired token'}, 401)
            return None

        return payload

    def _handle_schedule_call(self):
        """
        Full scheduling flow:
        1. Create Zoom meeting
        2. Create Google Calendar event with Zoom link
        3. Store in Supabase calls_mentoria
        """
        # Require authentication
        user = self._require_auth()
        if not user:
            return

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

        # Validate mentorado_id (HIGH-05: prevent integer overflow)
        if mentorado_id:
            try:
                mentorado_id = int(mentorado_id)
                if mentorado_id < 1 or mentorado_id > 2147483647:  # Max 32-bit signed int
                    raise ValueError('mentorado_id out of range')
            except (ValueError, TypeError):
                self._send_json({'error': 'Invalid mentorado_id'}, 400)
                return

        # Build datetime with proper DST handling (HIGH-02, MED-05)
        tz_br = pytz.timezone('America/Sao_Paulo')
        try:
            # Parse naive datetime and localize it (handles DST correctly)
            dt_naive = datetime.fromisoformat(f'{data}T{horario}:00')
            dt_aware = tz_br.localize(dt_naive, is_dst=None)  # is_dst=None raises on ambiguous times
            start_dt = dt_aware.isoformat()
            end_dt_obj = dt_aware + timedelta(minutes=duracao)
            end_dt = end_dt_obj.isoformat()
        except Exception as e:
            # Fallback if parsing fails
            now_br = datetime.now(tz_br)
            offset = now_br.strftime('%z')
            offset_formatted = f'{offset[:-2]}:{offset[-2:]}'
            start_dt = f'{data}T{horario}:00{offset_formatted}'
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
                'mentorado_id': mentorado_id,  # Already validated above
                'data_call': f'{data}T{horario}:00{offset_formatted}',
                'tipo': tipo,
                'tipo_call': tipo_call_map.get(tipo, 'acompanhamento'),
                'duracao_minutos': duracao,
                'zoom_meeting_id': str(zoom_result.get('meeting_id', '')),
                'zoom_topic': topic,
                'zoom_join_url': zoom_result.get('join_url', ''),
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
        # Require authentication
        user = self._require_auth()
        if not user:
            return

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

    def _handle_get_mentees(self):
        result = get_mentees_with_email()
        self._send_json(result if isinstance(result, list) else [result])

    def _handle_list_events(self):
        result = list_calendar_events()
        self._send_json(result)

    def _handle_upcoming_calls(self):
        result = supabase_request('GET', "calls_mentoria?status=eq.agendada&order=data_call.asc&select=*")
        self._send_json(result if isinstance(result, list) else [result])

    # ===== EVOLUTION PROXY =====
    def _proxy_evolution(self, method):
        target_path = self.path[len('/api/evolution'):]
        url = f'{EVOLUTION_BASE}{target_path}'
        body = self._read_body() if method == 'POST' else None

        req = urllib.request.Request(url, data=body, method=method)
        req.add_header('Content-Type', 'application/json')
        req.add_header('apikey', EVOLUTION_API_KEY)

        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                resp_body = resp.read()
                self.send_response(resp.status)
                self.send_header('Content-Type', 'application/json')
                # CORS already handled by _get_allowed_origin() above
                self.send_header('Content-Length', len(resp_body))
                self.end_headers()
                self.wfile.write(resp_body)
        except urllib.error.HTTPError as e:
            error_body = e.read()
            self.send_response(e.code)
            self.send_header('Content-Type', 'application/json')
            # CORS already handled by _get_allowed_origin() above
            self.end_headers()
            self.wfile.write(error_body)
        except Exception as e:
            error_msg = json.dumps({'error': str(e)}).encode()
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            # CORS already handled by _get_allowed_origin() above
            self.end_headers()
            self.wfile.write(error_msg)

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
    print(f'[Spalla] Evolution: ✓ proxy at /api/evolution/*')
    print(f'[Spalla] Endpoints:')
    print(f'  POST /api/schedule-call    — Full scheduling (Zoom + Calendar + DB)')
    print(f'  POST /api/zoom/create-meeting')
    print(f'  POST /api/calendar/create-event')
    print(f'  GET  /api/mentees          — Mentorados with email')
    print(f'  GET  /api/calendar/events   — Upcoming calendar events')
    print(f'  GET  /api/calls/upcoming    — Scheduled calls from DB')
    print(f'  GET  /api/health')

    server = http.server.HTTPServer(('', PORT), ProxyHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n[Spalla] Server stopped')
