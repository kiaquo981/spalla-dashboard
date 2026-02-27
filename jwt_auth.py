"""
JWT Authentication Module
Provides token generation, verification, and middleware for protected endpoints
"""

import json
import time
import base64
import hashlib
import hmac
import os
from datetime import datetime, timedelta

# JWT Configuration
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION_HOURS = 24

def _get_jwt_secret():
    """Get JWT_SECRET from environment, raising if not set"""
    secret = os.environ.get('JWT_SECRET')
    if not secret:
        raise ValueError('JWT_SECRET environment variable is required')
    return secret

def generate_jwt(user_id: str, email: str, extra_claims: dict = None) -> str:
    """
    Generate a JWT token for a user

    Args:
        user_id: User's unique ID
        email: User's email address
        extra_claims: Additional payload claims (optional)

    Returns:
        JWT token string

    Raises:
        ValueError: If JWT_SECRET is not configured
    """
    jwt_secret = _get_jwt_secret()

    # Create header
    header = {'alg': JWT_ALGORITHM, 'typ': 'JWT'}

    # Create payload
    now = int(time.time())
    payload = {
        'sub': user_id,
        'email': email,
        'iat': now,
        'exp': now + (JWT_EXPIRATION_HOURS * 3600),
    }

    # Add extra claims if provided
    if extra_claims:
        payload.update(extra_claims)

    # Encode header and payload
    header_b64 = base64.urlsafe_b64encode(
        json.dumps(header).encode()
    ).decode().rstrip('=')

    payload_b64 = base64.urlsafe_b64encode(
        json.dumps(payload).encode()
    ).decode().rstrip('=')

    # Create signature
    msg = f'{header_b64}.{payload_b64}'.encode()
    sig = hmac.new(jwt_secret.encode(), msg, hashlib.sha256).digest()
    sig_b64 = base64.urlsafe_b64encode(sig).decode().rstrip('=')

    return f'{header_b64}.{payload_b64}.{sig_b64}'


def verify_jwt(token: str) -> dict:
    """
    Verify and decode a JWT token

    Args:
        token: JWT token string

    Returns:
        Decoded payload (dict) if valid, None if invalid/expired
    """
    if not token:
        return None

    try:
        jwt_secret = _get_jwt_secret()
        parts = token.split('.')
        if len(parts) != 3:
            return None

        header_b64, payload_b64, sig_b64 = parts

        # Verify signature
        msg = f'{header_b64}.{payload_b64}'.encode()
        expected_sig = hmac.new(jwt_secret.encode(), msg, hashlib.sha256).digest()
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
        print(f'[JWT] Verification error: {e}')
        return None


def extract_bearer_token(auth_header: str) -> str:
    """
    Extract bearer token from Authorization header

    Args:
        auth_header: Authorization header value (e.g., "Bearer token123...")

    Returns:
        Token string if valid format, None otherwise
    """
    if not auth_header:
        return None

    if auth_header.startswith('Bearer '):
        return auth_header[7:]

    return None


def is_token_expired(payload: dict) -> bool:
    """
    Check if a token's payload is expired

    Args:
        payload: Decoded JWT payload

    Returns:
        True if expired, False otherwise
    """
    exp = payload.get('exp', 0)
    return exp < time.time()


def get_token_expiration_seconds(payload: dict) -> int:
    """
    Get remaining seconds until token expiration

    Args:
        payload: Decoded JWT payload

    Returns:
        Seconds remaining (negative if expired)
    """
    exp = payload.get('exp', 0)
    return max(0, exp - int(time.time()))
