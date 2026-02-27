"""
Error Handler Module
Provides comprehensive error handling and logging for database and API failures
Prevents silent failures by ensuring all errors are logged and reported
"""

import json
import traceback
from datetime import datetime
from typing import Any, Dict, Optional, Tuple
from enum import Enum

# Error severity levels
class ErrorSeverity(Enum):
    """Error severity classification"""
    CRITICAL = 'CRITICAL'  # System down, data loss risk
    ERROR = 'ERROR'        # Operation failed but system functioning
    WARNING = 'WARNING'    # Operation succeeded with degradation
    INFO = 'INFO'         # Informational logging


class ErrorCode(Enum):
    """Standardized error codes"""
    # Database errors (5000-5999)
    DB_CONNECTION = 5001
    DB_QUERY_FAILED = 5002
    DB_TRANSACTION_FAILED = 5003
    DB_CONSTRAINT_VIOLATION = 5004
    DB_TIMEOUT = 5005
    DB_NOT_FOUND = 5006

    # Authentication errors (4000-4999)
    AUTH_INVALID_CREDENTIALS = 4001
    AUTH_TOKEN_EXPIRED = 4002
    AUTH_TOKEN_INVALID = 4003
    AUTH_INSUFFICIENT_PERMISSIONS = 4004
    AUTH_MISSING = 4005

    # Validation errors (4100-4199)
    VALIDATION_FAILED = 4100
    VALIDATION_SCHEMA_MISMATCH = 4101
    VALIDATION_CONSTRAINT = 4102

    # API errors (4200-4299)
    API_NOT_FOUND = 4200
    API_METHOD_NOT_ALLOWED = 4201
    API_RATE_LIMITED = 4202
    API_TIMEOUT = 4203
    API_UNAVAILABLE = 4204

    # External service errors (5500-5999)
    EXTERNAL_SERVICE_FAILED = 5500
    EXTERNAL_SERVICE_TIMEOUT = 5501
    EXTERNAL_SERVICE_UNAVAILABLE = 5502

    # Unknown errors
    UNKNOWN = 9999


class AppError(Exception):
    """Application error with structured information"""

    def __init__(
        self,
        message: str,
        error_code: ErrorCode = ErrorCode.UNKNOWN,
        severity: ErrorSeverity = ErrorSeverity.ERROR,
        context: Dict = None,
        original_error: Exception = None,
    ):
        """
        Initialize application error

        Args:
            message: Human-readable error message
            error_code: Standardized error code
            severity: Error severity level
            context: Additional context information
            original_error: Original exception that caused this error
        """
        self.message = message
        self.error_code = error_code
        self.severity = severity
        self.context = context or {}
        self.original_error = original_error
        self.timestamp = datetime.utcnow().isoformat()
        super().__init__(message)

    def to_dict(self) -> Dict:
        """Convert error to dictionary for JSON response"""
        return {
            'error': self.message,
            'code': self.error_code.value,
            'severity': self.severity.value,
            'timestamp': self.timestamp,
            'context': self.context,
        }


class DatabaseError(AppError):
    """Database operation error"""

    def __init__(
        self,
        message: str,
        operation: str = '',
        query: str = '',
        original_error: Exception = None,
    ):
        """
        Initialize database error

        Args:
            message: Error message
            operation: Operation being attempted (SELECT, INSERT, UPDATE, DELETE)
            query: SQL query (safe - no sensitive data)
            original_error: Original exception
        """
        context = {}
        if operation:
            context['operation'] = operation
        if query:
            # Only log query structure, not actual data
            context['query_type'] = operation or 'UNKNOWN'

        super().__init__(
            message,
            error_code=ErrorCode.DB_QUERY_FAILED,
            severity=ErrorSeverity.ERROR,
            context=context,
            original_error=original_error,
        )


class ValidationError(AppError):
    """Input validation error"""

    def __init__(self, message: str, field: str = '', details: str = ''):
        """
        Initialize validation error

        Args:
            message: Error message
            field: Field that failed validation
            details: Additional validation details
        """
        context = {}
        if field:
            context['field'] = field
        if details:
            context['details'] = details

        super().__init__(
            message,
            error_code=ErrorCode.VALIDATION_FAILED,
            severity=ErrorSeverity.WARNING,
            context=context,
        )


class AuthenticationError(AppError):
    """Authentication error"""

    def __init__(self, message: str, auth_type: str = ''):
        """
        Initialize authentication error

        Args:
            message: Error message
            auth_type: Type of authentication (JWT, OAuth, etc.)
        """
        context = {}
        if auth_type:
            context['auth_type'] = auth_type

        super().__init__(
            message,
            error_code=ErrorCode.AUTH_MISSING,
            severity=ErrorSeverity.WARNING,
            context=context,
        )


class ErrorLogger:
    """Comprehensive error logging"""

    @staticmethod
    def log(
        error: Exception,
        context: str = '',
        severity: ErrorSeverity = ErrorSeverity.ERROR,
    ) -> Dict:
        """
        Log an error with full context

        Args:
            error: Exception to log
            context: Additional context (component name, operation, etc.)
            severity: Error severity

        Returns:
            Error information dictionary
        """
        timestamp = datetime.utcnow().isoformat()
        error_type = type(error).__name__
        error_message = str(error)
        stack_trace = traceback.format_exc()

        # Build error info
        error_info = {
            'timestamp': timestamp,
            'severity': severity.value,
            'type': error_type,
            'message': error_message,
            'context': context,
            'stack_trace': stack_trace,
        }

        # Log to console
        log_line = f'[{timestamp}] {severity.value} [{context}] {error_message}'
        print(log_line)

        # Include stack trace for CRITICAL and ERROR
        if severity in [ErrorSeverity.CRITICAL, ErrorSeverity.ERROR]:
            print(f'Stack trace:\n{stack_trace}')

        return error_info

    @staticmethod
    def log_database_error(
        operation: str,
        query: str,
        error: Exception,
    ) -> Dict:
        """
        Log database error with safe query info

        Args:
            operation: SQL operation (SELECT, INSERT, etc.)
            query: SQL query (will be sanitized)
            error: Exception from database

        Returns:
            Error information
        """
        return ErrorLogger.log(
            error,
            context=f'DATABASE[{operation}]',
            severity=ErrorSeverity.ERROR,
        )

    @staticmethod
    def log_api_error(
        endpoint: str,
        method: str,
        error: Exception,
    ) -> Dict:
        """
        Log API endpoint error

        Args:
            endpoint: API endpoint path
            method: HTTP method
            error: Exception

        Returns:
            Error information
        """
        return ErrorLogger.log(
            error,
            context=f'API[{method} {endpoint}]',
            severity=ErrorSeverity.ERROR,
        )


def safe_database_call(
    operation_name: str,
    operation_func,
    *args,
    **kwargs,
) -> Tuple[bool, Any, Optional[AppError]]:
    """
    Execute database operation with error handling

    Args:
        operation_name: Name of operation (for logging)
        operation_func: Function to execute
        *args: Function arguments
        **kwargs: Function keyword arguments

    Returns:
        Tuple of (success: bool, result: Any, error: AppError or None)
    """
    try:
        result = operation_func(*args, **kwargs)
        return True, result, None

    except Exception as e:
        error = DatabaseError(
            message=f'Database operation failed: {operation_name}',
            operation=operation_name,
            original_error=e,
        )
        ErrorLogger.log_database_error(
            operation=operation_name,
            query='',
            error=e,
        )
        return False, None, error


def safe_api_call(
    endpoint: str,
    method: str,
    operation_func,
    *args,
    **kwargs,
) -> Tuple[bool, Any, Optional[AppError]]:
    """
    Execute API operation with error handling

    Args:
        endpoint: API endpoint
        method: HTTP method
        operation_func: Function to execute
        *args: Function arguments
        **kwargs: Function keyword arguments

    Returns:
        Tuple of (success: bool, result: Any, error: AppError or None)
    """
    try:
        result = operation_func(*args, **kwargs)
        return True, result, None

    except AppError as e:
        # Already structured error
        ErrorLogger.log_api_error(endpoint, method, e)
        return False, None, e

    except Exception as e:
        error = AppError(
            message=f'API operation failed: {endpoint}',
            error_code=ErrorCode.UNKNOWN,
            severity=ErrorSeverity.ERROR,
            original_error=e,
        )
        ErrorLogger.log_api_error(endpoint, method, e)
        return False, None, error


def format_error_response(error: AppError) -> Tuple[Dict, int]:
    """
    Format error for HTTP response

    Args:
        error: AppError instance

    Returns:
        Tuple of (response_body: Dict, http_status: int)
    """
    # Map error codes to HTTP status codes
    status_map = {
        ErrorCode.DB_CONNECTION.value: 503,
        ErrorCode.DB_QUERY_FAILED.value: 500,
        ErrorCode.DB_TIMEOUT.value: 504,
        ErrorCode.DB_NOT_FOUND.value: 404,
        ErrorCode.AUTH_MISSING.value: 401,
        ErrorCode.AUTH_TOKEN_EXPIRED.value: 401,
        ErrorCode.AUTH_INVALID_CREDENTIALS.value: 401,
        ErrorCode.AUTH_INSUFFICIENT_PERMISSIONS.value: 403,
        ErrorCode.VALIDATION_FAILED.value: 400,
        ErrorCode.API_NOT_FOUND.value: 404,
        ErrorCode.API_METHOD_NOT_ALLOWED.value: 405,
        ErrorCode.API_RATE_LIMITED.value: 429,
        ErrorCode.API_TIMEOUT.value: 504,
        ErrorCode.API_UNAVAILABLE.value: 503,
        ErrorCode.EXTERNAL_SERVICE_FAILED.value: 502,
        ErrorCode.EXTERNAL_SERVICE_TIMEOUT.value: 504,
        ErrorCode.EXTERNAL_SERVICE_UNAVAILABLE.value: 503,
    }

    http_status = status_map.get(error.error_code.value, 500)
    return error.to_dict(), http_status
