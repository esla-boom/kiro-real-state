-- =====================================================
-- SECURITY DEPLOYMENT SCRIPT
-- Real Estate Dashboard Database Security Deployment
-- =====================================================

-- This script demonstrates the proper deployment sequence for
-- implementing security measures in the Real Estate Dashboard database

\echo 'Starting security deployment...'

-- =====================================================
-- 1. VERIFY PREREQUISITES
-- =====================================================

\echo 'Checking prerequisites...'

-- Verify required extensions are available
DO $
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'pgcrypto') THEN
        RAISE EXCEPTION 'pgcrypto extension is not available';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'uuid-ossp') THEN
        RAISE EXCEPTION 'uuid-ossp extension is not available';
    END IF;
    
    RAISE NOTICE 'Prerequisites check passed';
END
$;

-- =====================================================
-- 2. CREATE SAMPLE USERS FOR TESTING
-- =====================================================

\echo 'Creating sample database users...'

-- Create sample users (in production, use proper password management)
DO $
BEGIN
    -- Create admin user
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'admin_user') THEN
        CREATE USER admin_user WITH PASSWORD 'AdminPass123!';
        RAISE NOTICE 'Created admin_user';
    END IF;
    
    -- Create manager user  
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'manager_user') THEN
        CREATE USER manager_user WITH PASSWORD 'ManagerPass123!';
        RAISE NOTICE 'Created manager_user';
    END IF;
    
    -- Create agent users
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'agent_john') THEN
        CREATE USER agent_john WITH PASSWORD 'AgentPass123!';
        RAISE NOTICE 'Created agent_john';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'agent_sarah') THEN
        CREATE USER agent_sarah WITH PASSWORD 'AgentPass123!';
        RAISE NOTICE 'Created agent_sarah';
    END IF;
    
    -- Create readonly user
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'readonly_user') THEN
        CREATE USER readonly_user WITH PASSWORD 'ReadonlyPass123!';
        RAISE NOTICE 'Created readonly_user';
    END IF;
END
$;

-- =====================================================
-- 3. APPLY SECURITY CONFIGURATION
-- =====================================================

\echo 'Applying security configuration from security.sql...'

-- Include the main security configuration
\i security.sql

-- =====================================================
-- 4. ASSIGN ROLES TO USERS
-- =====================================================

\echo 'Assigning roles to users...'

-- Assign roles to sample users
GRANT re_admin TO admin_user;
GRANT re_manager TO manager_user;
GRANT re_agent TO agent_john;
GRANT re_agent TO agent_sarah;
GRANT re_readonly TO readonly_user;

\echo 'Role assignments completed'

-- =====================================================
-- 5. CREATE SAMPLE DATA WITH PROPER SECURITY CONTEXT
-- =====================================================

\echo 'Creating sample data with security context...'

-- Get user IDs for context setting
DO $
DECLARE
    admin_id UUID;
    agent_john_id UUID;
    agent_sarah_id UUID;
BEGIN
    -- Get admin user ID
    SELECT user_id INTO admin_id FROM users WHERE username = 'admin';
    
    -- Insert additional sample agents
    INSERT INTO users (username, email, password_hash, first_name, last_name, role)
    VALUES 
        ('john_agent', 'john@realestate.com', hash_password('AgentPass123!'), 'John', 'Smith', 'agent'),
        ('sarah_agent', 'sarah@realestate.com', hash_password('AgentPass123!'), 'Sarah', 'Johnson', 'agent')
    ON CONFLICT (username) DO NOTHING;
    
    -- Get agent IDs
    SELECT user_id INTO agent_john_id FROM users WHERE username = 'john_agent';
    SELECT user_id INTO agent_sarah_id FROM users WHERE username = 'sarah_agent';
    
    -- Set context for John and create his data
    PERFORM set_current_user_context(agent_john_id, 'sample-session-1', 'Security-Deployment-Script');
    
    -- Insert sample property for John
    INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, agent_id)
    VALUES (
        'Modern Downtown Apartment',
        'Beautiful 2-bedroom apartment in the heart of downtown',
        '123 Main Street, Downtown',
        40.7128,
        -74.0060,
        450000.00,
        85.5,
        2,
        2,
        'apartment',
        agent_john_id
    );
    
    -- Insert sample client for John
    INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, agent_id)
    VALUES (
        'Michael',
        'Brown',
        'michael.brown@email.com',
        '+1-555-0123',
        400000.00,
        500000.00,
        agent_john_id
    );
    
    -- Set context for Sarah and create her data
    PERFORM set_current_user_context(agent_sarah_id, 'sample-session-2', 'Security-Deployment-Script');
    
    -- Insert sample property for Sarah
    INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, agent_id)
    VALUES (
        'Suburban Family Home',
        'Spacious 4-bedroom house perfect for families',
        '456 Oak Avenue, Suburbs',
        40.7589,
        -73.9851,
        650000.00,
        150.0,
        4,
        3,
        'house',
        agent_sarah_id
    );
    
    -- Insert sample client for Sarah
    INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, agent_id)
    VALUES (
        'Jennifer',
        'Davis',
        'jennifer.davis@email.com',
        '+1-555-0456',
        600000.00,
        700000.00,
        agent_sarah_id
    );
    
    -- Clear context
    PERFORM clear_user_context();
    
    RAISE NOTICE 'Sample data created with proper security context';
END
$;

-- =====================================================
-- 6. SECURITY VALIDATION TESTS
-- =====================================================

\echo 'Running security validation tests...'

-- Test 1: Verify RLS is enabled
DO $
DECLARE
    rls_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO rls_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' 
    AND c.relkind = 'r'
    AND c.relrowsecurity = true;
    
    IF rls_count < 8 THEN
        RAISE EXCEPTION 'Row Level Security not properly enabled on all tables';
    END IF;
    
    RAISE NOTICE 'RLS validation passed: % tables have RLS enabled', rls_count;
END
$;

-- Test 2: Verify roles exist
DO $
DECLARE
    role_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO role_count
    FROM pg_roles
    WHERE rolname IN ('re_admin', 're_manager', 're_agent', 're_readonly');
    
    IF role_count != 4 THEN
        RAISE EXCEPTION 'Not all required roles were created';
    END IF;
    
    RAISE NOTICE 'Role validation passed: All 4 roles exist';
END
$;

-- Test 3: Verify encryption functions exist
DO $
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'encrypt_sensitive_data') THEN
        RAISE EXCEPTION 'Encryption function not found';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'decrypt_sensitive_data') THEN
        RAISE EXCEPTION 'Decryption function not found';
    END IF;
    
    RAISE NOTICE 'Encryption function validation passed';
END
$;

-- Test 4: Test encryption/decryption
DO $
DECLARE
    test_data TEXT := 'This is sensitive test data';
    encrypted_data BYTEA;
    decrypted_data TEXT;
BEGIN
    -- Test encryption
    encrypted_data := encrypt_sensitive_data(test_data);
    
    -- Test decryption
    decrypted_data := decrypt_sensitive_data(encrypted_data);
    
    IF decrypted_data != test_data THEN
        RAISE EXCEPTION 'Encryption/decryption test failed';
    END IF;
    
    RAISE NOTICE 'Encryption/decryption test passed';
END
$;

-- Test 5: Verify audit logging is working
DO $
DECLARE
    log_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO log_count
    FROM activity_logs
    WHERE action_type = 'SECURITY_SETUP';
    
    IF log_count = 0 THEN
        RAISE EXCEPTION 'Audit logging not working properly';
    END IF;
    
    RAISE NOTICE 'Audit logging validation passed';
END
$;

-- =====================================================
-- 7. GENERATE SECURITY REPORT
-- =====================================================

\echo 'Generating security deployment report...'

-- Create deployment report
SELECT 
    'Security Deployment Report' as report_title,
    CURRENT_TIMESTAMP as deployment_time;

-- Show security configuration
\echo 'Current Security Configuration:'
SELECT * FROM security_configuration ORDER BY security_feature, tablename;

-- Show created roles and their members
\echo 'Database Roles and Members:'
SELECT 
    r.rolname as role_name,
    ARRAY_AGG(m.rolname) as members
FROM pg_roles r
LEFT JOIN pg_auth_members am ON r.oid = am.roleid
LEFT JOIN pg_roles m ON am.member = m.oid
WHERE r.rolname LIKE 're_%'
GROUP BY r.rolname
ORDER BY r.rolname;

-- Show sample data counts
\echo 'Sample Data Summary:'
SELECT 
    'users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'properties', COUNT(*) FROM properties
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'activity_logs', COUNT(*) FROM activity_logs
ORDER BY table_name;

-- =====================================================
-- 8. SECURITY RECOMMENDATIONS
-- =====================================================

\echo 'Security deployment completed successfully!'
\echo ''
\echo 'IMPORTANT SECURITY RECOMMENDATIONS:'
\echo '1. Change all default passwords in production'
\echo '2. Configure SSL/TLS for database connections'
\echo '3. Set up regular backup encryption'
\echo '4. Implement connection pooling with authentication'
\echo '5. Monitor audit logs regularly'
\echo '6. Set up automated security alerts'
\echo '7. Review and update security policies quarterly'
\echo ''
\echo 'Next Steps:'
\echo '1. Test application connectivity with different roles'
\echo '2. Verify RLS policies work as expected'
\echo '3. Set up monitoring and alerting'
\echo '4. Document security procedures for operations team'
\echo ''
\echo 'For detailed security information, see SECURITY_README.md'

-- Log the deployment completion
INSERT INTO activity_logs (action_type, entity_type, new_values)
VALUES ('SECURITY_DEPLOYMENT', 'database', jsonb_build_object(
    'deployment_completed', true,
    'timestamp', CURRENT_TIMESTAMP,
    'roles_created', 4,
    'sample_users_created', 5,
    'validation_tests_passed', 5
));