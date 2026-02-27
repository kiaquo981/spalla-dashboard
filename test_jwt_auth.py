"""
Unit tests for JWT Authentication Module
"""

import os
import time
import unittest
from unittest.mock import patch
from jwt_auth import (
    generate_jwt,
    verify_jwt,
    extract_bearer_token,
    is_token_expired,
    get_token_expiration_seconds,
)


class TestJWTAuth(unittest.TestCase):
    """JWT Authentication Tests"""

    def setUp(self):
        """Set up test environment"""
        os.environ['JWT_SECRET'] = 'test_secret_key_min_32_characters_1234567890'

    def tearDown(self):
        """Clean up after tests"""
        if 'JWT_SECRET' in os.environ:
            del os.environ['JWT_SECRET']

    def test_generate_jwt_valid(self):
        """Test JWT generation with valid inputs"""
        token = generate_jwt('user123', 'user@example.com')
        self.assertIsNotNone(token)
        self.assertIn('.', token)
        parts = token.split('.')
        self.assertEqual(len(parts), 3)

    def test_generate_jwt_without_secret(self):
        """Test JWT generation fails without JWT_SECRET"""
        del os.environ['JWT_SECRET']
        with self.assertRaises(ValueError):
            generate_jwt('user123', 'user@example.com')

    def test_generate_jwt_with_extra_claims(self):
        """Test JWT generation with extra claims"""
        extra = {'role': 'admin', 'org_id': 'org456'}
        token = generate_jwt('user123', 'user@example.com', extra)
        payload = verify_jwt(token)
        self.assertEqual(payload['role'], 'admin')
        self.assertEqual(payload['org_id'], 'org456')

    def test_verify_jwt_valid(self):
        """Test JWT verification with valid token"""
        token = generate_jwt('user123', 'user@example.com')
        payload = verify_jwt(token)
        self.assertIsNotNone(payload)
        self.assertEqual(payload['sub'], 'user123')
        self.assertEqual(payload['email'], 'user@example.com')

    def test_verify_jwt_invalid_format(self):
        """Test JWT verification fails with invalid format"""
        payload = verify_jwt('invalid.token')
        self.assertIsNone(payload)

    def test_verify_jwt_tampered_signature(self):
        """Test JWT verification fails with tampered signature"""
        token = generate_jwt('user123', 'user@example.com')
        parts = token.split('.')
        tampered = f'{parts[0]}.{parts[1]}.invalidsignature'
        payload = verify_jwt(tampered)
        self.assertIsNone(payload)

    def test_verify_jwt_expired(self):
        """Test JWT verification fails with expired token"""
        # Create token with past expiration
        import json
        import base64
        import hashlib
        import hmac

        header = {'alg': 'HS256', 'typ': 'JWT'}
        payload = {
            'sub': 'user123',
            'email': 'user@example.com',
            'iat': int(time.time()) - 86400,  # 1 day ago
            'exp': int(time.time()) - 3600,   # Expired 1 hour ago
        }

        header_b64 = base64.urlsafe_b64encode(
            json.dumps(header).encode()
        ).decode().rstrip('=')
        payload_b64 = base64.urlsafe_b64encode(
            json.dumps(payload).encode()
        ).decode().rstrip('=')

        msg = f'{header_b64}.{payload_b64}'.encode()
        sig = hmac.new(
            os.environ['JWT_SECRET'].encode(),
            msg,
            hashlib.sha256
        ).digest()
        sig_b64 = base64.urlsafe_b64encode(sig).decode().rstrip('=')

        token = f'{header_b64}.{payload_b64}.{sig_b64}'
        payload = verify_jwt(token)
        self.assertIsNone(payload)

    def test_extract_bearer_token_valid(self):
        """Test bearer token extraction with valid format"""
        auth_header = 'Bearer token123'
        token = extract_bearer_token(auth_header)
        self.assertEqual(token, 'token123')

    def test_extract_bearer_token_invalid_format(self):
        """Test bearer token extraction fails with invalid format"""
        # Missing "Bearer " prefix
        token = extract_bearer_token('token123')
        self.assertIsNone(token)

        # Wrong prefix
        token = extract_bearer_token('Basic token123')
        self.assertIsNone(token)

        # Empty string
        token = extract_bearer_token('')
        self.assertIsNone(token)

    def test_extract_bearer_token_none(self):
        """Test bearer token extraction with None input"""
        token = extract_bearer_token(None)
        self.assertIsNone(token)

    def test_is_token_expired_valid(self):
        """Test expiration check with valid token"""
        token = generate_jwt('user123', 'user@example.com')
        payload = verify_jwt(token)
        self.assertFalse(is_token_expired(payload))

    def test_is_token_expired_expired(self):
        """Test expiration check with expired token"""
        # Payload with past expiration
        payload = {
            'sub': 'user123',
            'email': 'user@example.com',
            'exp': int(time.time()) - 3600  # Expired 1 hour ago
        }
        self.assertTrue(is_token_expired(payload))

    def test_get_token_expiration_seconds_valid(self):
        """Test getting remaining expiration seconds"""
        token = generate_jwt('user123', 'user@example.com')
        payload = verify_jwt(token)
        remaining = get_token_expiration_seconds(payload)
        # Should be ~24 hours (86400 seconds)
        # Allow 5 seconds margin for test execution time
        self.assertGreater(remaining, 86395)
        self.assertLessEqual(remaining, 86400)

    def test_get_token_expiration_seconds_expired(self):
        """Test getting remaining expiration seconds for expired token"""
        payload = {
            'sub': 'user123',
            'email': 'user@example.com',
            'exp': int(time.time()) - 3600  # Expired 1 hour ago
        }
        remaining = get_token_expiration_seconds(payload)
        self.assertEqual(remaining, 0)

    def test_round_trip_token_generation_verification(self):
        """Test complete round trip: generate → verify"""
        user_id = 'test_user_123'
        email = 'test@example.com'
        extra = {'role': 'admin', 'permissions': ['read', 'write']}

        # Generate
        token = generate_jwt(user_id, email, extra)
        self.assertIsNotNone(token)

        # Verify
        payload = verify_jwt(token)
        self.assertIsNotNone(payload)
        self.assertEqual(payload['sub'], user_id)
        self.assertEqual(payload['email'], email)
        self.assertEqual(payload['role'], 'admin')
        self.assertEqual(payload['permissions'], ['read', 'write'])

    def test_multiple_tokens_different(self):
        """Test that multiple tokens for same user are different"""
        token1 = generate_jwt('user123', 'user@example.com')
        time.sleep(1.01)  # Ensure different timestamp (must be > 1 second)
        token2 = generate_jwt('user123', 'user@example.com')
        # Tokens should be different due to different 'iat'
        self.assertNotEqual(token1, token2)


class TestJWTEdgeCases(unittest.TestCase):
    """Edge case tests for JWT"""

    def setUp(self):
        """Set up test environment"""
        os.environ['JWT_SECRET'] = 'test_secret_key_min_32_characters_1234567890'

    def tearDown(self):
        """Clean up after tests"""
        if 'JWT_SECRET' in os.environ:
            del os.environ['JWT_SECRET']

    def test_very_long_token(self):
        """Test JWT with very long extra claims"""
        big_claim = 'x' * 10000
        token = generate_jwt('user123', 'user@example.com', {'data': big_claim})
        payload = verify_jwt(token)
        self.assertEqual(payload['data'], big_claim)

    def test_special_characters_in_email(self):
        """Test JWT with special characters in email"""
        email = 'user+test@example.co.uk'
        token = generate_jwt('user123', email)
        payload = verify_jwt(token)
        self.assertEqual(payload['email'], email)

    def test_unicode_in_claims(self):
        """Test JWT with Unicode characters in claims"""
        token = generate_jwt('user123', 'user@example.com', {'name': 'João Silva'})
        payload = verify_jwt(token)
        self.assertEqual(payload['name'], 'João Silva')


if __name__ == '__main__':
    unittest.main()
