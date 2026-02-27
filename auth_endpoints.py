#!/usr/bin/env python3
"""
Auth Endpoints for Supabase + Google OAuth
"""

import json
import os
import time
import hashlib
import hmac
import base64
import urllib.request
import urllib.error
from auth_manager import AuthManager

SUPABASE_URL = os.environ.get('SUPABASE_URL')
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY')

# Validate required environment variables
if not SUPABASE_URL:
    raise ValueError('SUPABASE_URL environment variable is required')
if not SUPABASE_ANON_KEY:
    raise ValueError('SUPABASE_ANON_KEY environment variable is required')

def handle_signup(body):
    """
    POST /api/auth/signup
    Body: {"email": "...", "password": "...", "full_name": "..."}
    """
    try:
        email = body.get('email', '').strip().lower()
        password = body.get('password', '')
        full_name = body.get('full_name', '')
        
        if not email or not password or len(password) < 8:
            return {'error': 'Email and password (min 8 chars) required'}, 400
        
        # Validate email format
        if '@' not in email or '.' not in email:
            return {'error': 'Invalid email format'}, 400
        
        # Call Supabase Auth API to create user
        auth_data = {
            'email': email,
            'password': password,
            'user_metadata': {
                'full_name': full_name
            }
        }
        
        url = f"{SUPABASE_URL}/auth/v1/signup"
        headers = {
            'Content-Type': 'application/json',
            'apikey': SUPABASE_ANON_KEY
        }
        
        req = urllib.request.Request(
            url,
            data=json.dumps(auth_data).encode(),
            headers=headers,
            method='POST'
        )
        
        with urllib.request.urlopen(req, timeout=10) as resp:
            user_data = json.loads(resp.read())
            
            return {
                'user': {'id': user_data.get('user', {}).get('id'), 'email': email},
                'message': 'Signup successful! Check your email to confirm.',
            }, 200
    
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        error_data = json.loads(error_body) if error_body else {}
        
        if 'already registered' in error_data.get('message', ''):
            return {'error': 'Email already registered'}, 409
        
        return {'error': error_data.get('message', 'Signup failed')}, 400
    
    except Exception as e:
        return {'error': f'Signup error: {str(e)}'}, 500


def handle_login_email_password(body):
    """
    POST /api/auth/login
    Body: {"email": "...", "password": "..."}
    Uses Supabase Auth with fallback to hardcoded dev users
    """
    try:
        email = body.get('email', '').strip().lower()
        password = body.get('password', '')

        if not email or not password:
            return {'error': 'Email and password required'}, 400

        # Fallback: Check hardcoded dev users first (for development)
        VALID_USERS = {
            'queila@case.com': 'spalla',
            'hugo.nicchio@gmail.com': 'spalla',  # Dev user for testing
        }

        if email in VALID_USERS and VALID_USERS[email] == password:
            # Generate a mock token for dev users
            # Create a simple JWT-like token
            header = {'alg': 'HS256', 'typ': 'JWT'}
            payload = {
                'sub': email.split('@')[0],
                'email': email,
                'iat': int(time.time()),
                'exp': int(time.time()) + 86400
            }

            header_b64 = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip('=')
            payload_b64 = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip('=')

            secret = os.environ.get('JWT_SECRET', 'dev_secret_change_in_production')
            msg = f'{header_b64}.{payload_b64}'.encode()
            sig = hmac.new(secret.encode(), msg, hashlib.sha256).digest()
            sig_b64 = base64.urlsafe_b64encode(sig).decode().rstrip('=')
            token = f'{header_b64}.{payload_b64}.{sig_b64}'

            return {
                'token': token,
                'refreshToken': token,
                'expiresIn': 86400,
                'user': {
                    'id': email.split('@')[0],
                    'email': email,
                    'user_metadata': {'auth_source': 'dev'}
                }
            }, 200

        # Try Supabase Auth API
        auth_data = {
            'email': email,
            'password': password
        }

        url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
        headers = {
            'Content-Type': 'application/json',
            'apikey': SUPABASE_ANON_KEY
        }

        req = urllib.request.Request(
            url,
            data=json.dumps(auth_data).encode(),
            headers=headers,
            method='POST'
        )

        with urllib.request.urlopen(req, timeout=10) as resp:
            token_data = json.loads(resp.read())

            return {
                'token': token_data.get('access_token'),
                'refreshToken': token_data.get('refresh_token'),
                'expiresIn': token_data.get('expires_in', 3600),
                'user': {
                    'id': token_data.get('user', {}).get('id'),
                    'email': token_data.get('user', {}).get('email'),
                    'user_metadata': token_data.get('user', {}).get('user_metadata', {})
                }
            }, 200

    except urllib.error.HTTPError as e:
        return {'error': 'Invalid credentials'}, 401

    except Exception as e:
        return {'error': f'Login error: {str(e)}'}, 500


def handle_google_callback(body):
    """
    POST /api/auth/google/callback
    Body: {"code": "...", "codeVerifier": "..."}
    Exchange Google auth code for session
    """
    try:
        code = body.get('code', '')
        code_verifier = body.get('codeVerifier', '')
        
        if not code:
            return {'error': 'Auth code required'}, 400
        
        # Call Supabase to exchange code for session
        auth_data = {
            'code': code,
            'code_verifier': code_verifier
        }
        
        url = f"{SUPABASE_URL}/auth/v1/callback"
        headers = {
            'Content-Type': 'application/json',
            'apikey': SUPABASE_ANON_KEY
        }
        
        req = urllib.request.Request(
            url,
            data=json.dumps(auth_data).encode(),
            headers=headers,
            method='POST'
        )
        
        with urllib.request.urlopen(req, timeout=10) as resp:
            session_data = json.loads(resp.read())
            
            return {
                'token': session_data.get('access_token'),
                'refreshToken': session_data.get('refresh_token'),
                'user': session_data.get('user', {})
            }, 200
    
    except Exception as e:
        return {'error': f'Google auth failed: {str(e)}'}, 500


def handle_refresh_token(body):
    """
    POST /api/auth/refresh
    Body: {"refreshToken": "..."}
    Get new access token from refresh token
    """
    try:
        refresh_token = body.get('refreshToken', '')
        
        if not refresh_token:
            return {'error': 'Refresh token required'}, 400
        
        # Call Supabase to refresh token
        auth_data = {
            'refresh_token': refresh_token
        }
        
        url = f"{SUPABASE_URL}/auth/v1/token?grant_type=refresh_token"
        headers = {
            'Content-Type': 'application/json',
            'apikey': SUPABASE_ANON_KEY
        }
        
        req = urllib.request.Request(
            url,
            data=json.dumps(auth_data).encode(),
            headers=headers,
            method='POST'
        )
        
        with urllib.request.urlopen(req, timeout=10) as resp:
            token_data = json.loads(resp.read())
            
            return {
                'token': token_data.get('access_token'),
                'expiresIn': token_data.get('expires_in', 3600)
            }, 200
    
    except Exception as e:
        return {'error': 'Token refresh failed'}, 401

