"""
Unit tests for Error Handler Module
"""

import unittest
from error_handler import (
    ErrorSeverity,
    ErrorCode,
    AppError,
    DatabaseError,
    ValidationError,
    AuthenticationError,
    ErrorLogger,
    safe_database_call,
    safe_api_call,
    format_error_response,
)


class TestErrorCodes(unittest.TestCase):
    """Test error code enumeration"""

    def test_error_code_values(self):
        """Test that error codes have values"""
        self.assertEqual(ErrorCode.DB_CONNECTION.value, 5001)
        self.assertEqual(ErrorCode.AUTH_MISSING.value, 4005)
        self.assertEqual(ErrorCode.VALIDATION_FAILED.value, 4100)

    def test_error_code_uniqueness(self):
        """Test that error codes are unique"""
        values = [code.value for code in ErrorCode]
        self.assertEqual(len(values), len(set(values)))


class TestAppError(unittest.TestCase):
    """Test AppError class"""

    def test_app_error_basic(self):
        """Test creating basic AppError"""
        error = AppError('Something went wrong')
        self.assertEqual(error.message, 'Something went wrong')
        self.assertEqual(error.severity, ErrorSeverity.ERROR)
        self.assertIsNotNone(error.timestamp)

    def test_app_error_with_code(self):
        """Test AppError with custom error code"""
        error = AppError(
            'Database connection failed',
            error_code=ErrorCode.DB_CONNECTION,
            severity=ErrorSeverity.CRITICAL,
        )
        self.assertEqual(error.error_code, ErrorCode.DB_CONNECTION)
        self.assertEqual(error.severity, ErrorSeverity.CRITICAL)

    def test_app_error_to_dict(self):
        """Test AppError serialization"""
        error = AppError(
            'Test error',
            error_code=ErrorCode.VALIDATION_FAILED,
            context={'field': 'email'},
        )
        error_dict = error.to_dict()
        self.assertIn('error', error_dict)
        self.assertIn('code', error_dict)
        self.assertIn('severity', error_dict)
        self.assertIn('timestamp', error_dict)
        self.assertEqual(error_dict['context']['field'], 'email')

    def test_app_error_with_original_error(self):
        """Test AppError wrapping original exception"""
        original = ValueError('Original error')
        error = AppError(
            'Wrapped error',
            original_error=original,
        )
        self.assertEqual(error.original_error, original)


class TestDatabaseError(unittest.TestCase):
    """Test DatabaseError class"""

    def test_database_error_basic(self):
        """Test creating DatabaseError"""
        error = DatabaseError('Query failed', operation='SELECT')
        self.assertEqual(error.message, 'Query failed')
        self.assertEqual(error.error_code, ErrorCode.DB_QUERY_FAILED)
        self.assertIn('operation', error.context)

    def test_database_error_with_details(self):
        """Test DatabaseError with operation details"""
        error = DatabaseError(
            'INSERT failed',
            operation='INSERT',
            query='INSERT INTO users...',
        )
        self.assertIn('operation', error.context)
        self.assertEqual(error.context['operation'], 'INSERT')


class TestValidationError(unittest.TestCase):
    """Test ValidationError class"""

    def test_validation_error_basic(self):
        """Test creating ValidationError"""
        error = ValidationError('Invalid email', field='email')
        self.assertEqual(error.message, 'Invalid email')
        self.assertEqual(error.error_code, ErrorCode.VALIDATION_FAILED)
        self.assertEqual(error.context['field'], 'email')

    def test_validation_error_with_details(self):
        """Test ValidationError with details"""
        error = ValidationError(
            'Invalid format',
            field='phone',
            details='Expected format: +55 11 99999-9999',
        )
        self.assertEqual(error.context['field'], 'phone')
        self.assertIn('details', error.context)


class TestAuthenticationError(unittest.TestCase):
    """Test AuthenticationError class"""

    def test_auth_error_basic(self):
        """Test creating AuthenticationError"""
        error = AuthenticationError('Missing token', auth_type='JWT')
        self.assertEqual(error.message, 'Missing token')
        self.assertEqual(error.error_code, ErrorCode.AUTH_MISSING)

    def test_auth_error_context(self):
        """Test AuthenticationError includes auth type"""
        error = AuthenticationError('Invalid token', auth_type='OAuth')
        self.assertEqual(error.context['auth_type'], 'OAuth')


class TestErrorLogger(unittest.TestCase):
    """Test ErrorLogger class"""

    def test_log_generic_error(self):
        """Test logging generic error"""
        error = ValueError('Test error')
        info = ErrorLogger.log(error, context='TEST')
        self.assertIn('timestamp', info)
        self.assertIn('type', info)
        self.assertIn('message', info)
        self.assertIn('context', info)
        self.assertEqual(info['context'], 'TEST')

    def test_log_database_error(self):
        """Test logging database error"""
        error = Exception('Connection timeout')
        info = ErrorLogger.log_database_error(
            operation='SELECT',
            query='SELECT * FROM users',
            error=error,
        )
        self.assertIn('timestamp', info)
        self.assertIn('context', info)

    def test_log_api_error(self):
        """Test logging API error"""
        error = Exception('Not found')
        info = ErrorLogger.log_api_error(
            endpoint='/api/users',
            method='GET',
            error=error,
        )
        self.assertIn('context', info)
        self.assertIn('API', info['context'])
        self.assertIn('GET', info['context'])


class TestSafeDatabaseCall(unittest.TestCase):
    """Test safe_database_call function"""

    def test_successful_operation(self):
        """Test successful database operation"""
        def operation():
            return {'id': 1, 'name': 'test'}

        success, result, error = safe_database_call('SELECT', operation)
        self.assertTrue(success)
        self.assertEqual(result['id'], 1)
        self.assertIsNone(error)

    def test_failed_operation(self):
        """Test failed database operation"""
        def operation():
            raise Exception('Connection lost')

        success, result, error = safe_database_call('INSERT', operation)
        self.assertFalse(success)
        self.assertIsNone(result)
        self.assertIsNotNone(error)
        self.assertIsInstance(error, DatabaseError)

    def test_operation_with_arguments(self):
        """Test database operation with arguments"""
        def operation(a, b, multiplier=1):
            return (a + b) * multiplier

        success, result, error = safe_database_call(
            'CALCULATE',
            operation,
            10,
            20,
            multiplier=2,
        )
        self.assertTrue(success)
        self.assertEqual(result, 60)


class TestSafeAPICall(unittest.TestCase):
    """Test safe_api_call function"""

    def test_successful_api_call(self):
        """Test successful API operation"""
        def operation():
            return {'status': 'ok', 'data': []}

        success, result, error = safe_api_call(
            '/api/users',
            'GET',
            operation,
        )
        self.assertTrue(success)
        self.assertIsNone(error)

    def test_failed_api_call(self):
        """Test failed API operation"""
        def operation():
            raise ValueError('Invalid input')

        success, result, error = safe_api_call(
            '/api/users',
            'POST',
            operation,
        )
        self.assertFalse(success)
        self.assertIsNotNone(error)

    def test_app_error_propagation(self):
        """Test AppError is properly propagated"""
        def operation():
            raise ValidationError('Email invalid', field='email')

        success, result, error = safe_api_call(
            '/api/users',
            'POST',
            operation,
        )
        self.assertFalse(success)
        self.assertIsInstance(error, ValidationError)


class TestFormatErrorResponse(unittest.TestCase):
    """Test format_error_response function"""

    def test_format_validation_error(self):
        """Test formatting validation error"""
        error = ValidationError('Invalid email', field='email')
        response, status = format_error_response(error)
        self.assertEqual(status, 400)
        self.assertIn('error', response)

    def test_format_db_error(self):
        """Test formatting database error"""
        error = DatabaseError('Connection failed', operation='SELECT')
        response, status = format_error_response(error)
        self.assertEqual(status, 500)
        self.assertIn('error', response)

    def test_format_auth_error(self):
        """Test formatting authentication error"""
        error = AuthenticationError('Missing token', auth_type='JWT')
        response, status = format_error_response(error)
        self.assertEqual(status, 401)

    def test_format_not_found_error(self):
        """Test formatting 404 error"""
        error = AppError(
            'User not found',
            error_code=ErrorCode.DB_NOT_FOUND,
        )
        response, status = format_error_response(error)
        self.assertEqual(status, 404)

    def test_format_rate_limit_error(self):
        """Test formatting rate limit error"""
        error = AppError(
            'Rate limited',
            error_code=ErrorCode.API_RATE_LIMITED,
        )
        response, status = format_error_response(error)
        self.assertEqual(status, 429)

    def test_format_timeout_error(self):
        """Test formatting timeout error"""
        error = AppError(
            'Request timeout',
            error_code=ErrorCode.API_TIMEOUT,
        )
        response, status = format_error_response(error)
        self.assertEqual(status, 504)

    def test_format_unavailable_error(self):
        """Test formatting service unavailable error"""
        error = AppError(
            'Service unavailable',
            error_code=ErrorCode.API_UNAVAILABLE,
        )
        response, status = format_error_response(error)
        self.assertEqual(status, 503)


class TestErrorSeverity(unittest.TestCase):
    """Test error severity levels"""

    def test_severity_values(self):
        """Test severity level values"""
        self.assertEqual(ErrorSeverity.CRITICAL.value, 'CRITICAL')
        self.assertEqual(ErrorSeverity.ERROR.value, 'ERROR')
        self.assertEqual(ErrorSeverity.WARNING.value, 'WARNING')
        self.assertEqual(ErrorSeverity.INFO.value, 'INFO')


class TestErrorEdgeCases(unittest.TestCase):
    """Test error handling edge cases"""

    def test_error_with_none_context(self):
        """Test AppError with None context"""
        error = AppError('Error', context=None)
        self.assertEqual(error.context, {})

    def test_error_nesting(self):
        """Test error wrapping (nesting)"""
        original = ValueError('Original')
        middle = DatabaseError('Wrapped', original_error=original)
        outer = AppError('Outer', original_error=middle)
        self.assertEqual(outer.original_error, middle)

    def test_error_to_dict_serializable(self):
        """Test that error dict is JSON serializable"""
        import json
        error = AppError(
            'Test',
            context={'data': 'value'},
        )
        error_dict = error.to_dict()
        # Should not raise
        json_str = json.dumps(error_dict)
        self.assertIsNotNone(json_str)

    def test_unicode_in_error_message(self):
        """Test error messages with unicode"""
        error = AppError('Erro de autenticação em São Paulo')
        self.assertIn('São Paulo', error.message)

    def test_long_error_message(self):
        """Test very long error message"""
        long_message = 'x' * 10000
        error = AppError(long_message)
        self.assertEqual(error.message, long_message)


if __name__ == '__main__':
    unittest.main()
