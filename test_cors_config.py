"""
Unit tests for CORS Configuration
"""

import os
import unittest
from cors_config import (
    get_allowed_origins,
    get_cors_headers,
    is_origin_allowed,
    handle_cors_preflight,
    is_endpoint_protected,
    PUBLIC_ENDPOINTS,
)


class TestCORSConfiguration(unittest.TestCase):
    """Test CORS configuration and whitelist"""

    def test_get_allowed_origins_default(self):
        """Test default allowed origins"""
        origins = get_allowed_origins()
        self.assertIsInstance(origins, list)
        self.assertGreater(len(origins), 0)
        # Should include localhost
        self.assertTrue(any('localhost' in o for o in origins))

    def test_get_allowed_origins_from_env(self):
        """Test allowed origins from environment variable"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'https://example.com, https://test.com'
        origins = get_allowed_origins()
        self.assertEqual(len(origins), 2)
        self.assertIn('https://example.com', origins)
        self.assertIn('https://test.com', origins)
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_get_allowed_origins_from_env_with_spaces(self):
        """Test parsing env origins with extra spaces"""
        os.environ['CORS_ALLOWED_ORIGINS'] = '  https://example.com  ,  https://test.com  '
        origins = get_allowed_origins()
        self.assertEqual(len(origins), 2)
        self.assertIn('https://example.com', origins)
        self.assertIn('https://test.com', origins)
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_is_origin_allowed_valid(self):
        """Test checking if a valid origin is allowed"""
        # Use default origins
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        self.assertTrue(is_origin_allowed('http://localhost:3000'))
        self.assertTrue(is_origin_allowed('http://localhost:8000'))

    def test_is_origin_allowed_invalid(self):
        """Test checking if an invalid origin is rejected"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        self.assertFalse(is_origin_allowed('https://malicious.com'))
        self.assertFalse(is_origin_allowed(''))
        self.assertFalse(is_origin_allowed(None))

    def test_get_cors_headers_allowed_origin(self):
        """Test getting CORS headers for allowed origin"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('http://localhost:3000')
        self.assertIn('Access-Control-Allow-Origin', headers)
        self.assertEqual(headers['Access-Control-Allow-Origin'], 'http://localhost:3000')
        self.assertIn('Access-Control-Allow-Methods', headers)
        self.assertIn('Access-Control-Allow-Headers', headers)

    def test_get_cors_headers_disallowed_origin(self):
        """Test getting CORS headers for disallowed origin"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('https://malicious.com')
        # Should not include CORS headers
        self.assertEqual(len(headers), 0)

    def test_cors_headers_include_auth(self):
        """Test that CORS headers include Authorization"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('http://localhost:3000')
        auth_header = headers.get('Access-Control-Allow-Headers', '')
        self.assertIn('Authorization', auth_header)

    def test_cors_headers_methods(self):
        """Test that CORS headers allow all standard methods"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('http://localhost:3000')
        methods = headers.get('Access-Control-Allow-Methods', '')
        self.assertIn('GET', methods)
        self.assertIn('POST', methods)
        self.assertIn('PUT', methods)
        self.assertIn('DELETE', methods)
        self.assertIn('OPTIONS', methods)

    def test_handle_cors_preflight_allowed(self):
        """Test handling preflight request for allowed origin"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        status, body, headers = handle_cors_preflight('http://localhost:3000')
        self.assertEqual(status, 200)
        self.assertIn('Access-Control-Allow-Origin', headers)

    def test_handle_cors_preflight_disallowed(self):
        """Test handling preflight request for disallowed origin"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        status, body, headers = handle_cors_preflight('https://malicious.com')
        self.assertEqual(status, 403)
        self.assertEqual(len(headers), 0)

    def test_is_endpoint_protected_post(self):
        """Test that POST endpoints are protected"""
        self.assertTrue(is_endpoint_protected('/api/schedule-call', 'POST'))
        self.assertTrue(is_endpoint_protected('/api/users', 'POST'))
        self.assertTrue(is_endpoint_protected('/api/data', 'POST'))

    def test_is_endpoint_protected_put(self):
        """Test that PUT endpoints are protected"""
        self.assertTrue(is_endpoint_protected('/api/users/123', 'PUT'))

    def test_is_endpoint_protected_delete(self):
        """Test that DELETE endpoints are protected"""
        self.assertTrue(is_endpoint_protected('/api/users/123', 'DELETE'))

    def test_is_endpoint_protected_get(self):
        """Test that GET endpoints are not protected (by default)"""
        self.assertFalse(is_endpoint_protected('/api/users', 'GET'))
        self.assertFalse(is_endpoint_protected('/api/data', 'GET'))

    def test_is_endpoint_protected_public(self):
        """Test that public endpoints are never protected"""
        for endpoint in PUBLIC_ENDPOINTS:
            # Even POST to public endpoints shouldn't require auth
            self.assertFalse(is_endpoint_protected(endpoint, 'POST'))

    def test_public_endpoints_exist(self):
        """Test that public endpoints are defined"""
        self.assertIsNotNone(PUBLIC_ENDPOINTS)
        self.assertGreater(len(PUBLIC_ENDPOINTS), 0)
        # Should include auth endpoints
        self.assertTrue(any('/auth/' in ep for ep in PUBLIC_ENDPOINTS))

    def test_public_endpoints_include_health(self):
        """Test that health endpoint is public"""
        self.assertIn('/api/health', PUBLIC_ENDPOINTS)
        self.assertFalse(is_endpoint_protected('/api/health', 'GET'))
        self.assertFalse(is_endpoint_protected('/api/health', 'POST'))

    def test_production_origins_included(self):
        """Test that production origins are included"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        origins = get_allowed_origins()
        # Should include production URLs
        self.assertTrue(any('railway' in o or 'vercel' in o or 'spalla' in o for o in origins))

    def test_cors_max_age(self):
        """Test that CORS Max-Age is set for preflight caching"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('http://localhost:3000')
        self.assertIn('Access-Control-Max-Age', headers)
        self.assertEqual(headers['Access-Control-Max-Age'], '3600')

    def test_cors_credentials_allowed(self):
        """Test that credentials are allowed in CORS"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)
        headers = get_cors_headers('http://localhost:3000')
        self.assertIn('Access-Control-Allow-Credentials', headers)
        self.assertEqual(headers['Access-Control-Allow-Credentials'], 'true')


class TestCORSEdgeCases(unittest.TestCase):
    """Test edge cases for CORS configuration"""

    def setUp(self):
        """Clean environment before each test"""
        os.environ.pop('CORS_ALLOWED_ORIGINS', None)

    def test_case_sensitive_origins(self):
        """Test that origins are case-sensitive"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'https://Example.Com'
        origins = get_allowed_origins()
        # Origins should be stored as-is
        self.assertIn('https://Example.Com', origins)
        # Different case should not match
        self.assertFalse(is_origin_allowed('https://example.com'))
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_protocol_matters(self):
        """Test that protocol (http vs https) matters"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'https://example.com'
        # https is allowed
        self.assertTrue(is_origin_allowed('https://example.com'))
        # http is not
        self.assertFalse(is_origin_allowed('http://example.com'))
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_port_matters(self):
        """Test that port number matters"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'http://localhost:3000'
        # Port 3000 is allowed
        self.assertTrue(is_origin_allowed('http://localhost:3000'))
        # Port 8000 is not
        self.assertFalse(is_origin_allowed('http://localhost:8000'))
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_subdomain_matters(self):
        """Test that subdomains are treated as different origins"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'https://api.example.com'
        # Exact subdomain is allowed
        self.assertTrue(is_origin_allowed('https://api.example.com'))
        # Different subdomain is not
        self.assertFalse(is_origin_allowed('https://app.example.com'))
        # Parent domain is not
        self.assertFalse(is_origin_allowed('https://example.com'))
        del os.environ['CORS_ALLOWED_ORIGINS']

    def test_trailing_slash_matters(self):
        """Test that trailing slashes matter"""
        os.environ['CORS_ALLOWED_ORIGINS'] = 'https://example.com/'
        # With trailing slash is allowed
        self.assertTrue(is_origin_allowed('https://example.com/'))
        # Without is different
        self.assertFalse(is_origin_allowed('https://example.com'))
        del os.environ['CORS_ALLOWED_ORIGINS']


if __name__ == '__main__':
    unittest.main()
