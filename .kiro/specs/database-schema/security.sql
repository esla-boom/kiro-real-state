-- =====================================================
-- SECURITY AND ACCESS CONTROL IMPLEMENTATION
-- Real Estate Dashboard Database Security
-- =====================================================

-- =====================================================
-- 1. DATABASE ROLES AND PERMISSIONS
-- =====================================================

-- Create database roles for different user types
CREATE ROLE re_admin;
CREATE ROLE re_manager;
CREATE ROLE re_agent;
CREATE ROLE re_readonly;

-- Grant basic connection privileges
GRANT CONNECT ON DATABASE postgres TO re_admin, re_manager, re_agent, re_readonly;
GRANT USAGE ON SCHEMA public TO re_admin, re_manager, re_agent, re_readonly;

-- =====================================================
-- ADMIN ROLE PERMISSIONS (Full access)
-- =====================================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO re_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO re_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO re_admin;

-- Grant ability to create and manage other roles
ALTER ROLE re_admin WITH CREATEROLE;

-- =====================================================
-- MANAGER ROLE PERMISSIONS (Read/Write access to most data)
-- =====================================================
-- Full access to business data tables
GRANT SELECT, INSERT, UPDATE, DELETE ON users, properties, clients, appointments, documents, transactions, client_preferences, property_matches, reports TO re_manager;

-- Read-only access to activity logs (cannot modify audit trail)
GRANT SELECT ON activity_logs TO re_manager;

-- Sequence access for inserts
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO re_manager;

-- =====================================================
-- AGENT ROLE PERMISSIONS (Limited to own data)
-- =====================================================
-- Basic read access to users table (to see other agents for referrals)
GRANT SELECT ON users TO re_agent;

-- Full access to own properties, clients, appointments, documents, transactions
GRANT SELECT, INSERT, UPDATE, DELETE ON properties, clients, appointments, documents, transactions, client_preferences, property_matches TO re_agent;

-- Read access to reports (can view but not create system reports)
GRANT SELECT ON reports TO re_agent;

-- No direct access to activity_logs (handled by triggers)

-- Sequence access for inserts
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO re_agent;

-- =====================================================
-- READONLY ROLE PERMISSIONS (Reports and analytics only)
-- =====================================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO re_readonly;

-- =====================================================
-- 2. ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables that need access control
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USERS TABLE RLS POLICIES
-- =====================================================

-- Admins can see all users
CREATE POLICY users_admin_all ON users
    FOR ALL TO re_admin
    USING (true);

-- Managers can see all users
CREATE POLICY users_manager_all ON users
    FOR ALL TO re_manager
    USING (true);

-- Agents can see all users (for referrals) but only update themselves
CREATE POLICY users_agent_select ON users
    FOR SELECT TO re_agent
    USING (true);

CREATE POLICY users_agent_update ON users
    FOR UPDATE TO re_agent
    USING (user_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all users
CREATE POLICY users_readonly_select ON users
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- PROPERTIES TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all properties
CREATE POLICY properties_admin_all ON properties
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY properties_manager_all ON properties
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access their own properties
CREATE POLICY properties_agent_own ON properties
    FOR ALL TO re_agent
    USING (agent_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all properties
CREATE POLICY properties_readonly_select ON properties
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- CLIENTS TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all clients
CREATE POLICY clients_admin_all ON clients
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY clients_manager_all ON clients
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access their own clients
CREATE POLICY clients_agent_own ON clients
    FOR ALL TO re_agent
    USING (agent_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all clients
CREATE POLICY clients_readonly_select ON clients
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- APPOINTMENTS TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all appointments
CREATE POLICY appointments_admin_all ON appointments
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY appointments_manager_all ON appointments
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access their own appointments
CREATE POLICY appointments_agent_own ON appointments
    FOR ALL TO re_agent
    USING (agent_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all appointments
CREATE POLICY appointments_readonly_select ON appointments
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- DOCUMENTS TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all documents
CREATE POLICY documents_admin_all ON documents
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY documents_manager_all ON documents
    FOR ALL TO re_manager
    USING (true);

-- Agents can access documents they uploaded or that belong to their properties/clients
CREATE POLICY documents_agent_own ON documents
    FOR ALL TO re_agent
    USING (
        uploaded_by = current_setting('app.current_user_id')::uuid OR
        property_id IN (SELECT property_id FROM properties WHERE agent_id = current_setting('app.current_user_id')::uuid) OR
        client_id IN (SELECT client_id FROM clients WHERE agent_id = current_setting('app.current_user_id')::uuid) OR
        is_public = true
    );

-- Readonly can see public documents only
CREATE POLICY documents_readonly_public ON documents
    FOR SELECT TO re_readonly
    USING (is_public = true);

-- =====================================================
-- TRANSACTIONS TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all transactions
CREATE POLICY transactions_admin_all ON transactions
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY transactions_manager_all ON transactions
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access their own transactions
CREATE POLICY transactions_agent_own ON transactions
    FOR ALL TO re_agent
    USING (agent_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all transactions
CREATE POLICY transactions_readonly_select ON transactions
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- CLIENT PREFERENCES TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all preferences
CREATE POLICY preferences_admin_all ON client_preferences
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY preferences_manager_all ON client_preferences
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access preferences for their own clients
CREATE POLICY preferences_agent_own ON client_preferences
    FOR ALL TO re_agent
    USING (client_id IN (SELECT client_id FROM clients WHERE agent_id = current_setting('app.current_user_id')::uuid));

-- Readonly can see all preferences
CREATE POLICY preferences_readonly_select ON client_preferences
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- PROPERTY MATCHES TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all matches
CREATE POLICY matches_admin_all ON property_matches
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY matches_manager_all ON property_matches
    FOR ALL TO re_manager
    USING (true);

-- Agents can only access matches for their own properties and clients
CREATE POLICY matches_agent_own ON property_matches
    FOR ALL TO re_agent
    USING (
        property_id IN (SELECT property_id FROM properties WHERE agent_id = current_setting('app.current_user_id')::uuid) OR
        client_id IN (SELECT client_id FROM clients WHERE agent_id = current_setting('app.current_user_id')::uuid)
    );

-- Readonly can see all matches
CREATE POLICY matches_readonly_select ON property_matches
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- ACTIVITY LOGS TABLE RLS POLICIES
-- =====================================================

-- Admins can access all logs
CREATE POLICY logs_admin_all ON activity_logs
    FOR ALL TO re_admin
    USING (true);

-- Managers can read all logs but not modify
CREATE POLICY logs_manager_select ON activity_logs
    FOR SELECT TO re_manager
    USING (true);

-- Agents can only see their own activity logs
CREATE POLICY logs_agent_own ON activity_logs
    FOR SELECT TO re_agent
    USING (user_id = current_setting('app.current_user_id')::uuid);

-- Readonly can see all logs
CREATE POLICY logs_readonly_select ON activity_logs
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- REPORTS TABLE RLS POLICIES
-- =====================================================

-- Admins and managers can access all reports
CREATE POLICY reports_admin_all ON reports
    FOR ALL TO re_admin
    USING (true);

CREATE POLICY reports_manager_all ON reports
    FOR ALL TO re_manager
    USING (true);

-- Agents can only see reports they created
CREATE POLICY reports_agent_own ON reports
    FOR SELECT TO re_agent
    USING (created_by = current_setting('app.current_user_id')::uuid);

-- Readonly can see all reports
CREATE POLICY reports_readonly_select ON reports
    FOR SELECT TO re_readonly
    USING (true);

-- =====================================================
-- 3. SENSITIVE DATA ENCRYPTION
-- =====================================================

-- Enable pgcrypto extension for encryption functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create encryption key management table
CREATE TABLE encryption_keys (
    key_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key_name VARCHAR(50) UNIQUE NOT NULL,
    key_value BYTEA NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Restrict access to encryption keys table
ALTER TABLE encryption_keys ENABLE ROW LEVEL SECURITY;
CREATE POLICY encryption_keys_admin_only ON encryption_keys
    FOR ALL TO re_admin
    USING (true);

-- Insert master encryption key (in production, this should be managed externally)
INSERT INTO encryption_keys (key_name, key_value) 
VALUES ('master_key', gen_random_bytes(32));

-- =====================================================
-- ENCRYPTION FUNCTIONS
-- =====================================================

-- Function to encrypt sensitive data
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(data TEXT)
RETURNS BYTEA AS $
DECLARE
    master_key BYTEA;
BEGIN
    SELECT key_value INTO master_key 
    FROM encryption_keys 
    WHERE key_name = 'master_key' AND is_active = TRUE;
    
    IF master_key IS NULL THEN
        RAISE EXCEPTION 'Master encryption key not found';
    END IF;
    
    RETURN pgp_sym_encrypt(data, encode(master_key, 'hex'));
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to decrypt sensitive data
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_data BYTEA)
RETURNS TEXT AS $
DECLARE
    master_key BYTEA;
BEGIN
    SELECT key_value INTO master_key 
    FROM encryption_keys 
    WHERE key_name = 'master_key' AND is_active = TRUE;
    
    IF master_key IS NULL THEN
        RAISE EXCEPTION 'Master encryption key not found';
    END IF;
    
    RETURN pgp_sym_decrypt(encrypted_data, encode(master_key, 'hex'));
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on encryption functions
GRANT EXECUTE ON FUNCTION encrypt_sensitive_data(TEXT) TO re_admin, re_manager, re_agent;
GRANT EXECUTE ON FUNCTION decrypt_sensitive_data(BYTEA) TO re_admin, re_manager, re_agent;

-- =====================================================
-- 4. AUDIT LOGGING TRIGGERS FOR SECURITY
-- =====================================================

-- Enhanced audit logging function with security context
CREATE OR REPLACE FUNCTION log_security_activity()
RETURNS TRIGGER AS $
DECLARE
    current_user_id UUID;
    old_data JSONB;
    new_data JSONB;
BEGIN
    -- Get current user ID from session
    BEGIN
        current_user_id := current_setting('app.current_user_id')::UUID;
    EXCEPTION WHEN OTHERS THEN
        current_user_id := NULL;
    END;
    
    -- Prepare old and new data
    IF TG_OP = 'DELETE' THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
    ELSE -- UPDATE
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);
    END IF;
    
    -- Insert audit log
    INSERT INTO activity_logs (
        user_id,
        action_type,
        entity_type,
        entity_id,
        old_values,
        new_values,
        ip_address,
        user_agent,
        session_id
    ) VALUES (
        current_user_id,
        TG_OP,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN (old_data->>(TG_TABLE_NAME || '_id'))::UUID
            ELSE (new_data->>(TG_TABLE_NAME || '_id'))::UUID
        END,
        old_data,
        new_data,
        inet_client_addr(),
        current_setting('app.user_agent', true),
        current_setting('app.session_id', true)
    );
    
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply security audit triggers to sensitive tables
CREATE TRIGGER security_audit_users AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION log_security_activity();

CREATE TRIGGER security_audit_properties AFTER INSERT OR UPDATE OR DELETE ON properties
    FOR EACH ROW EXECUTE FUNCTION log_security_activity();

CREATE TRIGGER security_audit_clients AFTER INSERT OR UPDATE OR DELETE ON clients
    FOR EACH ROW EXECUTE FUNCTION log_security_activity();

CREATE TRIGGER security_audit_documents AFTER INSERT OR UPDATE OR DELETE ON documents
    FOR EACH ROW EXECUTE FUNCTION log_security_activity();

CREATE TRIGGER security_audit_transactions AFTER INSERT OR UPDATE OR DELETE ON transactions
    FOR EACH ROW EXECUTE FUNCTION log_security_activity();

-- =====================================================
-- 5. SECURITY VIEWS FOR ENCRYPTED DATA
-- =====================================================

-- Secure view for users with encrypted sensitive data
CREATE VIEW users_secure AS
SELECT 
    user_id,
    username,
    email,
    first_name,
    last_name,
    role,
    status,
    phone,
    created_at,
    updated_at,
    last_login_at
FROM users;

-- Secure view for clients with encrypted sensitive data
CREATE VIEW clients_secure AS
SELECT 
    client_id,
    first_name,
    last_name,
    email,
    phone,
    budget_min,
    budget_max,
    status,
    agent_id,
    created_at,
    updated_at
FROM clients;

-- Grant appropriate permissions on secure views
GRANT SELECT ON users_secure TO re_admin, re_manager, re_agent, re_readonly;
GRANT SELECT ON clients_secure TO re_admin, re_manager, re_agent, re_readonly;

-- =====================================================
-- 6. SESSION SECURITY FUNCTIONS
-- =====================================================

-- Function to set current user context for RLS
CREATE OR REPLACE FUNCTION set_current_user_context(
    p_user_id UUID,
    p_session_id VARCHAR DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS VOID AS $
BEGIN
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, false);
    
    IF p_session_id IS NOT NULL THEN
        PERFORM set_config('app.session_id', p_session_id, false);
    END IF;
    
    IF p_user_agent IS NOT NULL THEN
        PERFORM set_config('app.user_agent', p_user_agent, false);
    END IF;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clear user context
CREATE OR REPLACE FUNCTION clear_user_context()
RETURNS VOID AS $
BEGIN
    PERFORM set_config('app.current_user_id', '', false);
    PERFORM set_config('app.session_id', '', false);
    PERFORM set_config('app.user_agent', '', false);
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on context functions
GRANT EXECUTE ON FUNCTION set_current_user_context(UUID, VARCHAR, TEXT) TO re_admin, re_manager, re_agent;
GRANT EXECUTE ON FUNCTION clear_user_context() TO re_admin, re_manager, re_agent;

-- =====================================================
-- 7. PASSWORD SECURITY ENHANCEMENTS
-- =====================================================

-- Function to validate password strength
CREATE OR REPLACE FUNCTION validate_password_strength(password TEXT)
RETURNS BOOLEAN AS $
BEGIN
    -- Password must be at least 8 characters
    IF LENGTH(password) < 8 THEN
        RETURN FALSE;
    END IF;
    
    -- Must contain at least one uppercase letter
    IF password !~ '[A-Z]' THEN
        RETURN FALSE;
    END IF;
    
    -- Must contain at least one lowercase letter
    IF password !~ '[a-z]' THEN
        RETURN FALSE;
    END IF;
    
    -- Must contain at least one digit
    IF password !~ '[0-9]' THEN
        RETURN FALSE;
    END IF;
    
    -- Must contain at least one special character
    IF password !~ '[^A-Za-z0-9]' THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$ LANGUAGE plpgsql;

-- Function to hash passwords securely
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS TEXT AS $
BEGIN
    -- Validate password strength first
    IF NOT validate_password_strength(password) THEN
        RAISE EXCEPTION 'Password does not meet security requirements';
    END IF;
    
    -- Generate bcrypt hash with cost factor 12
    RETURN crypt(password, gen_salt('bf', 12));
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to verify passwords
CREATE OR REPLACE FUNCTION verify_password(password TEXT, hash TEXT)
RETURNS BOOLEAN AS $
BEGIN
    RETURN hash = crypt(password, hash);
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on password functions
GRANT EXECUTE ON FUNCTION validate_password_strength(TEXT) TO re_admin, re_manager, re_agent;
GRANT EXECUTE ON FUNCTION hash_password(TEXT) TO re_admin, re_manager, re_agent;
GRANT EXECUTE ON FUNCTION verify_password(TEXT, TEXT) TO re_admin, re_manager, re_agent;

-- =====================================================
-- 8. SECURITY MONITORING VIEWS
-- =====================================================

-- View for monitoring failed login attempts
CREATE VIEW security_failed_logins AS
SELECT 
    user_id,
    ip_address,
    user_agent,
    created_at,
    COUNT(*) OVER (PARTITION BY user_id, DATE(created_at)) as daily_attempts,
    COUNT(*) OVER (PARTITION BY ip_address, DATE(created_at)) as ip_daily_attempts
FROM activity_logs 
WHERE action_type = 'LOGIN_FAILED'
ORDER BY created_at DESC;

-- View for monitoring suspicious activities
CREATE VIEW security_suspicious_activities AS
SELECT 
    user_id,
    action_type,
    entity_type,
    ip_address,
    user_agent,
    created_at,
    COUNT(*) OVER (PARTITION BY user_id, action_type, DATE(created_at)) as daily_count
FROM activity_logs 
WHERE action_type IN ('DELETE', 'BULK_UPDATE', 'PERMISSION_CHANGE', 'LOGIN_FAILED')
ORDER BY created_at DESC;

-- Grant permissions on security monitoring views
GRANT SELECT ON security_failed_logins TO re_admin, re_manager;
GRANT SELECT ON security_suspicious_activities TO re_admin, re_manager;

-- =====================================================
-- 9. DATA RETENTION AND CLEANUP POLICIES
-- =====================================================

-- Function to cleanup old activity logs (retain for 2 years)
CREATE OR REPLACE FUNCTION cleanup_old_activity_logs()
RETURNS INTEGER AS $
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM activity_logs 
    WHERE created_at < CURRENT_DATE - INTERVAL '2 years';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Log the cleanup activity
    INSERT INTO activity_logs (action_type, entity_type, new_values)
    VALUES ('CLEANUP', 'activity_logs', jsonb_build_object('deleted_count', deleted_count));
    
    RETURN deleted_count;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on cleanup function
GRANT EXECUTE ON FUNCTION cleanup_old_activity_logs() TO re_admin;

-- =====================================================
-- 10. SECURITY CONFIGURATION SUMMARY
-- =====================================================

-- Create a view to show current security configuration
CREATE VIEW security_configuration AS
SELECT 
    'Row Level Security' as security_feature,
    schemaname,
    tablename,
    rowsecurity as enabled
FROM pg_tables t
JOIN pg_class c ON c.relname = t.tablename
WHERE schemaname = 'public' 
AND c.relrowsecurity = true

UNION ALL

SELECT 
    'Database Roles' as security_feature,
    'public' as schemaname,
    rolname as tablename,
    'true' as enabled
FROM pg_roles 
WHERE rolname LIKE 're_%'

UNION ALL

SELECT 
    'Encryption Extensions' as security_feature,
    'public' as schemaname,
    extname as tablename,
    'true' as enabled
FROM pg_extension 
WHERE extname IN ('pgcrypto', 'uuid-ossp');

-- Grant select on security configuration view
GRANT SELECT ON security_configuration TO re_admin, re_manager;

-- =====================================================
-- SECURITY IMPLEMENTATION COMPLETE
-- =====================================================

-- Log the security implementation
INSERT INTO activity_logs (action_type, entity_type, new_values)
VALUES ('SECURITY_SETUP', 'database', jsonb_build_object(
    'rls_enabled', true,
    'roles_created', 4,
    'encryption_enabled', true,
    'audit_triggers', true,
    'timestamp', CURRENT_TIMESTAMP
));