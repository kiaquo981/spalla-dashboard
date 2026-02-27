"""
Input Validation Module
Provides schema validation and input sanitization for API endpoints
"""

import re
import json
from typing import Any, Dict, List, Optional, Tuple


class ValidationError(Exception):
    """Raised when validation fails"""
    def __init__(self, message: str, field: str = None):
        self.message = message
        self.field = field
        super().__init__(f'{field}: {message}' if field else message)


def validate_email(email: str) -> bool:
    """
    Validate email address format

    Args:
        email: Email address to validate

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(email, str):
        return False

    # RFC 5322 simplified email validation
    # Reject consecutive dots
    if '..' in email:
        return False

    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def validate_password(password: str, min_length: int = 8) -> Tuple[bool, str]:
    """
    Validate password strength

    Args:
        password: Password to validate
        min_length: Minimum required length (default: 8)

    Returns:
        Tuple of (is_valid, error_message)
    """
    if not isinstance(password, str):
        return False, 'Password must be a string'

    if len(password) < min_length:
        return False, f'Password must be at least {min_length} characters'

    # Check for at least one uppercase letter
    if not re.search(r'[A-Z]', password):
        return False, 'Password must contain at least one uppercase letter'

    # Check for at least one lowercase letter
    if not re.search(r'[a-z]', password):
        return False, 'Password must contain at least one lowercase letter'

    # Check for at least one digit
    if not re.search(r'\d', password):
        return False, 'Password must contain at least one digit'

    return True, ''


def validate_url(url: str) -> bool:
    """
    Validate URL format

    Args:
        url: URL to validate

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(url, str):
        return False

    pattern = r'^https?://[^\s/$.?#].[^\s]*$'
    return bool(re.match(pattern, url, re.IGNORECASE))


def validate_integer(value: Any, min_val: int = None, max_val: int = None) -> bool:
    """
    Validate integer value

    Args:
        value: Value to validate
        min_val: Minimum allowed value (optional)
        max_val: Maximum allowed value (optional)

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(value, int) or isinstance(value, bool):
        return False

    if min_val is not None and value < min_val:
        return False

    if max_val is not None and value > max_val:
        return False

    return True


def validate_string(value: Any, min_length: int = 1, max_length: int = None) -> bool:
    """
    Validate string value

    Args:
        value: Value to validate
        min_length: Minimum length (default: 1)
        max_length: Maximum length (optional)

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(value, str):
        return False

    if len(value) < min_length:
        return False

    if max_length is not None and len(value) > max_length:
        return False

    return True


def validate_date(date_string: str) -> bool:
    """
    Validate ISO 8601 date format (YYYY-MM-DD or DD/MM/YYYY)

    Args:
        date_string: Date string to validate

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(date_string, str):
        return False

    # ISO format: YYYY-MM-DD
    if re.match(r'^\d{4}-\d{2}-\d{2}$', date_string):
        try:
            from datetime import datetime
            datetime.strptime(date_string, '%Y-%m-%d')
            return True
        except ValueError:
            return False

    # Brazilian format: DD/MM/YYYY
    if re.match(r'^\d{2}/\d{2}/\d{4}$', date_string):
        try:
            from datetime import datetime
            datetime.strptime(date_string, '%d/%m/%Y')
            return True
        except ValueError:
            return False

    return False


def validate_time(time_string: str) -> bool:
    """
    Validate time format (HH:MM or HH:MM:SS)

    Args:
        time_string: Time string to validate

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(time_string, str):
        return False

    # HH:MM:SS format
    if re.match(r'^([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$', time_string):
        return True

    # HH:MM format
    if re.match(r'^([0-1]\d|2[0-3]):[0-5]\d$', time_string):
        return True

    return False


def validate_phone(phone: str) -> bool:
    """
    Validate Brazilian phone number

    Args:
        phone: Phone number to validate

    Returns:
        True if valid, False otherwise
    """
    if not isinstance(phone, str):
        return False

    # Remove common separators
    cleaned = re.sub(r'[\s\-().]', '', phone)

    # Brazilian phone: +55 or 55 or nothing, then 11 digits (2 area + 9 number)
    pattern = r'^(\+?55)?[1-9]{2}9?[0-9]{8}$'
    return bool(re.match(pattern, cleaned))


def sanitize_string(value: str, max_length: int = None) -> str:
    """
    Sanitize string input (remove/escape dangerous characters)

    Args:
        value: String to sanitize
        max_length: Maximum length to truncate to (optional)

    Returns:
        Sanitized string
    """
    if not isinstance(value, str):
        return ''

    # Strip whitespace
    value = value.strip()

    # Truncate if needed
    if max_length and len(value) > max_length:
        value = value[:max_length]

    return value


def validate_json(data: str) -> Tuple[bool, Optional[Dict]]:
    """
    Validate and parse JSON

    Args:
        data: JSON string to validate

    Returns:
        Tuple of (is_valid, parsed_dict_or_none)
    """
    if not isinstance(data, str):
        return False, None

    try:
        parsed = json.loads(data)
        return True, parsed
    except json.JSONDecodeError:
        return False, None


class SchemaValidator:
    """Schema validator for API request bodies"""

    def __init__(self, schema: Dict[str, Dict]):
        """
        Initialize validator with schema

        Args:
            schema: Schema definition
                Example:
                {
                    'email': {'type': 'email', 'required': True},
                    'age': {'type': 'int', 'min': 0, 'max': 150},
                    'name': {'type': 'string', 'min_length': 1, 'max_length': 100},
                }
        """
        self.schema = schema

    def validate(self, data: Dict) -> Tuple[bool, Optional[str]]:
        """
        Validate data against schema

        Args:
            data: Data to validate

        Returns:
            Tuple of (is_valid, error_message_or_none)
        """
        if not isinstance(data, dict):
            return False, 'Data must be a dictionary'

        for field, rules in self.schema.items():
            # Check required fields
            if rules.get('required', False) and field not in data:
                return False, f'Required field missing: {field}'

            # Skip validation if field is missing and not required
            if field not in data:
                continue

            value = data[field]
            field_type = rules.get('type')

            # Type-specific validation
            if field_type == 'email':
                if not validate_email(value):
                    return False, f'Invalid email format: {field}'

            elif field_type == 'string':
                min_len = rules.get('min_length', 1)
                max_len = rules.get('max_length')
                if not validate_string(value, min_len, max_len):
                    return False, f'Invalid string: {field} (length {min_len}-{max_len})'

            elif field_type == 'int':
                min_val = rules.get('min')
                max_val = rules.get('max')
                if not validate_integer(value, min_val, max_val):
                    return False, f'Invalid integer: {field}'

            elif field_type == 'date':
                if not validate_date(value):
                    return False, f'Invalid date format: {field}'

            elif field_type == 'time':
                if not validate_time(value):
                    return False, f'Invalid time format: {field}'

            elif field_type == 'phone':
                if not validate_phone(value):
                    return False, f'Invalid phone number: {field}'

        return True, None
