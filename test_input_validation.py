"""
Unit tests for Input Validation Module
"""

import unittest
from input_validation import (
    validate_email,
    validate_password,
    validate_url,
    validate_integer,
    validate_string,
    validate_date,
    validate_time,
    validate_phone,
    sanitize_string,
    validate_json,
    SchemaValidator,
    ValidationError,
)


class TestEmailValidation(unittest.TestCase):
    """Test email validation"""

    def test_valid_emails(self):
        """Test valid email addresses"""
        valid = [
            'user@example.com',
            'john.doe@company.co.uk',
            'admin+tag@site.org',
            'test123@test-domain.com',
        ]
        for email in valid:
            self.assertTrue(validate_email(email), f'{email} should be valid')

    def test_invalid_emails(self):
        """Test invalid email addresses"""
        invalid = [
            'user@',
            '@example.com',
            'user.example.com',
            'user@.com',
            'user @example.com',
            'user@example',
            '',
            'user@example..com',
        ]
        for email in invalid:
            self.assertFalse(validate_email(email), f'{email} should be invalid')

    def test_email_non_string(self):
        """Test email validation with non-string input"""
        self.assertFalse(validate_email(123))
        self.assertFalse(validate_email(None))
        self.assertFalse(validate_email([]))


class TestPasswordValidation(unittest.TestCase):
    """Test password validation"""

    def test_strong_passwords(self):
        """Test valid strong passwords"""
        valid = [
            'StrongPass123',
            'MyP@ssw0rd',
            'SecurePassword1',
        ]
        for password in valid:
            is_valid, msg = validate_password(password)
            self.assertTrue(is_valid, f'{password} should be valid: {msg}')

    def test_weak_passwords(self):
        """Test weak/invalid passwords"""
        invalid = [
            'short',           # Too short
            'nouppercase1',    # No uppercase
            'NOLOWERCASE1',    # No lowercase
            'NoNumbers',       # No digits
            '12345678',        # Only numbers
        ]
        for password in invalid:
            is_valid, msg = validate_password(password)
            self.assertFalse(is_valid, f'{password} should be invalid')

    def test_custom_min_length(self):
        """Test password with custom minimum length"""
        is_valid, msg = validate_password('Aa1', min_length=3)
        self.assertTrue(is_valid)

        is_valid, msg = validate_password('Aa1', min_length=10)
        self.assertFalse(is_valid)


class TestURLValidation(unittest.TestCase):
    """Test URL validation"""

    def test_valid_urls(self):
        """Test valid URLs"""
        valid = [
            'https://example.com',
            'http://example.com/path',
            'https://example.com/path?query=value',
            'http://localhost:8000',
        ]
        for url in valid:
            self.assertTrue(validate_url(url), f'{url} should be valid')

    def test_invalid_urls(self):
        """Test invalid URLs"""
        invalid = [
            'example.com',
            'htp://example.com',
            'https://',
            'https:/example.com',
        ]
        for url in invalid:
            self.assertFalse(validate_url(url), f'{url} should be invalid')


class TestIntegerValidation(unittest.TestCase):
    """Test integer validation"""

    def test_valid_integers(self):
        """Test valid integers"""
        self.assertTrue(validate_integer(0))
        self.assertTrue(validate_integer(42))
        self.assertTrue(validate_integer(-10))

    def test_invalid_integers(self):
        """Test invalid integers"""
        self.assertFalse(validate_integer('42'))
        self.assertFalse(validate_integer(42.5))
        self.assertFalse(validate_integer(True))
        self.assertFalse(validate_integer(None))

    def test_integer_range(self):
        """Test integer range validation"""
        self.assertTrue(validate_integer(5, min_val=0, max_val=10))
        self.assertFalse(validate_integer(15, min_val=0, max_val=10))
        self.assertFalse(validate_integer(-1, min_val=0, max_val=10))


class TestStringValidation(unittest.TestCase):
    """Test string validation"""

    def test_valid_strings(self):
        """Test valid strings"""
        self.assertTrue(validate_string('hello'))
        self.assertTrue(validate_string('a'))
        self.assertTrue(validate_string('hello world'))

    def test_invalid_strings(self):
        """Test invalid strings"""
        self.assertFalse(validate_string(''))
        self.assertFalse(validate_string(None))
        self.assertFalse(validate_string(123))

    def test_string_length_constraints(self):
        """Test string length constraints"""
        self.assertTrue(validate_string('hello', min_length=1, max_length=10))
        self.assertFalse(validate_string('hello', min_length=10))
        self.assertFalse(validate_string('hello world', max_length=5))


class TestDateValidation(unittest.TestCase):
    """Test date validation"""

    def test_valid_iso_dates(self):
        """Test valid ISO format dates"""
        valid = [
            '2026-02-27',
            '2000-01-01',
            '1999-12-31',
        ]
        for date in valid:
            self.assertTrue(validate_date(date), f'{date} should be valid')

    def test_valid_br_dates(self):
        """Test valid Brazilian format dates"""
        valid = [
            '27/02/2026',
            '01/01/2000',
            '31/12/1999',
        ]
        for date in valid:
            self.assertTrue(validate_date(date), f'{date} should be valid')

    def test_invalid_dates(self):
        """Test invalid dates"""
        invalid = [
            '2026-13-01',  # Invalid month
            '2026-02-30',  # Invalid day for February
            '27/13/2026',  # Invalid month
            '32/02/2026',  # Invalid day
            '2026/02/27',  # Wrong format
            '02-27-2026',  # Wrong format
        ]
        for date in invalid:
            self.assertFalse(validate_date(date), f'{date} should be invalid')


class TestTimeValidation(unittest.TestCase):
    """Test time validation"""

    def test_valid_times(self):
        """Test valid time formats"""
        valid = [
            '12:30',
            '00:00',
            '23:59',
            '12:30:45',
            '00:00:00',
        ]
        for time in valid:
            self.assertTrue(validate_time(time), f'{time} should be valid')

    def test_invalid_times(self):
        """Test invalid time formats"""
        invalid = [
            '24:00',
            '12:60',
            '12:30:60',
            '1:30',
            '12:3',
            '12:30:5',
        ]
        for time in invalid:
            self.assertFalse(validate_time(time), f'{time} should be invalid')


class TestPhoneValidation(unittest.TestCase):
    """Test phone number validation"""

    def test_valid_brazilian_phones(self):
        """Test valid Brazilian phone numbers"""
        valid = [
            '11999999999',      # São Paulo mobile
            '1199999999',       # São Paulo mobile
            '1133333333',       # São Paulo landline
            '(11) 99999-9999',  # Formatted
            '11 99999-9999',    # Formatted
            '+55 11 99999-9999',# With country code
        ]
        for phone in valid:
            self.assertTrue(validate_phone(phone), f'{phone} should be valid')

    def test_invalid_phones(self):
        """Test invalid phone numbers"""
        invalid = [
            '123',
            'abcdefghijk',
            '00999999999',  # Invalid area code
        ]
        for phone in invalid:
            self.assertFalse(validate_phone(phone), f'{phone} should be invalid')


class TestStringSanitization(unittest.TestCase):
    """Test string sanitization"""

    def test_sanitize_string(self):
        """Test string sanitization"""
        # Trim whitespace
        self.assertEqual(sanitize_string('  hello  '), 'hello')
        # Handle non-string
        self.assertEqual(sanitize_string(123), '')
        # Truncate to max length
        self.assertEqual(sanitize_string('hello world', max_length=5), 'hello')


class TestJSONValidation(unittest.TestCase):
    """Test JSON validation"""

    def test_valid_json(self):
        """Test valid JSON parsing"""
        valid_json = '{"key": "value"}'
        is_valid, parsed = validate_json(valid_json)
        self.assertTrue(is_valid)
        self.assertEqual(parsed['key'], 'value')

    def test_invalid_json(self):
        """Test invalid JSON"""
        invalid_json = '{"key": "value"'
        is_valid, parsed = validate_json(invalid_json)
        self.assertFalse(is_valid)
        self.assertIsNone(parsed)


class TestSchemaValidator(unittest.TestCase):
    """Test schema-based validation"""

    def setUp(self):
        """Set up test schema"""
        self.schema = {
            'email': {'type': 'email', 'required': True},
            'password': {'type': 'string', 'min_length': 8, 'required': True},
            'age': {'type': 'int', 'min': 0, 'max': 150},
            'birthdate': {'type': 'date'},
        }
        self.validator = SchemaValidator(self.schema)

    def test_valid_data(self):
        """Test validation of valid data"""
        data = {
            'email': 'user@example.com',
            'password': 'SecurePass123',
            'age': 30,
        }
        is_valid, error = self.validator.validate(data)
        self.assertTrue(is_valid, error)

    def test_missing_required_field(self):
        """Test validation fails for missing required field"""
        data = {
            'password': 'SecurePass123',
        }
        is_valid, error = self.validator.validate(data)
        self.assertFalse(is_valid)
        self.assertIn('Required field', error)

    def test_invalid_email_field(self):
        """Test validation fails for invalid email"""
        data = {
            'email': 'invalid-email',
            'password': 'SecurePass123',
        }
        is_valid, error = self.validator.validate(data)
        self.assertFalse(is_valid)
        self.assertIn('email', error)

    def test_optional_field_not_validated_if_missing(self):
        """Test that optional fields are not validated if missing"""
        data = {
            'email': 'user@example.com',
            'password': 'SecurePass123',
        }
        is_valid, error = self.validator.validate(data)
        self.assertTrue(is_valid)

    def test_optional_field_validated_if_present(self):
        """Test that optional fields are validated if present"""
        data = {
            'email': 'user@example.com',
            'password': 'SecurePass123',
            'age': 200,  # Over max
        }
        is_valid, error = self.validator.validate(data)
        self.assertFalse(is_valid)


class TestValidationEdgeCases(unittest.TestCase):
    """Test edge cases in validation"""

    def test_unicode_email(self):
        """Test email with unicode characters"""
        self.assertFalse(validate_email('usér@example.com'))

    def test_very_long_email(self):
        """Test very long email address"""
        long_email = 'a' * 100 + '@example.com'
        # Should still be technically valid format
        self.assertTrue(validate_email(long_email))

    def test_empty_password(self):
        """Test empty password"""
        is_valid, msg = validate_password('')
        self.assertFalse(is_valid)

    def test_sql_injection_string(self):
        """Test SQL injection attempt (should pass validation but be handled by app)"""
        # Validation should not prevent SQL injection - that's DB layer's job
        self.assertTrue(validate_string("'; DROP TABLE users; --"))


if __name__ == '__main__':
    unittest.main()
