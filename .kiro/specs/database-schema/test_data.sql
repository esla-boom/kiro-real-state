-- Real Estate Dashboard Test Data Generation
-- This script creates realistic test data for all tables
-- Run after schema.sql to populate the database with test scenarios

-- =====================================================
-- CLEAR EXISTING DATA (for testing purposes)
-- =====================================================
-- Uncomment the following lines to clear existing data before inserting test data
-- TRUNCATE TABLE activity_logs CASCADE;
-- TRUNCATE TABLE property_matches CASCADE;
-- TRUNCATE TABLE client_preferences CASCADE;
-- TRUNCATE TABLE reports CASCADE;
-- TRUNCATE TABLE transactions CASCADE;
-- TRUNCATE TABLE documents CASCADE;
-- TRUNCATE TABLE appointments CASCADE;
-- TRUNCATE TABLE clients CASCADE;
-- TRUNCATE TABLE properties CASCADE;
-- TRUNCATE TABLE users CASCADE;

-- =====================================================
-- 1. TEST USERS DATA
-- =====================================================

-- Admin users
INSERT INTO users (user_id, username, email, password_hash, first_name, last_name, role, phone) VALUES
('11111111-1111-1111-1111-111111111111', 'admin', 'admin@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'System', 'Administrator', 'admin', '+1-555-0001'),
('22222222-2222-2222-2222-222222222222', 'manager1', 'manager@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Sarah', 'Johnson', 'manager', '+1-555-0002');

-- Agent users
INSERT INTO users (user_id, username, email, password_hash, first_name, last_name, role, phone, last_login_at) VALUES
('33333333-3333-3333-3333-333333333333', 'agent1', 'john.smith@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'John', 'Smith', 'agent', '+1-555-0101', '2024-12-09 14:30:00'),
('44444444-4444-4444-4444-444444444444', 'agent2', 'maria.garcia@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Maria', 'Garcia', 'agent', '+1-555-0102', '2024-12-09 16:45:00'),
('55555555-5555-5555-5555-555555555555', 'agent3', 'david.wilson@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'David', 'Wilson', 'agent', '+1-555-0103', '2024-12-08 09:15:00'),
('66666666-6666-6666-6666-666666666666', 'agent4', 'lisa.brown@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Lisa', 'Brown', 'agent', '+1-555-0104', '2024-12-09 11:20:00'),
('77777777-7777-7777-7777-777777777777', 'agent5', 'michael.davis@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Michael', 'Davis', 'agent', '+1-555-0105', '2024-12-07 13:45:00');

-- Inactive user for testing
INSERT INTO users (user_id, username, email, password_hash, first_name, last_name, role, status, phone) VALUES
('88888888-8888-8888-8888-888888888888', 'inactive_agent', 'inactive@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Former', 'Agent', 'agent', 'inactive', '+1-555-0199');

-- =====================================================
-- 2. TEST PROPERTIES DATA
-- =====================================================

-- Luxury properties
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Luxury Downtown Penthouse', 'Stunning penthouse with panoramic city views, modern amenities, and premium finishes throughout.', '123 Main St, Downtown, NY 10001', 40.7589, -73.9851, 2500000.00, 250.00, '25m x 10m', 3, 3, 'apartment', 'available', '33333333-3333-3333-3333-333333333333'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Modern Family Villa', 'Spacious family home with garden, pool, and 4-car garage in prestigious neighborhood.', '456 Oak Avenue, Suburbia, NY 10002', 40.7505, -73.9934, 1800000.00, 400.00, '20m x 20m', 5, 4, 'villa', 'available', '44444444-4444-4444-4444-444444444444'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Waterfront Condo', 'Beautiful waterfront condominium with private balcony and marina access.', '789 Harbor View, Waterfront, NY 10003', 40.7282, -74.0776, 950000.00, 120.00, '12m x 10m', 2, 2, 'condo', 'pending', '55555555-5555-5555-5555-555555555555');

-- Mid-range properties
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Cozy Suburban House', 'Well-maintained family home with updated kitchen and finished basement.', '321 Elm Street, Midtown, NY 10004', 40.7614, -73.9776, 650000.00, 180.00, '15m x 12m', 3, 2, 'house', 'available', '66666666-6666-6666-6666-666666666666'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Urban Townhouse', 'Modern townhouse in trendy neighborhood with rooftop terrace.', '654 Pine Road, Uptown, NY 10005', 40.7831, -73.9712, 850000.00, 200.00, '10m x 20m', 3, 3, 'townhouse', 'available', '77777777-7777-7777-7777-777777777777'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Downtown Loft', 'Converted warehouse loft with exposed brick and high ceilings.', '987 Industrial Blvd, Arts District, NY 10006', 40.7505, -73.9857, 750000.00, 150.00, '15m x 10m', 2, 1, 'apartment', 'sold', '33333333-3333-3333-3333-333333333333');

-- Affordable properties
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'Starter Home', 'Perfect first home with updated appliances and private yard.', '147 Maple Drive, Eastside, NY 10007', 40.7282, -73.9442, 425000.00, 110.00, '11m x 10m', 2, 1, 'house', 'available', '44444444-4444-4444-4444-444444444444'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'City Apartment', 'Convenient city living with easy access to public transportation.', '258 Broadway, Central, NY 10008', 40.7614, -73.9857, 380000.00, 85.00, '10m x 8.5m', 1, 1, 'apartment', 'rented', '55555555-5555-5555-5555-555555555555'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'Garden Apartment', 'Ground floor apartment with private garden access.', '369 Garden Lane, Westside, NY 10009', 40.7505, -74.0059, 520000.00, 95.00, '12m x 8m', 2, 1, 'apartment', 'available', '66666666-6666-6666-6666-666666666666');

-- Commercial property
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'Prime Retail Space', 'High-traffic retail location with excellent visibility and parking.', '741 Commerce Street, Business District, NY 10010', 40.7589, -73.9776, 1200000.00, 300.00, '20m x 15m', 0, 2, 'commercial', 'available', '77777777-7777-7777-7777-777777777777');

-- =====================================================
-- 3. TEST CLIENTS DATA
-- =====================================================

-- High-budget clients
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('aaaaaaaa-1111-1111-1111-111111111111', 'Robert', 'Johnson', 'robert.johnson@email.com', '+1-555-1001', 1500000.00, 3000000.00, 'active', '33333333-3333-3333-3333-333333333333', 'Looking for luxury penthouse, prefers downtown area'),
('bbbbbbbb-2222-2222-2222-222222222222', 'Jennifer', 'Williams', 'jennifer.williams@email.com', '+1-555-1002', 1200000.00, 2000000.00, 'active', '44444444-4444-4444-4444-444444444444', 'Family with teenagers, needs good schools nearby'),
('cccccccc-3333-3333-3333-333333333333', 'Thomas', 'Anderson', 'thomas.anderson@email.com', '+1-555-1003', 800000.00, 1500000.00, 'pending', '55555555-5555-5555-5555-555555555555', 'First-time luxury buyer, needs guidance');

-- Mid-range clients
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('dddddddd-4444-4444-4444-444444444444', 'Sarah', 'Miller', 'sarah.miller@email.com', '+1-555-1004', 500000.00, 800000.00, 'active', '66666666-6666-6666-6666-666666666666', 'Young professional, prefers modern amenities'),
('eeeeeeee-5555-5555-5555-555555555555', 'James', 'Davis', 'james.davis@email.com', '+1-555-1005', 600000.00, 900000.00, 'active', '77777777-7777-7777-7777-777777777777', 'Growing family, needs 3+ bedrooms'),
('ffffffff-6666-6666-6666-666666666666', 'Emily', 'Wilson', 'emily.wilson@email.com', '+1-555-1006', 400000.00, 700000.00, 'converted', '33333333-3333-3333-3333-333333333333', 'Recently purchased downtown loft');

-- Budget-conscious clients
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('gggggggg-7777-7777-7777-777777777777', 'Michael', 'Brown', 'michael.brown@email.com', '+1-555-1007', 300000.00, 500000.00, 'active', '44444444-4444-4444-4444-444444444444', 'First-time homebuyer, flexible on location'),
('hhhhhhhh-8888-8888-8888-888888888888', 'Lisa', 'Taylor', 'lisa.taylor@email.com', '+1-555-1008', 250000.00, 400000.00, 'active', '55555555-5555-5555-5555-555555555555', 'Single professional, prefers city living'),
('iiiiiiii-9999-9999-9999-999999999999', 'David', 'Martinez', 'david.martinez@email.com', '+1-555-1009', 350000.00, 550000.00, 'inactive', '66666666-6666-6666-6666-666666666666', 'Put search on hold due to job change');

-- Commercial client
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('jjjjjjjj-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Corporate', 'Buyer', 'corporate@business.com', '+1-555-1010', 1000000.00, 2000000.00, 'active', '77777777-7777-7777-7777-777777777777', 'Looking for retail space, high foot traffic essential');

-- =====================================================
-- 4. TEST CLIENT PREFERENCES DATA
-- =====================================================

INSERT INTO client_preferences (client_id, property_type, min_bedrooms, max_bedrooms, min_bathrooms, max_bathrooms, preferred_areas, max_distance_km, amenities, additional_requirements) VALUES
('aaaaaaaa-1111-1111-1111-111111111111', 'apartment', 2, 4, 2, 4, '["Downtown", "Midtown", "Uptown"]', 5.0, '["gym", "concierge", "parking", "pool", "city_view"]', 'Must have elevator and doorman'),
('bbbbbbbb-2222-2222-2222-222222222222', 'villa', 4, 6, 3, 5, '["Suburbia", "Westside"]', 15.0, '["garden", "garage", "pool", "security"]', 'Near good schools, quiet neighborhood'),
('cccccccc-3333-3333-3333-333333333333', 'condo', 2, 3, 2, 3, '["Waterfront", "Downtown"]', 8.0, '["parking", "gym", "water_view"]', 'Modern building with amenities'),
('dddddddd-4444-4444-4444-444444444444', 'apartment', 1, 2, 1, 2, '["Central", "Arts District"]', 10.0, '["gym", "laundry", "parking"]', 'Close to public transportation'),
('eeeeeeee-5555-5555-5555-555555555555', 'house', 3, 4, 2, 3, '["Midtown", "Eastside", "Westside"]', 12.0, '["garage", "garden", "updated_kitchen"]', 'Family-friendly neighborhood'),
('gggggggg-7777-7777-7777-777777777777', 'house', 2, 3, 1, 2, '["Eastside", "Westside"]', 20.0, '["parking", "garden"]', 'Starter home, good condition'),
('hhhhhhhh-8888-8888-8888-888888888888', 'apartment', 1, 2, 1, 2, '["Central", "Downtown"]', 5.0, '["gym", "laundry", "security"]', 'Walking distance to work'),
('jjjjjjjj-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'commercial', 0, 0, 1, 3, '["Business District", "Downtown"]', 3.0, '["parking", "visibility", "foot_traffic"]', 'Ground floor retail preferred');

-- =====================================================
-- 5. TEST PROPERTY MATCHES DATA
-- =====================================================

INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status, agent_notes) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'aaaaaaaa-1111-1111-1111-111111111111', 95.5, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 90}', 'sent', 'Perfect match - luxury penthouse in preferred area'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bbbbbbbb-2222-2222-2222-222222222222', 88.0, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 85}', 'interested', 'Client very interested, scheduling second viewing'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'cccccccc-3333-3333-3333-333333333333', 82.5, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 75}', 'viewed', 'Client liked the property but wants to see more options'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'dddddddd-4444-4444-4444-444444444444', 75.0, '{"price_match": true, "location_match": false, "bedrooms_match": true, "amenities_match": 80}', 'new', 'Good match but location not ideal for client'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'eeeeeeee-5555-5555-5555-555555555555', 91.0, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 95}', 'sent', 'Excellent match for growing family'),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'gggggggg-7777-7777-7777-777777777777', 85.5, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 70}', 'interested', 'First-time buyer very excited about this property'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'hhhhhhhh-8888-8888-8888-888888888888', 78.0, '{"price_match": true, "location_match": true, "bedrooms_match": true, "amenities_match": 65}', 'rejected', 'Client found apartment too small'),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'jjjjjjjj-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 92.0, '{"price_match": true, "location_match": true, "visibility_match": true, "foot_traffic_match": 95}', 'new', 'Prime retail location matches all requirements');

-- =====================================================
-- 6. TEST APPOINTMENTS DATA
-- =====================================================

-- Recent and upcoming appointments
INSERT INTO appointments (appointment_id, appointment_type, appointment_date, appointment_time, duration_minutes, status, client_id, property_id, agent_id, notes) VALUES
('11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'viewing', '2024-12-10', '10:00:00', 60, 'scheduled', 'aaaaaaaa-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'First viewing of penthouse'),
('22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'viewing', '2024-12-10', '14:30:00', 90, 'confirmed', 'bbbbbbbb-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444', 'Family viewing with children'),
('33333333-cccc-cccc-cccc-cccccccccccc', 'inspection', '2024-12-11', '09:00:00', 120, 'scheduled', 'cccccccc-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '55555555-5555-5555-5555-555555555555', 'Professional inspection before offer'),
('44444444-dddd-dddd-dddd-dddddddddddd', 'meeting', '2024-12-11', '16:00:00', 45, 'scheduled', 'dddddddd-4444-4444-4444-444444444444', NULL, '66666666-6666-6666-6666-666666666666', 'Initial consultation meeting'),
('55555555-eeee-eeee-eeee-eeeeeeeeeeee', 'viewing', '2024-12-12', '11:00:00', 60, 'scheduled', 'eeeeeeee-5555-5555-5555-555555555555', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '77777777-7777-7777-7777-777777777777', 'Second viewing requested');

-- Past appointments
INSERT INTO appointments (appointment_id, appointment_type, appointment_date, appointment_time, duration_minutes, status, client_id, property_id, agent_id, notes) VALUES
('66666666-ffff-ffff-ffff-ffffffffffff', 'viewing', '2024-12-08', '15:00:00', 60, 'completed', 'ffffffff-6666-6666-6666-666666666666', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '33333333-3333-3333-3333-333333333333', 'Client loved the loft, made offer same day'),
('77777777-gggg-gggg-gggg-gggggggggggg', 'viewing', '2024-12-07', '13:30:00', 45, 'completed', 'gggggggg-7777-7777-7777-777777777777', 'gggggggg-gggg-gggg-gggg-gggggggggggg', '44444444-4444-4444-4444-444444444444', 'Positive feedback, client considering offer'),
('88888888-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'viewing', '2024-12-06', '10:00:00', 30, 'no_show', 'hhhhhhhh-8888-8888-8888-888888888888', 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', '55555555-5555-5555-5555-555555555555', 'Client did not show up, rescheduled'),
('99999999-iiii-iiii-iiii-iiiiiiiiiiii', 'consultation', '2024-12-05', '14:00:00', 60, 'cancelled', 'iiiiiiii-9999-9999-9999-999999999999', NULL, '66666666-6666-6666-6666-666666666666', 'Client cancelled due to job situation');

-- =====================================================
-- 7. TEST DOCUMENTS DATA
-- =====================================================

INSERT INTO documents (document_id, filename, file_path, file_size, mime_type, document_type, title, description, property_id, client_id, uploaded_by, is_public) VALUES
('doc11111-1111-1111-1111-111111111111', 'penthouse_photos.zip', '/uploads/properties/penthouse_photos.zip', 15728640, 'application/zip', 'photo', 'Penthouse Photo Gallery', 'Professional photos of luxury penthouse', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '33333333-3333-3333-3333-333333333333', true),
('doc22222-2222-2222-2222-222222222222', 'villa_floorplan.pdf', '/uploads/properties/villa_floorplan.pdf', 2097152, 'application/pdf', 'other', 'Villa Floor Plan', 'Architectural floor plan and dimensions', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', NULL, '44444444-4444-4444-4444-444444444444', true),
('doc33333-3333-3333-3333-333333333333', 'condo_inspection.pdf', '/uploads/properties/condo_inspection.pdf', 5242880, 'application/pdf', 'report', 'Property Inspection Report', 'Professional inspection report', 'cccccccc-cccc-cccc-cccc-cccccccccccc', NULL, '55555555-5555-5555-5555-555555555555', false),
('doc44444-4444-4444-4444-444444444444', 'purchase_contract.pdf', '/uploads/contracts/purchase_contract.pdf', 1048576, 'application/pdf', 'contract', 'Purchase Agreement', 'Signed purchase agreement for downtown loft', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'ffffffff-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', false),
('doc55555-5555-5555-5555-555555555555', 'client_id_copy.pdf', '/uploads/clients/client_id_copy.pdf', 524288, 'application/pdf', 'client_doc', 'Client ID Verification', 'Copy of client identification', NULL, 'aaaaaaaa-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', false),
('doc66666-6666-6666-6666-666666666666', 'mortgage_preapproval.pdf', '/uploads/clients/mortgage_preapproval.pdf', 786432, 'application/pdf', 'client_doc', 'Mortgage Pre-approval', 'Bank pre-approval letter', NULL, 'bbbbbbbb-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', false),
('doc77777-7777-7777-7777-777777777777', 'property_certificate.pdf', '/uploads/properties/property_certificate.pdf', 1572864, 'application/pdf', 'certificate', 'Property Title Certificate', 'Official property ownership certificate', 'dddddddd-dddd-dddd-dddd-dddddddddddd', NULL, '66666666-6666-6666-6666-666666666666', false);

-- =====================================================
-- 8. TEST TRANSACTIONS DATA
-- =====================================================

INSERT INTO transactions (transaction_id, transaction_type, amount, currency, transaction_date, status, description, reference_number, property_id, client_id, agent_id) VALUES
('txn11111-1111-1111-1111-111111111111', 'commission', 75000.00, 'USD', '2024-12-08', 'paid', 'Commission from downtown loft sale', 'COM-2024-001', 'ffffffff-ffff-ffff-ffff-ffffffffffff', 'ffffffff-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333'),
('txn22222-2222-2222-2222-222222222222', 'expense', 1200.00, 'USD', '2024-12-07', 'paid', 'Professional photography for penthouse', 'EXP-2024-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '33333333-3333-3333-3333-333333333333'),
('txn33333-3333-3333-3333-333333333333', 'commission', 54000.00, 'USD', '2024-12-01', 'pending', 'Expected commission from villa sale', 'COM-2024-002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bbbbbbbb-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444'),
('txn44444-4444-4444-4444-444444444444', 'expense', 800.00, 'USD', '2024-12-05', 'paid', 'Marketing materials and signage', 'EXP-2024-002', NULL, NULL, '55555555-5555-5555-5555-555555555555'),
('txn55555-5555-5555-5555-555555555555', 'deposit', 50000.00, 'USD', '2024-12-06', 'paid', 'Earnest money deposit for condo', 'DEP-2024-001', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'cccccccc-3333-3333-3333-333333333333', '55555555-5555-5555-5555-555555555555'),
('txn66666-6666-6666-6666-666666666666', 'rental_fee', 3200.00, 'USD', '2024-12-01', 'paid', 'Monthly rental fee for city apartment', 'RENT-2024-001', 'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', NULL, '55555555-5555-5555-5555-555555555555'),
('txn77777-7777-7777-7777-777777777777', 'expense', 450.00, 'USD', '2024-11-28', 'paid', 'Property inspection fee', 'EXP-2024-003', 'dddddddd-dddd-dddd-dddd-dddddddddddd', NULL, '66666666-6666-6666-6666-666666666666'),
('txn88888-8888-8888-8888-888888888888', 'commission', 36000.00, 'USD', '2024-11-15', 'paid', 'Commission from retail space lease', 'COM-2024-003', 'jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'jjjjjjjj-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '77777777-7777-7777-7777-777777777777');

-- =====================================================
-- 9. TEST ACTIVITY LOGS DATA
-- =====================================================

INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, old_values, new_values, ip_address, user_agent, session_id) VALUES
('33333333-3333-3333-3333-333333333333', 'CREATE', 'property', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '{"title": "Luxury Downtown Penthouse", "price": 2500000.00, "status": "available"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'sess_001'),
('44444444-4444-4444-4444-444444444444', 'UPDATE', 'property', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '{"status": "available"}', '{"status": "pending"}', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'sess_002'),
('55555555-5555-5555-5555-555555555555', 'CREATE', 'client', 'cccccccc-3333-3333-3333-333333333333', NULL, '{"first_name": "Thomas", "last_name": "Anderson", "email": "thomas.anderson@email.com"}', '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'sess_003'),
('66666666-6666-6666-6666-666666666666', 'CREATE', 'appointment', '11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', NULL, '{"appointment_type": "viewing", "appointment_date": "2024-12-10", "status": "scheduled"}', '192.168.1.103', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15', 'sess_004'),
('77777777-7777-7777-7777-777777777777', 'UPDATE', 'appointment', '66666666-ffff-ffff-ffff-ffffffffffff', '{"status": "scheduled"}', '{"status": "completed"}', '192.168.1.104', 'Mozilla/5.0 (Android 13; Mobile; rv:109.0) Gecko/109.0 Firefox/109.0', 'sess_005'),
('33333333-3333-3333-3333-333333333333', 'CREATE', 'transaction', 'txn11111-1111-1111-1111-111111111111', NULL, '{"transaction_type": "commission", "amount": 75000.00, "status": "paid"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'sess_006'),
('44444444-4444-4444-4444-444444444444', 'LOGIN', 'user', '44444444-4444-4444-4444-444444444444', NULL, '{"login_time": "2024-12-09 16:45:00", "ip_address": "192.168.1.101"}', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'sess_007'),
('55555555-5555-5555-5555-555555555555', 'DELETE', 'document', 'doc99999-9999-9999-9999-999999999999', '{"filename": "old_contract.pdf", "document_type": "contract"}', NULL, '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'sess_008');

-- =====================================================
-- 10. TEST REPORTS DATA
-- =====================================================

INSERT INTO reports (report_id, report_name, report_type, parameters, created_by, is_scheduled, schedule_frequency, last_run_at, next_run_at) VALUES
('rpt11111-1111-1111-1111-111111111111', 'Monthly Sales Report', 'sales', '{"date_range": "monthly", "include_pending": true, "group_by": "agent"}', '22222222-2222-2222-2222-222222222222', true, 'monthly', '2024-12-01 09:00:00', '2025-01-01 09:00:00'),
('rpt22222-2222-2222-2222-222222222222', 'Property Inventory Report', 'properties', '{"status_filter": ["available", "pending"], "property_types": ["apartment", "house", "condo"]}', '22222222-2222-2222-2222-222222222222', false, NULL, NULL, NULL),
('rpt33333-3333-3333-3333-333333333333', 'Agent Performance Dashboard', 'financial', '{"date_range": "quarterly", "metrics": ["commission", "expenses", "net_income"], "agents": "all"}', '11111111-1111-1111-1111-111111111111', true, 'quarterly', '2024-10-01 08:00:00', '2025-01-01 08:00:00'),
('rpt44444-4444-4444-4444-444444444444', 'Client Activity Summary', 'clients', '{"status_filter": ["active", "pending"], "include_preferences": true, "date_range": "last_30_days"}', '33333333-3333-3333-3333-333333333333', false, NULL, NULL, NULL),
('rpt55555-5555-5555-5555-555555555555', 'Weekly Activity Log', 'activity', '{"date_range": "weekly", "action_types": ["CREATE", "UPDATE", "DELETE"], "users": "all"}', '11111111-1111-1111-1111-111111111111', true, 'weekly', '2024-12-02 07:00:00', '2024-12-09 07:00:00');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- These queries can be used to verify the test data was inserted correctly
-- Uncomment to run verification checks

/*
-- Count records in each table
SELECT 'users' as table_name, COUNT(*) as record_count FROM users
UNION ALL
SELECT 'properties', COUNT(*) FROM properties
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'client_preferences', COUNT(*) FROM client_preferences
UNION ALL
SELECT 'property_matches', COUNT(*) FROM property_matches
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'documents', COUNT(*) FROM documents
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'activity_logs', COUNT(*) FROM activity_logs
UNION ALL
SELECT 'reports', COUNT(*) FROM reports;

-- Verify foreign key relationships
SELECT 'Properties without valid agents' as check_name, COUNT(*) as issues
FROM properties p LEFT JOIN users u ON p.agent_id = u.user_id WHERE u.user_id IS NULL
UNION ALL
SELECT 'Clients without valid agents', COUNT(*)
FROM clients c LEFT JOIN users u ON c.agent_id = u.user_id WHERE u.user_id IS NULL
UNION ALL
SELECT 'Appointments without valid clients', COUNT(*)
FROM appointments a LEFT JOIN clients c ON a.client_id = c.client_id WHERE c.client_id IS NULL;

-- Sample business queries
SELECT 'Active properties by agent' as query_type, u.first_name, u.last_name, COUNT(*) as property_count
FROM properties p JOIN users u ON p.agent_id = u.user_id
WHERE p.status = 'available'
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY property_count DESC;
*/

-- =====================================================
-- ADDITIONAL EDGE CASE TEST DATA
-- =====================================================

-- Edge case: Property with maximum values
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('edge0001-0001-0001-0001-000000000001', 'Maximum Value Property', 'Property testing maximum field values and edge cases', '999 Edge Case Boulevard, Extreme, NY 99999', 89.999999, 179.999999, 99999999.99, 9999.99, '999m x 999m', 50, 50, 'villa', 'available', '33333333-3333-3333-3333-333333333333');

-- Edge case: Property with minimum values
INSERT INTO properties (property_id, title, description, address, latitude, longitude, price, area_sqm, dimensions, bedrooms, bathrooms, property_type, status, agent_id) VALUES
('edge0002-0002-0002-0002-000000000002', 'Minimum Value Property', 'Property testing minimum field values', '1 Minimal Street, Small, NY 00001', -89.999999, -179.999999, 0.01, 0.01, '1m x 1m', 0, 0, 'apartment', 'available', '44444444-4444-4444-4444-444444444444');

-- Edge case: Client with extreme budget range
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('edge0003-0003-0003-0003-000000000003', 'Ultra', 'Wealthy', 'ultra.wealthy@billionaire.com', '+1-555-0001', 50000000.00, 99999999.99, 'active', '55555555-5555-5555-5555-555555555555', 'Ultra high net worth individual');

-- Edge case: Client with zero budget
INSERT INTO clients (client_id, first_name, last_name, email, phone, budget_min, budget_max, status, agent_id, notes) VALUES
('edge0004-0004-0004-0004-000000000004', 'Budget', 'Conscious', 'budget.conscious@frugal.com', '+1-555-0002', 0.00, 0.00, 'active', '66666666-6666-6666-6666-666666666666', 'Looking for free properties only');

-- Edge case: Appointment with maximum duration
INSERT INTO appointments (appointment_id, appointment_type, appointment_date, appointment_time, duration_minutes, status, client_id, property_id, agent_id, notes) VALUES
('edge0005-0005-0005-0005-000000000005', 'inspection', CURRENT_DATE + 5, '08:00:00', 1440, 'scheduled', 'edge0003-0003-0003-0003-000000000003', 'edge0001-0001-0001-0001-000000000001', '77777777-7777-7777-7777-777777777777', 'Full day property inspection');

-- Edge case: Transaction with maximum amount
INSERT INTO transactions (transaction_id, transaction_type, amount, currency, transaction_date, status, description, reference_number, property_id, agent_id) VALUES
('edge0006-0006-0006-0006-000000000006', 'commission', 99999999.99, 'USD', CURRENT_DATE, 'pending', 'Maximum value commission transaction', 'MAX-COMM-001', 'edge0001-0001-0001-0001-000000000001', '33333333-3333-3333-3333-333333333333');

-- Edge case: Document with maximum file size
INSERT INTO documents (document_id, filename, file_path, file_size, mime_type, document_type, title, property_id, uploaded_by) VALUES
('edge0007-0007-0007-0007-000000000007', 'maximum_size_document.zip', '/uploads/edge/max_doc.zip', 9223372036854775807, 'application/zip', 'other', 'Maximum Size Document', 'edge0001-0001-0001-0001-000000000001', '33333333-3333-3333-3333-333333333333');

-- Edge case: Activity log with maximum JSON data
INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, old_values, new_values, ip_address, user_agent, session_id) VALUES
('44444444-4444-4444-4444-444444444444', 'BULK_UPDATE', 'property', 'edge0001-0001-0001-0001-000000000001', 
'{"massive_data": "' || repeat('x', 1000) || '", "complex_structure": {"nested": {"deep": {"values": [1,2,3,4,5]}}}}',
'{"updated_data": "' || repeat('y', 1000) || '", "new_structure": {"different": {"layout": {"values": [6,7,8,9,10]}}}}',
'255.255.255.255', 'Edge Case User Agent String That Is Very Long ' || repeat('Agent', 50), 'edge_session_001');

-- =====================================================
-- COMPREHENSIVE DATA VALIDATION QUERIES
-- =====================================================

-- Final verification of all test data
DO $
DECLARE
    total_records INTEGER := 0;
    table_name TEXT;
    record_count INTEGER;
BEGIN
    RAISE NOTICE '=== COMPREHENSIVE TEST DATA VALIDATION ===';
    
    FOR table_name IN 
        SELECT t.table_name 
        FROM information_schema.tables t 
        WHERE t.table_schema = 'public' 
        AND t.table_type = 'BASE TABLE'
        AND t.table_name NOT LIKE 'pg_%'
        ORDER BY t.table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO record_count;
        total_records := total_records + record_count;
        RAISE NOTICE 'Table %: % records', table_name, record_count;
    END LOOP;
    
    RAISE NOTICE 'Total test records across all tables: %', total_records;
    
    -- Validate business relationships
    RAISE NOTICE '=== BUSINESS RELATIONSHIP VALIDATION ===';
    
    -- Properties per agent
    FOR record_count IN 
        SELECT COUNT(*) 
        FROM properties p 
        JOIN users u ON p.agent_id = u.user_id 
        WHERE u.role = 'agent'
        GROUP BY u.user_id
    LOOP
        RAISE NOTICE 'Agent has % properties', record_count;
    END LOOP;
    
    -- Clients per agent
    SELECT COUNT(*) INTO record_count FROM clients;
    RAISE NOTICE 'Total clients: %', record_count;
    
    -- Active appointments
    SELECT COUNT(*) INTO record_count FROM appointments WHERE status IN ('scheduled', 'confirmed');
    RAISE NOTICE 'Active appointments: %', record_count;
    
    -- Property matches with high scores
    SELECT COUNT(*) INTO record_count FROM property_matches WHERE match_score >= 85;
    RAISE NOTICE 'High-score property matches: %', record_count;
    
    RAISE NOTICE '=== TEST DATA GENERATION COMPLETED SUCCESSFULLY ===';
END $;operty_id, client_id, agent_id) VALUES
('edge0006-0006-0006-0006-000000000006', 'commission', 9999999.99, 'USD', CURRENT_DATE, 'pending', 'Maximum commission from ultra-luxury sale', 'MAX-COM-001', 'edge0001-0001-0001-0001-000000000001', 'edge0003-0003-0003-0003-000000000003', '33333333-3333-3333-3333-333333333333');

-- Edge case: Property match with perfect score
INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status, agent_notes) VALUES
('edge0001-0001-0001-0001-000000000001', 'edge0003-0003-0003-0003-000000000003', 100.00, '{"price_match": true, "location_match": true, "bedrooms_match": true, "bathrooms_match": true, "amenities_match": 100, "perfect_match": true}', 'new', 'Perfect match - all criteria exceeded');

-- Edge case: Property match with minimum score
INSERT INTO property_matches (property_id, client_id, match_score, match_criteria, status, agent_notes) VALUES
('edge0002-0002-0002-0002-000000000002', 'edge0004-0004-0004-0004-000000000004', 0.00, '{"price_match": false, "location_match": false, "bedrooms_match": false, "bathrooms_match": false, "amenities_match": 0}', 'rejected', 'No criteria matched - complete mismatch');

-- =====================================================
-- STRESS TEST DATA SCENARIOS
-- =====================================================

-- Scenario: Agent with maximum workload
DO $
DECLARE
    stress_agent_id UUID := '88888888-8888-8888-8888-888888888888';
    i INTEGER;
BEGIN
    -- Create stress test agent
    INSERT INTO users (user_id, username, email, password_hash, first_name, last_name, role, phone) 
    VALUES (stress_agent_id, 'stress_agent', 'stress@test.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'Stress', 'Agent', 'agent', '+1-555-9999');
    
    -- Create 50 properties for stress agent
    FOR i IN 1..50 LOOP
        INSERT INTO properties (title, description, address, latitude, longitude, price, area_sqm, bedrooms, bathrooms, property_type, status, agent_id)
        VALUES ('Stress Property ' || i, 'High volume test property', i || ' Stress Street', 40.7500 + (i * 0.001), -73.9850 + (i * 0.001), 400000 + (i * 10000), 100 + i, 2, 1, 'apartment', 'available', stress_agent_id);
    END LOOP;
    
    -- Create 100 clients for stress agent
    FOR i IN 1..100 LOOP
        INSERT INTO clients (first_name, last_name, email, phone, budget_min, budget_max, status, agent_id)
        VALUES ('StressClient' || i, 'Test', 'stress' || i || '@test.com', '+1-555-' || (8000 + i), 300000, 600000, 'active', stress_agent_id);
    END LOOP;
    
    RAISE NOTICE 'Created stress test scenario: 1 agent with 50 properties and 100 clients';
END $;

-- =====================================================
-- BUSINESS LOGIC VALIDATION TEST DATA
-- =====================================================

-- Test data for complex business scenarios
INSERT INTO client_preferences (client_id, property_type, min_bedrooms, max_bedrooms, min_bathrooms, max_bathrooms, preferred_areas, max_distance_km, amenities, additional_requirements) VALUES
('edge0003-0003-0003-0003-000000000003', 'villa', 10, 20, 8, 15, '["Exclusive", "Waterfront", "Private Island"]', 50.0, '["helipad", "wine_cellar", "home_theater", "spa", "tennis_court", "marina"]', 'Must have ocean views and complete privacy'),
('edge0004-0004-0004-0004-000000000004', 'apartment', 0, 1, 0, 1, '["Affordable", "Public Transport"]', 100.0, '["laundry", "heat_included"]', 'Lowest possible rent, utilities included preferred');

-- Complex appointment scheduling scenario
INSERT INTO appointments (appointment_type, appointment_date, appointment_time, duration_minutes, status, client_id, property_id, agent_id, notes) VALUES
('viewing', CURRENT_DATE + 1, '09:00:00', 30, 'scheduled', 'aaaaaaaa-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Back-to-back appointment 1'),
('viewing', CURRENT_DATE + 1, '09:30:00', 30, 'scheduled', 'bbbbbbbb-2222-2222-2222-222222222222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'Back-to-back appointment 2'),
('viewing', CURRENT_DATE + 1, '10:00:00', 30, 'scheduled', 'cccccccc-3333-3333-3333-333333333333', 'cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'Back-to-back appointment 3');

-- Multi-currency transaction test
INSERT INTO transactions (transaction_type, amount, currency, transaction_date, status, description, reference_number, agent_id) VALUES
('commission', 45000.00, 'EUR', CURRENT_DATE - 10, 'paid', 'International property sale commission', 'EUR-COM-001', '44444444-4444-4444-4444-444444444444'),
('expense', 2500.00, 'GBP', CURRENT_DATE - 5, 'paid', 'London property marketing expenses', 'GBP-EXP-001', '55555555-5555-5555-5555-555555555555'),
('commission', 8500000.00, 'JPY', CURRENT_DATE - 15, 'paid', 'Tokyo property sale commission', 'JPY-COM-001', '66666666-6666-6666-6666-666666666666');

-- =====================================================
-- DATA INTEGRITY VALIDATION SCENARIOS
-- =====================================================

-- Create scenarios that test constraint validation
-- These should be used in validation tests to ensure constraints work properly

-- Document with large file size for testing
INSERT INTO documents (filename, file_path, file_size, mime_type, document_type, title, description, property_id, uploaded_by, is_public) VALUES
('large_property_video.mp4', '/uploads/videos/large_video.mp4', 2147483647, 'video/mp4', 'photo', 'Property Virtual Tour', '4K virtual tour of luxury property', 'edge0001-0001-0001-0001-000000000001', '33333333-3333-3333-3333-333333333333', true);

-- Activity logs for comprehensive audit trail testing
INSERT INTO activity_logs (user_id, action_type, entity_type, entity_id, old_values, new_values, ip_address, user_agent, session_id) VALUES
('33333333-3333-3333-3333-333333333333', 'CREATE', 'property', 'edge0001-0001-0001-0001-000000000001', NULL, '{"title": "Maximum Value Property", "price": 99999999.99, "status": "available"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'edge_sess_001'),
('44444444-4444-4444-4444-444444444444', 'UPDATE', 'property', 'edge0002-0002-0002-0002-000000000002', '{"price": 0.01}', '{"price": 1.00}', '192.168.1.101', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'edge_sess_002'),
('55555555-5555-5555-5555-555555555555', 'DELETE', 'appointment', 'deleted-appointment-id', '{"status": "cancelled", "notes": "Client no longer interested"}', NULL, '192.168.1.102', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36', 'edge_sess_003');

-- Reports with complex parameters for testing
INSERT INTO reports (report_name, report_type, parameters, created_by, is_scheduled, schedule_frequency, next_run_at) VALUES
('Complex Property Analysis', 'properties', '{"date_range": {"start": "2024-01-01", "end": "2024-12-31"}, "price_range": {"min": 500000, "max": 2000000}, "property_types": ["apartment", "condo"], "status_filter": ["available", "pending"], "agent_filter": ["33333333-3333-3333-3333-333333333333"], "include_metrics": ["viewing_count", "match_count", "days_on_market"], "sort_by": "price", "sort_order": "desc", "limit": 100}', '22222222-2222-2222-2222-222222222222', false, NULL, NULL),
('Advanced Financial Dashboard', 'financial', '{"date_range": "last_12_months", "transaction_types": ["commission", "expense", "rental_fee"], "currency_filter": ["USD", "EUR"], "agent_breakdown": true, "property_breakdown": true, "monthly_aggregation": true, "include_projections": true, "benchmark_comparison": true}', '11111111-1111-1111-1111-111111111111', true, 'monthly', '2025-01-01 08:00:00');

-- =====================================================
-- VERIFICATION QUERIES FOR ENHANCED TEST DATA
-- =====================================================

-- Verify edge case data was inserted correctly
SELECT 'EDGE CASE VERIFICATION' as test_type,
    (SELECT COUNT(*) FROM properties WHERE property_id LIKE 'edge%') as edge_properties,
    (SELECT COUNT(*) FROM clients WHERE client_id LIKE 'edge%') as edge_clients,
    (SELECT COUNT(*) FROM appointments WHERE appointment_id LIKE 'edge%') as edge_appointments,
    (SELECT COUNT(*) FROM transactions WHERE transaction_id LIKE 'edge%') as edge_transactions,
    (SELECT COUNT(*) FROM property_matches WHERE property_id LIKE 'edge%' OR client_id LIKE 'edge%') as edge_matches;

-- Verify stress test data
SELECT 'STRESS TEST VERIFICATION' as test_type,
    (SELECT COUNT(*) FROM users WHERE username = 'stress_agent') as stress_agents,
    (SELECT COUNT(*) FROM properties WHERE title LIKE 'Stress Property%') as stress_properties,
    (SELECT COUNT(*) FROM clients WHERE first_name LIKE 'StressClient%') as stress_clients;

-- Verify business logic test scenarios
SELECT 'BUSINESS LOGIC VERIFICATION' as test_type,
    (SELECT COUNT(*) FROM client_preferences WHERE amenities::text LIKE '%helipad%') as luxury_preferences,
    (SELECT COUNT(*) FROM appointments WHERE notes LIKE 'Back-to-back%') as scheduled_sequence,
    (SELECT COUNT(DISTINCT currency) FROM transactions) as currency_variety;

-- =====================================================
-- END OF ENHANCED TEST DATA SCRIPT
-- =====================================================