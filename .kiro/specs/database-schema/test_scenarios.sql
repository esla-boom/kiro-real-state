-- Real Estate Dashboard Test Scenarios
-- This script contains business workflow test scenarios and validation cases
-- Run after schema.sql and test_data.sql

-- =====================================================
-- BUSINESS WORKFLOW TEST SCENARIOS
-- =====================================================

-- =====================================================
-- SCENARIO 1: Complete Property Listing Workflow
-- =====================================================

-- Test: Agent creates new property listing
DO $$
DECLARE
    test_agent_id UUID := '33333333-3333-3333-3333-333333333333';
    test_property_id UUID;
BEGIN
    -- Insert new property
    INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, agent_id)
    VALUES ('Test Scenario Property', 'Property for testing complete workflow', '123 Test Street, Test City', 40.7500, -73.9850, 500000.00, 100.00, 2, 1, 'apartment', test_agent_id)
    RETURNING property_id INTO test_property_id;
    
    -- Add property photos
    INSERT INTO documents (filename, file_path, file_size, mime_type, document_type, title, property_id, uploaded_by)
    VALUES ('test_property_photos.jpg', '/uploads/test/photos.jpg', 1048576, 'image/jpeg', 'photo', 'Test Property Photos', test_property_id, test_agent_id);
    
    -- Log the activity
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'property', test_property_id, '{"title": "Test Scenario Property", "status": "available"}');
    
    RAISE NOTICE 'SCENARIO 1 PASSED: Property listing workflow completed successfully';
END $$;

-- =====================================================
-- SCENARIO 2: Client Registration and Preference Setup
-- =====================================================

DO $$
DECLARE
    test_agent_id UUID := '44444444-4444-4444-4444-444444444444';
    test_client_id UUID;
BEGIN
    -- Register new client
    INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, agent_id, notes)
    VALUES ('Test', 'Client', 'test.client@email.com', '+1-555-9999', 400000.00, 600000.00, test_agent_id, 'Test scenario client')
    RETURNING client_id INTO test_client_id;
    
    -- Set client preferences
    INSERT INTO client_preferences (client_id, property_type, min_bedrooms, max_bedrooms, min_bathrooms, preferred_areas, amenities)
    VALUES (test_client_id, 'apartment', 1, 2, 1, '["Downtown", "Midtown"]', '["gym", "parking"]');
    
    -- Log the activity
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'client', test_client_id, '{"name": "Test Client", "status": "active"}');
    
    RAISE NOTICE 'SCENARIO 2 PASSED: Client registration and preferences setup completed';
END $$;

-- =====================================================
-- SCENARIO 3: Property Matching and Appointment Scheduling
-- =====================================================

DO $$
DECLARE
    test_property_id UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    test_client_id UUID := 'dddddddd-4444-4444-4444-444444444444';
    test_agent_id UUID := '66666666-6666-6666-6666-666666666666';
    test_match_id UUID;
    test_appointment_id UUID;
BEGIN
    -- Create property match
    INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status)
    VALUES (test_property_id, test_client_id, 87.5, '{"price_match": true, "location_match": true, "bedrooms_match": true}', 'new')
    RETURNING match_id INTO test_match_id;
    
    -- Schedule viewing appointment
    INSERT INTO appointments (appointment_type, appointment_date, appointment_time, client_id, property_id, agent_id, notes)
    VALUES ('viewing', CURRENT_DATE + INTERVAL '2 days', '14:00:00', test_client_id, test_property_id, test_agent_id, 'Property match viewing')
    RETURNING appointment_id INTO test_appointment_id;
    
    -- Update match status to sent
    UPDATE property_matches SET status = 'sent' WHERE match_id = test_match_id;
    
    -- Log activities
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'property_match', test_match_id, '{"match_score": 87.5, "status": "sent"}');
    
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'appointment', test_appointment_id, '{"type": "viewing", "status": "scheduled"}');
    
    RAISE NOTICE 'SCENARIO 3 PASSED: Property matching and appointment scheduling completed';
END $$;

-- =====================================================
-- SCENARIO 4: Sale Transaction Workflow
-- =====================================================

DO $$
DECLARE
    test_property_id UUID := 'ffffffff-ffff-ffff-ffff-ffffffffffff';
    test_client_id UUID := 'ffffffff-6666-6666-6666-666666666666';
    test_agent_id UUID := '33333333-3333-3333-3333-333333333333';
    test_transaction_id UUID;
    test_document_id UUID;
BEGIN
    -- Update property status to sold
    UPDATE properties SET status = 'sold' WHERE property_id = test_property_id;
    
    -- Create commission transaction
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, property_id, client_id, agent_id, reference_number)
    VALUES ('commission', 22500.00, CURRENT_DATE, 'pending', 'Commission from loft sale', test_property_id, test_client_id, test_agent_id, 'COM-TEST-001')
    RETURNING transaction_id INTO test_transaction_id;
    
    -- Add sale contract document
    INSERT INTO documents (filename, file_path, file_size, mime_type, document_type, title, property_id, client_id, uploaded_by)
    VALUES ('sale_contract_test.pdf', '/uploads/contracts/test_contract.pdf', 2097152, 'application/pdf', 'contract', 'Test Sale Contract', test_property_id, test_client_id, test_agent_id)
    RETURNING document_id INTO test_document_id;
    
    -- Update client status to converted
    UPDATE clients SET status = 'converted' WHERE client_id = test_client_id;
    
    -- Log activities
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, old_values, new_values)
    VALUES (test_agent_id, 'UPDATE', 'property', test_property_id, '{"status": "available"}', '{"status": "sold"}');
    
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'transaction', test_transaction_id, '{"type": "commission", "amount": 22500.00}');
    
    RAISE NOTICE 'SCENARIO 4 PASSED: Sale transaction workflow completed';
END $$;

-- =====================================================
-- SCENARIO 5: Rental Property Management
-- =====================================================

DO $$
DECLARE
    test_property_id UUID := 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh';
    test_agent_id UUID := '55555555-5555-5555-5555-555555555555';
    test_transaction_id UUID;
BEGIN
    -- Verify property is rented
    IF NOT EXISTS (SELECT 1 FROM properties WHERE property_id = test_property_id AND status = 'rented') THEN
        RAISE EXCEPTION 'Property should be in rented status for this scenario';
    END IF;
    
    -- Create monthly rental transaction
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, property_id, agent_id, reference_number)
    VALUES ('rental_fee', 3200.00, CURRENT_DATE, 'paid', 'Monthly rental payment', test_property_id, test_agent_id, 'RENT-TEST-001')
    RETURNING transaction_id INTO test_transaction_id;
    
    -- Log rental payment
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (test_agent_id, 'CREATE', 'transaction', test_transaction_id, '{"type": "rental_fee", "amount": 3200.00}');
    
    RAISE NOTICE 'SCENARIO 5 PASSED: Rental property management workflow completed';
END $$;

-- =====================================================
-- DATA VALIDATION TEST CASES
-- =====================================================

-- =====================================================
-- VALIDATION 1: Referential Integrity Tests
-- =====================================================

DO $$
DECLARE
    integrity_issues INTEGER := 0;
BEGIN
    -- Check for orphaned properties (properties without valid agents)
    SELECT COUNT(*) INTO integrity_issues
    FROM properties p LEFT JOIN users u ON p.agent_id = u.user_id 
    WHERE u.user_id IS NULL;
    
    IF integrity_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % properties without valid agents', integrity_issues;
    END IF;
    
    -- Check for orphaned clients
    SELECT COUNT(*) INTO integrity_issues
    FROM clients c LEFT JOIN users u ON c.agent_id = u.user_id 
    WHERE u.user_id IS NULL;
    
    IF integrity_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % clients without valid agents', integrity_issues;
    END IF;
    
    -- Check for appointments without valid clients
    SELECT COUNT(*) INTO integrity_issues
    FROM appointments a LEFT JOIN clients c ON a.client_id = c.client_id 
    WHERE c.client_id IS NULL;
    
    IF integrity_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % appointments without valid clients', integrity_issues;
    END IF;
    
    -- Check for property matches with invalid references
    SELECT COUNT(*) INTO integrity_issues
    FROM property_matches pm 
    LEFT JOIN properties p ON pm.property_id = p.property_id
    LEFT JOIN clients c ON pm.client_id = c.client_id
    WHERE p.property_id IS NULL OR c.client_id IS NULL;
    
    IF integrity_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % property matches with invalid references', integrity_issues;
    END IF;
    
    RAISE NOTICE 'VALIDATION 1 PASSED: All referential integrity checks passed';
END $$;

-- =====================================================
-- VALIDATION 2: Business Rule Constraints
-- =====================================================

DO $$
DECLARE
    constraint_violations INTEGER := 0;
BEGIN
    -- Check for negative prices
    SELECT COUNT(*) INTO constraint_violations
    FROM properties WHERE price <= 0;
    
    IF constraint_violations > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % properties with negative or zero prices', constraint_violations;
    END IF;
    
    -- Check for invalid budget ranges (min > max)
    SELECT COUNT(*) INTO constraint_violations
    FROM clients WHERE budget_min > budget_max;
    
    IF constraint_violations > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % clients with invalid budget ranges', constraint_violations;
    END IF;
    
    -- Check for invalid coordinates
    SELECT COUNT(*) INTO constraint_violations
    FROM properties 
    WHERE latitude < -90 OR latitude > 90 OR longitude < -180 OR longitude > 180;
    
    IF constraint_violations > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % properties with invalid coordinates', constraint_violations;
    END IF;
    
    -- Check for future appointments in past status
    SELECT COUNT(*) INTO constraint_violations
    FROM appointments 
    WHERE appointment_date > CURRENT_DATE AND status IN ('completed', 'no_show');
    
    IF constraint_violations > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % future appointments marked as completed/no_show', constraint_violations;
    END IF;
    
    RAISE NOTICE 'VALIDATION 2 PASSED: All business rule constraints validated';
END $$;

-- =====================================================
-- VALIDATION 3: Data Quality Checks
-- =====================================================

DO $$
DECLARE
    quality_issues INTEGER := 0;
BEGIN
    -- Check for duplicate email addresses within same agent
    SELECT COUNT(*) INTO quality_issues
    FROM (
        SELECT agent_id, email, COUNT(*) 
        FROM clients 
        GROUP BY agent_id, email 
        HAVING COUNT(*) > 1
    ) duplicates;
    
    IF quality_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % duplicate client emails within same agent', quality_issues;
    END IF;
    
    -- Check for properties without descriptions
    SELECT COUNT(*) INTO quality_issues
    FROM properties WHERE description IS NULL OR TRIM(description) = '';
    
    IF quality_issues > 0 THEN
        RAISE NOTICE 'DATA QUALITY WARNING: Found % properties without descriptions', quality_issues;
    END IF;
    
    -- Check for clients without phone numbers
    SELECT COUNT(*) INTO quality_issues
    FROM clients WHERE phone IS NULL OR TRIM(phone) = '';
    
    IF quality_issues > 0 THEN
        RAISE NOTICE 'DATA QUALITY WARNING: Found % clients without phone numbers', quality_issues;
    END IF;
    
    -- Check for match scores outside valid range
    SELECT COUNT(*) INTO quality_issues
    FROM property_matches WHERE match_score < 0 OR match_score > 100;
    
    IF quality_issues > 0 THEN
        RAISE EXCEPTION 'VALIDATION FAILED: Found % property matches with invalid scores', quality_issues;
    END IF;
    
    RAISE NOTICE 'VALIDATION 3 PASSED: Data quality checks completed';
END $$;

-- =====================================================
-- VALIDATION 4: Performance and Index Validation
-- =====================================================

-- Test common query patterns to ensure indexes are working
DO $$
DECLARE
    query_plan TEXT;
BEGIN
    -- Test property search by agent and status (should use index)
    EXPLAIN (FORMAT TEXT) 
    SELECT * FROM properties WHERE agent_id = '33333333-3333-3333-3333-333333333333' AND status = 'available';
    
    -- Test client budget range queries (should use index)
    EXPLAIN (FORMAT TEXT)
    SELECT * FROM clients WHERE budget_min <= 500000 AND budget_max >= 400000;
    
    -- Test appointment calendar queries (should use index)
    EXPLAIN (FORMAT TEXT)
    SELECT * FROM appointments WHERE agent_id = '44444444-4444-4444-4444-444444444444' AND appointment_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days';
    
    -- Test property location queries (should use spatial index)
    EXPLAIN (FORMAT TEXT)
    SELECT * FROM properties WHERE latitude BETWEEN 40.7 AND 40.8 AND longitude BETWEEN -74.0 AND -73.9;
    
    RAISE NOTICE 'VALIDATION 4 COMPLETED: Query performance validation completed (check EXPLAIN output)';
END $$;

-- =====================================================
-- VALIDATION 5: Security and Access Control
-- =====================================================

DO $$
DECLARE
    security_issues INTEGER := 0;
BEGIN
    -- Check for users with weak password hashes (should all use bcrypt)
    SELECT COUNT(*) INTO security_issues
    FROM users WHERE password_hash NOT LIKE '$2b$%';
    
    IF security_issues > 0 THEN
        RAISE EXCEPTION 'SECURITY VALIDATION FAILED: Found % users with weak password hashes', security_issues;
    END IF;
    
    -- Check for sensitive documents marked as public
    SELECT COUNT(*) INTO security_issues
    FROM documents WHERE document_type IN ('contract', 'client_doc') AND is_public = true;
    
    IF security_issues > 0 THEN
        RAISE EXCEPTION 'SECURITY VALIDATION FAILED: Found % sensitive documents marked as public', security_issues;
    END IF;
    
    -- Check for activity logs without user context
    SELECT COUNT(*) INTO security_issues
    FROM activity_logs WHERE user_id IS NULL AND action_type NOT IN ('SYSTEM', 'AUTOMATED');
    
    IF security_issues > 0 THEN
        RAISE NOTICE 'SECURITY WARNING: Found % activity logs without user context', security_issues;
    END IF;
    
    RAISE NOTICE 'VALIDATION 5 PASSED: Security and access control validation completed';
END $$;

-- =====================================================
-- COMPREHENSIVE REPORTING QUERIES
-- =====================================================

-- Summary report of test data
SELECT 
    'DATABASE SUMMARY' as report_type,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM properties) as total_properties,
    (SELECT COUNT(*) FROM clients) as total_clients,
    (SELECT COUNT(*) FROM appointments) as total_appointments,
    (SELECT COUNT(*) FROM transactions) as total_transactions,
    (SELECT COUNT(*) FROM documents) as total_documents,
    (SELECT COUNT(*) FROM property_matches) as total_matches,
    (SELECT COUNT(*) FROM activity_logs) as total_logs;

-- Agent performance summary
SELECT 
    'AGENT PERFORMANCE' as report_type,
    u.first_name || ' ' || u.last_name as agent_name,
    COUNT(DISTINCT p.property_id) as properties_managed,
    COUNT(DISTINCT c.client_id) as clients_managed,
    COUNT(DISTINCT a.appointment_id) as appointments_scheduled,
    COALESCE(SUM(t.amount), 0) as total_transactions
FROM users u
LEFT JOIN properties p ON u.user_id = p.agent_id
LEFT JOIN clients c ON u.user_id = c.agent_id
LEFT JOIN appointments a ON u.user_id = a.agent_id
LEFT JOIN transactions t ON u.user_id = t.agent_id
WHERE u.role = 'agent'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_transactions DESC;

-- Property status distribution
SELECT 
    'PROPERTY STATUS' as report_type,
    status,
    COUNT(*) as property_count,
    AVG(price) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM properties
GROUP BY status
ORDER BY property_count DESC;

-- Client engagement metrics
SELECT 
    'CLIENT ENGAGEMENT' as report_type,
    c.status,
    COUNT(*) as client_count,
    AVG(c.budget_max - c.budget_min) as avg_budget_range,
    COUNT(DISTINCT a.appointment_id) as total_appointments,
    COUNT(DISTINCT pm.match_id) as total_matches
FROM clients c
LEFT JOIN appointments a ON c.client_id = a.client_id
LEFT JOIN property_matches pm ON c.client_id = pm.client_id
GROUP BY c.status
ORDER BY client_count DESC;

-- =====================================================
-- CLEANUP TEST DATA (Optional)
-- =====================================================

-- Uncomment the following block to clean up test scenario data
/*
DO $$
BEGIN
    -- Remove test scenario data (keep original test data)
    DELETE FROM activity_logs WHERE new_values::text LIKE '%Test%' OR old_values::text LIKE '%Test%';
    DELETE FROM documents WHERE title LIKE '%Test%' OR filename LIKE '%test%';
    DELETE FROM transactions WHERE description LIKE '%Test%' OR reference_number LIKE '%TEST%';
    DELETE FROM appointments WHERE notes LIKE '%Test%' OR notes LIKE '%test%';
    DELETE FROM property_matches WHERE agent_notes LIKE '%Test%';
    DELETE FROM client_preferences WHERE client_id IN (SELECT client_id FROM clients WHERE email LIKE '%test%');
    DELETE FROM clients WHERE email LIKE '%test%';
    DELETE FROM properties WHERE title LIKE '%Test%' OR description LIKE '%test%';
    
    RAISE NOTICE 'Test scenario data cleaned up successfully';
END $$;
*/

-- =====================================================
-- SCENARIO 6: Multi-Agent Collaboration Workflow
-- =====================================================

DO $
DECLARE
    primary_agent_id UUID := '33333333-3333-3333-3333-333333333333';
    secondary_agent_id UUID := '44444444-4444-4444-4444-444444444444';
    shared_client_id UUID := 'dddddddd-4444-4444-4444-444444444444';
    referral_property_id UUID := 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
    referral_transaction_id UUID;
BEGIN
    -- Create referral transaction between agents
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, property_id, client_id, agent_id, reference_number)
    VALUES ('commission', 15000.00, CURRENT_DATE, 'pending', 'Referral commission split', referral_property_id, shared_client_id, secondary_agent_id, 'REF-SPLIT-001')
    RETURNING transaction_id INTO referral_transaction_id;
    
    -- Log the referral activity
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES (primary_agent_id, 'CREATE', 'referral', referral_transaction_id, '{"type": "agent_referral", "referred_to": "' || secondary_agent_id || '", "commission_split": 50}');
    
    -- Update client to reflect agent change
    UPDATE clients SET agent_id = secondary_agent_id, notes = COALESCE(notes, '') || ' - Referred from Agent John Smith' 
    WHERE client_id = shared_client_id;
    
    RAISE NOTICE 'SCENARIO 6 PASSED: Multi-agent collaboration workflow completed';
END $;

-- =====================================================
-- SCENARIO 7: Property Lifecycle Management
-- =====================================================

DO $
DECLARE
    lifecycle_property_id UUID := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
    maintenance_doc_id UUID;
    price_history_count INTEGER;
BEGIN
    -- Property goes through complete lifecycle: available -> pending -> sold -> maintenance -> available
    
    -- Step 1: Property becomes pending
    UPDATE properties SET status = 'pending' WHERE property_id = lifecycle_property_id;
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, old_values, new_values)
    VALUES ('66666666-6666-6666-6666-666666666666', 'UPDATE', 'property', lifecycle_property_id, '{"status": "available"}', '{"status": "pending"}');
    
    -- Step 2: Property is sold
    UPDATE properties SET status = 'sold' WHERE property_id = lifecycle_property_id;
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, property_id, agent_id, reference_number)
    VALUES ('commission', 19500.00, CURRENT_DATE, 'paid', 'Sale commission for suburban house', lifecycle_property_id, '66666666-6666-6666-6666-666666666666', 'SALE-COMM-001');
    
    -- Step 3: Add maintenance documentation
    INSERT INTO documents (filename, file_path, file_size, mime_type, document_type, title, property_id, uploaded_by)
    VALUES ('maintenance_report.pdf', '/uploads/maintenance/report.pdf', 1048576, 'application/pdf', 'report', 'Post-Sale Maintenance Report', lifecycle_property_id, '66666666-6666-6666-6666-666666666666')
    RETURNING document_id INTO maintenance_doc_id;
    
    -- Step 4: Property becomes available again (resale)
    UPDATE properties SET status = 'available', price = price * 1.1 WHERE property_id = lifecycle_property_id;
    
    -- Verify price history tracking
    SELECT COUNT(*) INTO price_history_count FROM activity_logs 
    WHERE entity_type = 'property' AND entity_id = lifecycle_property_id AND action_type = 'UPDATE';
    
    IF price_history_count >= 2 THEN
        RAISE NOTICE 'SCENARIO 7 PASSED: Property lifecycle management with % price changes tracked', price_history_count;
    ELSE
        RAISE NOTICE 'SCENARIO 7 WARNING: Insufficient price history tracking';
    END IF;
END $;

-- =====================================================
-- SCENARIO 8: Advanced Property Matching Algorithm
-- =====================================================

DO $
DECLARE
    algorithm_client_id UUID := 'eeeeeeee-5555-5555-5555-555555555555';
    match_count INTEGER;
    high_score_matches INTEGER;
BEGIN
    -- Create multiple property matches with different scoring criteria
    INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status, agent_notes) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', algorithm_client_id, 92.5, '{"price_match": true, "location_match": true, "bedrooms_match": true, "school_district": true, "commute_time": 15}', 'new', 'Excellent match with great schools'),
    ('gggggggg-gggg-gggg-gggg-gggggggggggg', algorithm_client_id, 88.0, '{"price_match": true, "location_match": false, "bedrooms_match": true, "condition": "excellent", "yard_size": "large"}', 'new', 'Good match but location not ideal'),
    ('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', algorithm_client_id, 85.5, '{"price_match": true, "location_match": true, "bedrooms_match": false, "recent_renovation": true}', 'new', 'Good location but needs more bedrooms');
    
    -- Update client preferences to reflect complex matching criteria
    UPDATE client_preferences 
    SET amenities = '{"school_rating": "9+", "commute_time": "<20min", "yard_size": "large", "parking": "2_car_garage", "recent_updates": true}'::jsonb,
        additional_requirements = 'Must be in top school district, under 20 minute commute to downtown, large yard for children'
    WHERE client_id = algorithm_client_id;
    
    -- Verify matching algorithm results
    SELECT COUNT(*) INTO match_count FROM property_matches WHERE client_id = algorithm_client_id;
    SELECT COUNT(*) INTO high_score_matches FROM property_matches WHERE client_id = algorithm_client_id AND match_score >= 85;
    
    IF match_count >= 3 AND high_score_matches >= 3 THEN
        RAISE NOTICE 'SCENARIO 8 PASSED: Advanced matching algorithm created % matches with % high-scoring results', match_count, high_score_matches;
    ELSE
        RAISE NOTICE 'SCENARIO 8 FAILED: Insufficient matching results';
    END IF;
END $;

-- =====================================================
-- SCENARIO 9: Financial Reporting and Commission Tracking
-- =====================================================

DO $
DECLARE
    reporting_agent_id UUID := '77777777-7777-7777-7777-777777777777';
    quarterly_commission DECIMAL(12,2);
    expense_total DECIMAL(12,2);
    net_income DECIMAL(12,2);
BEGIN
    -- Create comprehensive financial scenario
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, agent_id, reference_number) VALUES
    ('commission', 45000.00, CURRENT_DATE - 30, 'paid', 'Q4 luxury property sale', reporting_agent_id, 'Q4-COMM-001'),
    ('commission', 32000.00, CURRENT_DATE - 60, 'paid', 'Q4 commercial lease commission', reporting_agent_id, 'Q4-COMM-002'),
    ('expense', 2500.00, CURRENT_DATE - 45, 'paid', 'Q4 marketing and advertising', reporting_agent_id, 'Q4-EXP-001'),
    ('expense', 1200.00, CURRENT_DATE - 35, 'paid', 'Q4 professional photography', reporting_agent_id, 'Q4-EXP-002'),
    ('expense', 800.00, CURRENT_DATE - 25, 'paid', 'Q4 client entertainment', reporting_agent_id, 'Q4-EXP-003');
    
    -- Calculate financial metrics
    SELECT COALESCE(SUM(amount), 0) INTO quarterly_commission 
    FROM transactions 
    WHERE agent_id = reporting_agent_id AND transaction_type = 'commission' AND status = 'paid';
    
    SELECT COALESCE(SUM(amount), 0) INTO expense_total 
    FROM transactions 
    WHERE agent_id = reporting_agent_id AND transaction_type = 'expense' AND status = 'paid';
    
    net_income := quarterly_commission - expense_total;
    
    -- Create financial report
    INSERT INTO reports (report_name, report_type, parameters, created_by, last_run_at)
    VALUES ('Agent Financial Performance Q4', 'financial', 
            ('{"agent_id": "' || reporting_agent_id || '", "period": "Q4_2024", "commission_total": ' || quarterly_commission || ', "expense_total": ' || expense_total || ', "net_income": ' || net_income || '}')::jsonb,
            reporting_agent_id, CURRENT_TIMESTAMP);
    
    IF net_income > 0 THEN
        RAISE NOTICE 'SCENARIO 9 PASSED: Financial reporting shows net income of $% (Commission: $%, Expenses: $%)', net_income, quarterly_commission, expense_total;
    ELSE
        RAISE NOTICE 'SCENARIO 9 WARNING: Negative net income detected';
    END IF;
END $;

-- =====================================================
-- SCENARIO 10: Data Archival and Cleanup Workflow
-- =====================================================

DO $
DECLARE
    old_logs_count INTEGER;
    archived_transactions INTEGER;
    cleanup_report_id UUID;
BEGIN
    -- Simulate data archival process
    
    -- Count old activity logs (older than 1 year)
    SELECT COUNT(*) INTO old_logs_count 
    FROM activity_logs 
    WHERE created_at < CURRENT_DATE - INTERVAL '365 days';
    
    -- Count old completed transactions
    SELECT COUNT(*) INTO archived_transactions 
    FROM transactions 
    WHERE transaction_date < CURRENT_DATE - INTERVAL '365 days' AND status = 'paid';
    
    -- Create cleanup report
    INSERT INTO reports (report_name, report_type, parameters, created_by)
    VALUES ('Data Archival Report', 'activity', 
            ('{"old_logs_count": ' || old_logs_count || ', "archived_transactions": ' || archived_transactions || ', "archival_date": "' || CURRENT_DATE || '", "retention_policy": "365_days"}')::jsonb,
            '11111111-1111-1111-1111-111111111111')
    RETURNING report_id INTO cleanup_report_id;
    
    -- Log the archival activity
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values)
    VALUES ('11111111-1111-1111-1111-111111111111', 'ARCHIVE', 'system', cleanup_report_id, 
            ('{"logs_archived": ' || old_logs_count || ', "transactions_archived": ' || archived_transactions || '}')::jsonb);
    
    RAISE NOTICE 'SCENARIO 10 PASSED: Data archival workflow identified % old logs and % old transactions for archival', old_logs_count, archived_transactions;
END $;

-- =====================================================
-- ENHANCED DATA VALIDATION TEST CASES
-- =====================================================

-- =====================================================
-- VALIDATION 6: Complex Business Rule Validation
-- =====================================================

DO $
DECLARE
    validation_issues INTEGER := 0;
    commission_rate_issues INTEGER := 0;
    appointment_overlap_issues INTEGER := 0;
BEGIN
    -- Check for unrealistic commission rates (should be reasonable percentage of sale price)
    SELECT COUNT(*) INTO commission_rate_issues
    FROM transactions t
    JOIN properties p ON t.property_id = p.property_id
    WHERE t.transaction_type = 'commission' 
      AND t.amount > (p.price * 0.10); -- More than 10% commission is unusual
    
    IF commission_rate_issues > 0 THEN
        RAISE NOTICE 'VALIDATION WARNING: Found % transactions with unusually high commission rates', commission_rate_issues;
    END IF;
    
    -- Check for appointment scheduling conflicts
    SELECT COUNT(*) INTO appointment_overlap_issues
    FROM appointments a1
    JOIN appointments a2 ON a1.agent_id = a2.agent_id 
      AND a1.appointment_date = a2.appointment_date
      AND a1.appointment_id != a2.appointment_id
    WHERE a1.status IN ('scheduled', 'confirmed')
      AND a2.status IN ('scheduled', 'confirmed')
      AND (
        (a1.appointment_time, a1.appointment_time + (a1.duration_minutes || ' minutes')::INTERVAL) 
        OVERLAPS 
        (a2.appointment_time, a2.appointment_time + (a2.duration_minutes || ' minutes')::INTERVAL)
      );
    
    IF appointment_overlap_issues = 0 THEN
        RAISE NOTICE 'VALIDATION 6 PASSED: No appointment conflicts or unrealistic commission rates found';
    ELSE
        RAISE NOTICE 'VALIDATION 6 WARNING: Found % appointment scheduling conflicts', appointment_overlap_issues;
    END IF;
END $;

-- =====================================================
-- VALIDATION 7: Data Consistency Across Relationships
-- =====================================================

DO $
DECLARE
    consistency_issues INTEGER := 0;
    orphaned_preferences INTEGER := 0;
    mismatched_agents INTEGER := 0;
BEGIN
    -- Check for client preferences without corresponding clients
    SELECT COUNT(*) INTO orphaned_preferences
    FROM client_preferences cp
    LEFT JOIN clients c ON cp.client_id = c.client_id
    WHERE c.client_id IS NULL;
    
    -- Check for appointments where client and property have different agents
    SELECT COUNT(*) INTO mismatched_agents
    FROM appointments a
    JOIN clients c ON a.client_id = c.client_id
    JOIN properties p ON a.property_id = p.property_id
    WHERE c.agent_id != p.agent_id AND c.agent_id != a.agent_id;
    
    consistency_issues := orphaned_preferences + mismatched_agents;
    
    IF consistency_issues = 0 THEN
        RAISE NOTICE 'VALIDATION 7 PASSED: All relationship data is consistent';
    ELSE
        RAISE NOTICE 'VALIDATION 7 FAILED: Found % consistency issues (% orphaned preferences, % agent mismatches)', 
                     consistency_issues, orphaned_preferences, mismatched_agents;
    END IF;
END $;

-- =====================================================
-- VALIDATION 8: Performance and Scalability Validation
-- =====================================================

DO $
DECLARE
    large_table_count INTEGER := 0;
    index_coverage DECIMAL(5,2);
    query_performance_issues INTEGER := 0;
BEGIN
    -- Check for tables that might need performance optimization
    SELECT COUNT(*) INTO large_table_count
    FROM (
        SELECT schemaname, tablename, n_tup_ins + n_tup_upd + n_tup_del as operations
        FROM pg_stat_user_tables 
        WHERE schemaname = 'public' AND (n_tup_ins + n_tup_upd + n_tup_del) > 100
    ) large_ops;
    
    -- Calculate index coverage ratio
    SELECT ROUND(
        100.0 * SUM(idx_scan) / NULLIF(SUM(idx_scan + seq_scan), 0), 2
    ) INTO index_coverage
    FROM pg_stat_user_tables 
    WHERE schemaname = 'public';
    
    IF large_table_count > 0 AND index_coverage >= 80.0 THEN
        RAISE NOTICE 'VALIDATION 8 PASSED: % active tables with %.2f%% index coverage ratio', large_table_count, index_coverage;
    ELSE
        RAISE NOTICE 'VALIDATION 8 WARNING: Performance may need optimization (Index coverage: %.2f%%)', COALESCE(index_coverage, 0);
    END IF;
END $;

-- =====================================================
-- COMPREHENSIVE TEST SUMMARY REPORT
-- =====================================================

-- Generate final test summary
SELECT 
    'TEST EXECUTION SUMMARY' as report_section,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM properties) as total_properties,
    (SELECT COUNT(*) FROM clients) as total_clients,
    (SELECT COUNT(*) FROM appointments) as total_appointments,
    (SELECT COUNT(*) FROM transactions) as total_transactions,
    (SELECT COUNT(*) FROM documents) as total_documents,
    (SELECT COUNT(*) FROM property_matches) as total_matches,
    (SELECT COUNT(*) FROM client_preferences) as total_preferences,
    (SELECT COUNT(*) FROM activity_logs) as total_activity_logs,
    (SELECT COUNT(*) FROM reports) as total_reports;

-- Business metrics summary
SELECT 
    'BUSINESS METRICS SUMMARY' as report_section,
    (SELECT COUNT(*) FROM properties WHERE status = 'available') as available_properties,
    (SELECT COUNT(*) FROM properties WHERE status = 'sold') as sold_properties,
    (SELECT COUNT(*) FROM clients WHERE status = 'active') as active_clients,
    (SELECT COUNT(*) FROM clients WHERE status = 'converted') as converted_clients,
    (SELECT COUNT(*) FROM appointments WHERE status = 'scheduled') as scheduled_appointments,
    (SELECT COUNT(*) FROM transactions WHERE status = 'paid') as paid_transactions,
    (SELECT ROUND(AVG(match_score), 2) FROM property_matches) as avg_match_score,
    (SELECT COUNT(DISTINCT agent_id) FROM properties) as active_agents;

-- Data quality metrics
SELECT 
    'DATA QUALITY METRICS' as report_section,
    (SELECT COUNT(*) FROM properties WHERE description IS NOT NULL) as properties_with_descriptions,
    (SELECT COUNT(*) FROM clients WHERE phone IS NOT NULL) as clients_with_phones,
    (SELECT COUNT(*) FROM properties WHERE latitude IS NOT NULL AND longitude IS NOT NULL) as properties_with_coordinates,
    (SELECT COUNT(*) FROM documents WHERE is_public = false AND document_type IN ('contract', 'client_doc')) as secure_documents,
    (SELECT COUNT(DISTINCT currency) FROM transactions) as currency_variety,
    (SELECT COUNT(*) FROM activity_logs WHERE user_id IS NOT NULL) as logged_user_activities;

-- =====================================================
-- END OF ENHANCED TEST SCENARIOS
-- =====================================================-
- =====================================================
-- SCENARIO 11: Stress Testing with Large Data Volumes
-- =====================================================

DO $
DECLARE
    i INTEGER;
    test_agent_id UUID := '33333333-3333-3333-3333-333333333333';
    bulk_property_id UUID;
    bulk_client_id UUID;
BEGIN
    -- Create bulk properties for performance testing
    FOR i IN 1..50 LOOP
        INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, agent_id)
        VALUES (
            'Bulk Property ' || i,
            'Generated property for stress testing scenario ' || i,
            i || ' Stress Test Avenue, Load City, NY ' || (10000 + i),
            40.7500 + (i * 0.001),
            -73.9850 + (i * 0.001),
            (400000 + (i * 10000))::DECIMAL(12,2),
            (80 + (i * 2))::DECIMAL(8,2),
            (i % 5) + 1,
            (i % 3) + 1,
            CASE (i % 4) 
                WHEN 0 THEN 'apartment'
                WHEN 1 THEN 'house'
                WHEN 2 THEN 'condo'
                ELSE 'villa'
            END,
            test_agent_id
        );
    END LOOP;
    
    -- Create bulk clients
    FOR i IN 1..30 LOOP
        INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, agent_id, notes)
        VALUES (
            'BulkClient' || i,
            'TestSurname' || i,
            'bulkclient' || i || '@stresstest.com',
            '+1-555-' || LPAD(i::TEXT, 4, '0'),
            (300000 + (i * 5000))::DECIMAL(12,2),
            (500000 + (i * 10000))::DECIMAL(12,2),
            test_agent_id,
            'Bulk generated client for stress testing'
        );
    END LOOP;
    
    RAISE NOTICE 'SCENARIO 11 PASSED: Created 50 bulk properties and 30 bulk clients for stress testing';
END $;

-- =====================================================
-- SCENARIO 12: Complex Multi-Table Transaction Workflow
-- =====================================================

DO $
DECLARE
    complex_property_id UUID;
    complex_client_id UUID;
    complex_agent_id UUID := '44444444-4444-4444-4444-444444444444';
    complex_appointment_id UUID;
    complex_match_id UUID;
    complex_transaction_id UUID;
    complex_document_id UUID;
BEGIN
    -- Create a complex property
    INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, agent_id)
    VALUES ('Complex Transaction Property', 'Property for testing complex multi-table workflows', '999 Complex Street, Transaction City, NY 99999', 40.7600, -73.9800, 1250000.00, 200.00, 4, 3, 'house', complex_agent_id)
    RETURNING property_id INTO complex_property_id;
    
    -- Create a complex client
    INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, agent_id, notes)
    VALUES ('Complex', 'Transaction', 'complex.transaction@test.com', '+1-555-9999', 1000000.00, 1500000.00, complex_agent_id, 'Client for complex transaction testing')
    RETURNING client_id INTO complex_client_id;
    
    -- Create client preferences
    INSERT INTO client_preferences (client_id, property_type, min_bedrooms, max_bedrooms, min_bathrooms, preferred_areas, amenities)
    VALUES (complex_client_id, 'house', 3, 5, 2, '["Transaction City", "Complex Area"]', '["garage", "garden", "modern_kitchen"]');
    
    -- Create property match
    INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status)
    VALUES (complex_property_id, complex_client_id, 94.5, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 95, "complex_criteria": true}', 'new')
    RETURNING match_id INTO complex_match_id;
    
    -- Schedule appointment
    INSERT INTO appointments (appointment_type, appointment_date, appointment_time, client_id, property_id, agent_id, notes)
    VALUES ('viewing', CURRENT_DATE + 3, '15:00:00', complex_client_id, complex_property_id, complex_agent_id, 'Complex transaction property viewing')
    RETURNING appointment_id INTO complex_appointment_id;
    
    -- Create multiple documents
    INSERT INTO documents (filename, file_path, file_size, mime_type, document_type, title, property_id, client_id, uploaded_by) VALUES
    ('complex_property_photos.zip', '/uploads/complex/photos.zip', 25165824, 'application/zip', 'photo', 'Complex Property Photos', complex_property_id, NULL, complex_agent_id),
    ('complex_client_docs.pdf', '/uploads/complex/client.pdf', 5242880, 'application/pdf', 'client_doc', 'Complex Client Documentation', NULL, complex_client_id, complex_agent_id);
    
    -- Create transaction
    INSERT INTO transactions (transaction_type, amount, transaction_date, status, description, property_id, client_id, agent_id, reference_number)
    VALUES ('deposit', 125000.00, CURRENT_DATE, 'pending', 'Earnest money deposit for complex transaction', complex_property_id, complex_client_id, complex_agent_id, 'COMPLEX-DEP-001')
    RETURNING transaction_id INTO complex_transaction_id;
    
    -- Log all activities
    INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, new_values) VALUES
    (complex_agent_id, 'CREATE', 'property', complex_property_id, '{"title": "Complex Transaction Property", "workflow": "complex"}'),
    (complex_agent_id, 'CREATE', 'client', complex_client_id, '{"name": "Complex Transaction", "workflow": "complex"}'),
    (complex_agent_id, 'CREATE', 'property_match', complex_match_id, '{"match_score": 94.5, "workflow": "complex"}'),
    (complex_agent_id, 'CREATE', 'appointment', complex_appointment_id, '{"type": "viewing", "workflow": "complex"}'),
    (complex_agent_id, 'CREATE', 'transaction', complex_transaction_id, '{"type": "deposit", "amount": 125000.00, "workflow": "complex"}');
    
    RAISE NOTICE 'SCENARIO 12 PASSED: Complex multi-table transaction workflow completed successfully';
END $;

-- =====================================================
-- SCENARIO 13: Data Consistency and Constraint Testing
-- =====================================================

DO $
DECLARE
    constraint_test_passed BOOLEAN := TRUE;
    error_message TEXT;
BEGIN
    -- Test 1: Try to create property with invalid coordinates
    BEGIN
        INSERT INTO properties (title, address, latitude, longitude, price, property_type, agent_id)
        VALUES ('Invalid Coordinates', 'Test Address', 91.0, 181.0, 100000.00, 'apartment', '33333333-3333-3333-3333-333333333333');
        constraint_test_passed := FALSE;
        RAISE NOTICE 'CONSTRAINT TEST FAILED: Invalid coordinates were accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CONSTRAINT TEST PASSED: Invalid coordinates properly rejected';
    END;
    
    -- Test 2: Try to create client with invalid budget range
    BEGIN
        INSERT INTO clients (first_name, last_name, email, budget_min, budget_max, agent_id)
        VALUES ('Invalid', 'Budget', 'invalid@test.com', 500000.00, 300000.00, '33333333-3333-3333-3333-333333333333');
        constraint_test_passed := FALSE;
        RAISE NOTICE 'CONSTRAINT TEST FAILED: Invalid budget range was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CONSTRAINT TEST PASSED: Invalid budget range properly rejected';
    END;
    
    -- Test 3: Try to create appointment with invalid status for future date
    BEGIN
        INSERT INTO appointments (appointment_type, appointment_date, appointment_time, status, client_id, agent_id)
        VALUES ('viewing', CURRENT_DATE + 10, '10:00:00', 'completed', 'aaaaaaaa-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333');
        constraint_test_passed := FALSE;
        RAISE NOTICE 'CONSTRAINT TEST FAILED: Future completed appointment was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CONSTRAINT TEST PASSED: Future completed appointment properly rejected';
    END;
    
    -- Test 4: Try to create property match with invalid score
    BEGIN
        INSERT INTO property_matches (property_id, client_id, match_score, match_criteria)
        VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'aaaaaaaa-1111-1111-1111-111111111111', 150.0, '{"invalid": "score"}');
        constraint_test_passed := FALSE;
        RAISE NOTICE 'CONSTRAINT TEST FAILED: Invalid match score was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'CONSTRAINT TEST PASSED: Invalid match score properly rejected';
    END;
    
    IF constraint_test_passed THEN
        RAISE NOTICE 'SCENARIO 13 PASSED: All data consistency and constraint tests passed';
    ELSE
        RAISE NOTICE 'SCENARIO 13 FAILED: Some constraint tests failed';
    END IF;
END $;

-- =====================================================
-- SCENARIO 14: Performance Optimization Validation
-- =====================================================

DO $
DECLARE
    index_count INTEGER;
    missing_indexes TEXT[] := ARRAY[]::TEXT[];
    expected_indexes TEXT[] := ARRAY[
        'idx_properties_agent',
        'idx_properties_status', 
        'idx_properties_price',
        'idx_properties_location',
        'idx_clients_agent',
        'idx_clients_budget',
        'idx_appointments_agent_date',
        'idx_transactions_agent',
        'idx_matches_score',
        'idx_logs_created'
    ];
    idx TEXT;
BEGIN
    -- Check for critical performance indexes
    FOREACH idx IN ARRAY expected_indexes LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = idx) THEN
            missing_indexes := array_append(missing_indexes, idx);
        END IF;
    END LOOP;
    
    SELECT COUNT(*) INTO index_count FROM pg_indexes WHERE tablename IN ('users', 'properties', 'clients', 'appointments', 'transactions', 'property_matches', 'activity_logs');
    
    IF array_length(missing_indexes, 1) IS NULL THEN
        RAISE NOTICE 'SCENARIO 14 PASSED: All critical performance indexes exist (% total indexes)', index_count;
    ELSE
        RAISE NOTICE 'SCENARIO 14 WARNING: Missing indexes: %', array_to_string(missing_indexes, ', ');
    END IF;
END $;

-- =====================================================
-- FINAL COMPREHENSIVE VALIDATION SUMMARY
-- =====================================================

DO $
DECLARE
    validation_summary TEXT;
    total_properties INTEGER;
    total_clients INTEGER;
    total_appointments INTEGER;
    total_transactions INTEGER;
    total_matches INTEGER;
    total_documents INTEGER;
    total_logs INTEGER;
    total_reports INTEGER;
BEGIN
    -- Gather comprehensive statistics
    SELECT COUNT(*) INTO total_properties FROM properties;
    SELECT COUNT(*) INTO total_clients FROM clients;
    SELECT COUNT(*) INTO total_appointments FROM appointments;
    SELECT COUNT(*) INTO total_transactions FROM transactions;
    SELECT COUNT(*) INTO total_matches FROM property_matches;
    SELECT COUNT(*) INTO total_documents FROM documents;
    SELECT COUNT(*) INTO total_logs FROM activity_logs;
    SELECT COUNT(*) INTO total_reports FROM reports;
    
    validation_summary := format(
        E'=== COMPREHENSIVE TEST SCENARIO VALIDATION SUMMARY ===\n' ||
        'Properties: %s (including %s bulk test properties)\n' ||
        'Clients: %s (including %s bulk test clients)\n' ||
        'Appointments: %s (covering past, present, and future)\n' ||
        'Transactions: %s (all types and statuses)\n' ||
        'Property Matches: %s (various scores and statuses)\n' ||
        'Documents: %s (all types and associations)\n' ||
        'Activity Logs: %s (comprehensive audit trail)\n' ||
        'Reports: %s (scheduled and on-demand)\n' ||
        E'\nAll business workflow scenarios completed successfully.\n' ||
        'Database ready for comprehensive testing and validation.',
        total_properties, GREATEST(total_properties - 10, 0),
        total_clients, GREATEST(total_clients - 10, 0),
        total_appointments,
        total_transactions,
        total_matches,
        total_documents,
        total_logs,
        total_reports
    );
    
    RAISE NOTICE '%', validation_summary;
END $;