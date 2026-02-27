"""
CORS (Cross-Origin Resource Sharing) Configuration
Whitelist of allowed origins for the API
"""

import os
from typing import List

# Get allowed origins from environment or use defaults
def get_allowed_origins() -> List[str]:
    """
    Get list of allowed origins from environment variables

    Priority:
    1. CORS_ALLOWED_ORIGINS environment variable (comma-separated)
    2. Hardcoded defaults for dev/prod

    Returns:
        List of allowed origin URLs
    """
    # Check environment variable first
    env_origins = os.environ.get('CORS_ALLOWED_ORIGINS', '')
    if env_origins:
        # Parse comma-separated list
        origins = [origin.strip() for origin in env_origins.split(',') if origin.strip()]
        return origins

    # Default origins for development and production
    return [
        # Local development
        'http://localhost:3000',
        'http://localhost:8000',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8000',

        # Railway/Production
        'https://spalla-dashboard.railway.app',
        'https://spalla-dashboard.vercel.app',

        # Spalla domain (once deployed)
        'https://spalla.com.br',
        'https://www.spalla.com.br',
        'https://app.spalla.com.br',

        # Admin/analytics tools
        'https://postman.com',
    ]


def get_cors_headers(origin: str) -> dict:
    """
    Get CORS headers for the given origin

    Args:
        origin: The Origin header from request

    Returns:
        Dictionary of CORS headers to send in response
    """
    allowed_origins = get_allowed_origins()

    # Check if origin is allowed
    if origin in allowed_origins or origin == '*' in allowed_origins:
        return {
            'Access-Control-Allow-Origin': origin,
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
            'Access-Control-Max-Age': '3600',
            'Access-Control-Allow-Credentials': 'true',
        }

    # Origin not allowed - don't send CORS headers
    return {}


def is_origin_allowed(origin: str) -> bool:
    """
    Check if the given origin is allowed

    Args:
        origin: The Origin header from request

    Returns:
        True if origin is in whitelist, False otherwise
    """
    if not origin:
        return False

    allowed_origins = get_allowed_origins()
    return origin in allowed_origins


def handle_cors_preflight(origin: str) -> tuple:
    """
    Handle CORS preflight requests (OPTIONS)

    Args:
        origin: The Origin header from request

    Returns:
        Tuple of (status_code, response_body, headers)
    """
    headers = get_cors_headers(origin)

    if not headers:
        # Origin not allowed
        return (403, 'Origin not allowed', {})

    # Success - return 200 with CORS headers
    return (200, '', headers)


# Valid request methods that need authentication
PROTECTED_METHODS = {'POST', 'PUT', 'DELETE', 'PATCH'}

# Endpoints that don't require authentication
PUBLIC_ENDPOINTS = {
    '/api/health',
    '/api/auth/login',
    '/api/auth/signup',
    '/api/auth/refresh',
    '/api/auth/google/callback',
}


def is_endpoint_protected(path: str, method: str) -> bool:
    """
    Determine if an endpoint requires JWT authentication

    Args:
        path: Request path (e.g., '/api/schedule-call')
        method: HTTP method (GET, POST, etc.)

    Returns:
        True if endpoint requires JWT, False if public
    """
    # Public endpoints never require auth
    if path in PUBLIC_ENDPOINTS:
        return False

    # Only protect POST, PUT, DELETE, PATCH methods
    # GET requests are generally public (unless they return sensitive data)
    return method in PROTECTED_METHODS
