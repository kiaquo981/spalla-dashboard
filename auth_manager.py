#!/usr/bin/env python3
"""
Spalla Authentication Module
Supports: Email/Password (bcrypt), Google OAuth, Supabase Auth
"""

import json
import os
import hmac
import hashlib
import base64
import time
from datetime import datetime, timedelta

# Try to import bcrypt, fallback to manual hashing
try:
    import bcrypt
    HAS_BCRYPT = True
except ImportError:
    HAS_BCRYPT = False
    print("⚠️  bcrypt not installed. Using fallback hashing.")

SUPABASE_URL = "https://knusqfbvhsqworzyhvip.supabase.co"
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY', '')
SUPABASE_SERVICE_KEY = os.environ.get('SUPABASE_SERVICE_KEY', '')

JWT_SECRET = os.environ.get('JWT_SECRET', 'CHANGE_ME_IN_PRODUCTION')
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION = 86400  # 24 hours

# OAuth Google Config
GOOGLE_CLIENT_ID = os.environ.get('GOOGLE_OAUTH_CLIENT_ID', '')
GOOGLE_CLIENT_SECRET = os.environ.get('GOOGLE_OAUTH_CLIENT_SECRET', '')
GOOGLE_REDIRECT_URI = os.environ.get('GOOGLE_REDIRECT_URI', 'http://localhost:3000/auth/google/callback')

class AuthManager:
    """Multi-method authentication manager"""
    
    @staticmethod
    def hash_password(password):
        """Hash password with bcrypt or fallback"""
        if HAS_BCRYPT:
            return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        else:
            # Fallback: PBKDF2 (not as secure as bcrypt, but better than plaintext)
            salt = os.urandom(16)
            key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
            return base64.b64encode(salt + key).decode()
    
    @staticmethod
    def verify_password(password, hashed):
        """Verify password against hash"""
        if HAS_BCRYPT:
            return bcrypt.checkpw(password.encode(), hashed.encode())
        else:
            # Fallback: PBKDF2
            try:
                data = base64.b64decode(hashed)
                salt = data[:16]
                key = data[16:]
                computed = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
                return computed == key
            except:
                return False
    
    @staticmethod
    def encode_jwt(payload):
        """Encode JWT token"""
        header = {'alg': JWT_ALGORITHM, 'typ': 'JWT'}
        header_b64 = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip('=')
        
        payload['iat'] = int(time.time())
        payload['exp'] = int(time.time()) + JWT_EXPIRATION
        payload_b64 = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip('=')
        
        msg = f'{header_b64}.{payload_b64}'.encode()
        sig = hmac.new(JWT_SECRET.encode(), msg, hashlib.sha256).digest()
        sig_b64 = base64.urlsafe_b64encode(sig).decode().rstrip('=')
        
        return f'{header_b64}.{payload_b64}.{sig_b64}'
    
    @staticmethod
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
            
            if not hmac.compare_digest(sig_b64, expected_sig_b64):
                return None
            
            # Decode payload
            payload_json = base64.urlsafe_b64decode(payload_b64 + '==')
            payload = json.loads(payload_json)
            
            # Check expiration
            if payload.get('exp', 0) < time.time():
                return None
            
            return payload
        except:
            return None
