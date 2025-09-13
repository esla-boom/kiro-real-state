# Database Security Implementation Guide

## Overview

This document describes the comprehensive security implementation for the Real Estate Dashboard database. The security system includes role-based access control, row-level security, data encryption, and audit logging.

## Security Features Implemented

### 1. Database Roles and Permissions

Four distinct roles have been created with different access levels:

#### `re_admin` - System Administrator
- **Full access** to all tables, sequences, and functions
- Can create and manage other database roles
- Can access all data across all agents and properties
- Can manage encryption keys and security policies

#### `re_manager` - Real Estate Manager
- **Read/Write access** to all business data tables
- **Read-only access** to activity logs (cannot modify audit trail)
- Can view all agents' data for management oversight
- Cannot manage database roles or security settings

#### `re_agent` - Real Estate Agent
- **Limited access** to only their own data
- Can view other agents (for referrals) but cannot modify their data
- Can access properties, clients, appointments, documents, and transactions they own
- Cannot access other agents' confidential data

#### `re_readonly` - Reports and Analytics
- **Read-only access** to all tables for reporting purposes
- Cannot modify any data
- Ideal for business intelligence tools and reporting systems

### 2. Row-Level Security (RLS)

Row-Level Security is enabled on all sensitive tables to ensure data isolation:

- **Users**: Agents can only update their own profile
- **Properties**: Agents can only access properties they manage
- **Clients**: Agents can only access their own clients
- **Appointments**: Agents can only see their own appointments
- **Documents**: Agents can access documents they uploaded or that belong to their properties/clients
- **Transactions**: Agents can only see their own financial transactions
- **Activity Logs**: Agents can only see their own activity history

### 3. Data Encryption

Sensitive data encryption is implemented using PostgreSQL's `pgcrypto` extension:

#### Encryption Functions
- `encrypt_sensitive_data(TEXT)` - Encrypts sensitive text data
- `decrypt_sensitive_data(BYTEA)` - Decrypts encrypted data
- Master encryption key management through `encryption_keys` table

#### Usage Example
```sql
-- Encrypt sensitive client notes
UPDATE clients 
SET notes = encrypt_sensitive_data('Confidential client information')
WHERE client_id = 'some-uuid';

-- Decrypt when needed
SELECT decrypt_sensitive_data(notes) as decrypted_notes
FROM clients 
WHERE client_id = 'some-uuid';
```

### 4. Enhanced Audit Logging

Comprehensive audit logging captures all data modifications:

#### Logged Information
- User ID and session information
- Action type (INSERT, UPDATE, DELETE)
- Entity type and ID
- Old and new values (JSON format)
- IP address and user agent
- Timestamp

#### Security-Specific Triggers
All sensitive tables have audit triggers that automatically log:
- Data modifications
- Access attempts
- Security policy violations

### 5. Password Security

Strong password policies are enforced:

#### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character

#### Security Functions
- `validate_password_strength(TEXT)` - Validates password complexity
- `hash_password(TEXT)` - Securely hashes passwords using bcrypt
- `verify_password(TEXT, TEXT)` - Verifies passwords against stored hashes

## Implementation Instructions

### 1. Initial Setup

1. **Create the base schema**:
   ```sql
   \i schema.sql
   ```

2. **Apply security measures**:
   ```sql
   \i security.sql
   ```

### 2. User Management

#### Creating Database Users

```sql
-- Create a new agent user
CREATE USER agent_john WITH PASSWORD 'SecurePassword123!';
GRANT re_agent TO agent_john;

-- Create a manager user
CREATE USER manager_sarah WITH PASSWORD 'ManagerPass456!';
GRANT re_manager TO manager_sarah;
```

#### Setting User Context for RLS

Before performing operations, set the user context:

```sql
-- Set context for current user session
SELECT set_current_user_context(
    'user-uuid-here'::UUID,
    'session-id-here',
    'Mozilla/5.0...'
);
```

### 3. Application Integration

#### Connection String Examples

```python
# Python example with different roles
admin_conn = psycopg2.connect(
    host="localhost",
    database="realestate",
    user="admin_user",
    password="admin_password"
)

agent_conn = psycopg2.connect(
    host="localhost", 
    database="realestate",
    user="agent_john",
    password="agent_password"
)
```

#### Setting Session Context

```python
# Set user context after connection
cursor.execute("""
    SELECT set_current_user_context(%s, %s, %s)
""", (user_id, session_id, user_agent))
```

### 4. Security Monitoring

#### Monitor Failed Login Attempts

```sql
SELECT * FROM security_failed_logins 
WHERE daily_attempts > 5
ORDER BY created_at DESC;
```

#### Check Suspicious Activities

```sql
SELECT * FROM security_suspicious_activities
WHERE daily_count > 10
ORDER BY created_at DESC;
```

#### View Security Configuration

```sql
SELECT * FROM security_configuration;
```

### 5. Data Encryption Usage

#### Encrypting Sensitive Data

```sql
-- Encrypt client notes during insert
INSERT INTO clients (first_name, last_name, email, notes, agent_id)
VALUES (
    'John', 
    'Doe', 
    'john@example.com',
    encrypt_sensitive_data('Sensitive client information'),
    'agent-uuid'
);
```

#### Querying Encrypted Data

```sql
-- Decrypt data for authorized users
SELECT 
    first_name,
    last_name,
    email,
    decrypt_sensitive_data(notes) as notes
FROM clients 
WHERE agent_id = current_setting('app.current_user_id')::uuid;
```

## Security Best Practices

### 1. Connection Security
- Use SSL/TLS connections in production
- Implement connection pooling with proper authentication
- Rotate database passwords regularly

### 2. Application Security
- Always set user context before database operations
- Validate user permissions at application level
- Implement session management and timeout policies

### 3. Data Protection
- Encrypt sensitive data at rest and in transit
- Implement proper backup encryption
- Use secure key management practices

### 4. Monitoring and Auditing
- Regularly review audit logs for suspicious activities
- Monitor failed login attempts and implement lockout policies
- Set up alerts for unusual data access patterns

### 5. Maintenance
- Regularly run cleanup functions for old audit logs
- Update encryption keys periodically
- Review and update security policies as needed

## Troubleshooting

### Common Issues

#### RLS Policy Violations
```
ERROR: new row violates row-level security policy
```
**Solution**: Ensure user context is properly set and user has appropriate permissions.

#### Encryption Key Not Found
```
ERROR: Master encryption key not found
```
**Solution**: Verify encryption keys table has active master key.

#### Permission Denied
```
ERROR: permission denied for table
```
**Solution**: Check user role assignments and table permissions.

### Debugging Commands

```sql
-- Check current user context
SELECT current_setting('app.current_user_id', true);

-- View user's effective permissions
SELECT * FROM information_schema.table_privileges 
WHERE grantee = current_user;

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'your_table';
```

## Security Compliance

This implementation addresses common security requirements:

- **GDPR**: Data encryption and audit logging for personal data
- **SOX**: Financial transaction audit trails and access controls
- **HIPAA**: (if applicable) Encryption and access logging for sensitive data
- **PCI DSS**: (if applicable) Secure data handling and access controls

## Maintenance Schedule

### Daily
- Monitor failed login attempts
- Review suspicious activity alerts

### Weekly  
- Review audit logs for unusual patterns
- Check security monitoring views

### Monthly
- Run cleanup functions for old logs
- Review user access permissions
- Update security documentation

### Quarterly
- Rotate encryption keys
- Review and update security policies
- Conduct security assessment

## Support and Documentation

For additional security questions or issues:

1. Review PostgreSQL security documentation
2. Check audit logs for specific error details
3. Consult with database security team
4. Update security policies as business requirements change

---

**Important**: This security implementation provides a robust foundation, but should be regularly reviewed and updated based on evolving security requirements and threat landscape.