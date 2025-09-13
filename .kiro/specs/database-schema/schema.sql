-- Real Estate Dashboard Database Schema
-- Created: December 2024
-- Database: PostgreSQL (can be adapted for MySQL/SQLite)

-- Enable UUID extension for PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'agent', 'manager')),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_phone CHECK (phone ~* '^\+?[1-9]\d{1,14}$' OR phone IS NULL)
);

-- =====================================================
-- 2. PROPERTIES TABLE
-- =====================================================
CREATE TABLE properties (
    property_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8) CHECK (latitude >= -90 AND latitude <= 90),
    longitude DECIMAL(11, 8) CHECK (longitude >= -180 AND longitude <= 180),
    price DECIMAL(12, 2) NOT NULL CHECK (price > 0),
    area_sqm DECIMAL(8, 2) CHECK (area_sqm > 0),
    dimensions VARCHAR(50),
    bedrooms INTEGER CHECK (bedrooms >= 0),
    bathrooms INTEGER CHECK (bathrooms >= 0),
    property_type VARCHAR(50) NOT NULL CHECK (property_type IN ('apartment', 'house', 'condo', 'villa', 'townhouse', 'commercial')),
    status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'pending', 'sold', 'rented', 'withdrawn')),
    agent_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_properties_agent FOREIGN KEY (agent_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- =====================================================
-- 3. CLIENTS TABLE
-- =====================================================
CREATE TABLE clients (
    client_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    budget_min DECIMAL(12, 2) CHECK (budget_min >= 0),
    budget_max DECIMAL(12, 2) CHECK (budget_max >= budget_min),
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'pending', 'inactive', 'converted')),
    agent_id UUID NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_clients_agent FOREIGN KEY (agent_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT valid_client_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_client_phone CHECK (phone ~* '^\+?[1-9]\d{1,14}$' OR phone IS NULL),
    CONSTRAINT unique_client_email_per_agent UNIQUE (agent_id, email)
);

-- =====================================================
-- 4. APPOINTMENTS TABLE
-- =====================================================
CREATE TABLE appointments (
    appointment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_type VARCHAR(50) NOT NULL CHECK (appointment_type IN ('viewing', 'meeting', 'inspection', 'consultation')),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 60 CHECK (duration_minutes > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'completed', 'cancelled', 'no_show')),
    client_id UUID NOT NULL,
    property_id UUID,
    agent_id UUID NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_appointments_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_appointments_property FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE SET NULL,
    CONSTRAINT fk_appointments_agent FOREIGN KEY (agent_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT future_appointment CHECK (appointment_date >= CURRENT_DATE OR status IN ('completed', 'cancelled'))
);

-- =====================================================
-- 5. DOCUMENTS TABLE
-- =====================================================
CREATE TABLE documents (
    document_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    mime_type VARCHAR(100) NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('contract', 'photo', 'certificate', 'client_doc', 'report', 'other')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    property_id UUID,
    client_id UUID,
    uploaded_by UUID NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_documents_property FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_documents_uploader FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT document_association CHECK (property_id IS NOT NULL OR client_id IS NOT NULL OR document_type = 'other')
);

-- =====================================================
-- 6. TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('commission', 'expense', 'rental_fee', 'deposit', 'refund')),
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    transaction_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'cancelled', 'refunded')),
    description TEXT NOT NULL,
    reference_number VARCHAR(100),
    property_id UUID,
    client_id UUID,
    agent_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_transactions_property FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE SET NULL,
    CONSTRAINT fk_transactions_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE SET NULL,
    CONSTRAINT fk_transactions_agent FOREIGN KEY (agent_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- =====================================================
-- 7. CLIENT PREFERENCES TABLE
-- =====================================================
CREATE TABLE client_preferences (
    preference_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL,
    property_type VARCHAR(50) CHECK (property_type IN ('apartment', 'house', 'condo', 'villa', 'townhouse', 'commercial')),
    min_bedrooms INTEGER CHECK (min_bedrooms >= 0),
    max_bedrooms INTEGER CHECK (max_bedrooms >= min_bedrooms),
    min_bathrooms INTEGER CHECK (min_bathrooms >= 0),
    max_bathrooms INTEGER CHECK (max_bathrooms >= min_bathrooms),
    preferred_areas JSONB,
    max_distance_km DECIMAL(5, 2) CHECK (max_distance_km > 0),
    amenities JSONB,
    additional_requirements TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_preferences_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Unique constraint - one preference record per client
    CONSTRAINT unique_client_preference UNIQUE (client_id)
);

-- =====================================================
-- 8. PROPERTY MATCHES TABLE
-- =====================================================
CREATE TABLE property_matches (
    match_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL,
    client_id UUID NOT NULL,
    match_score DECIMAL(5, 2) NOT NULL CHECK (match_score >= 0 AND match_score <= 100),
    match_criteria JSONB NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'sent', 'viewed', 'interested', 'rejected', 'expired')),
    agent_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_matches_property FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_matches_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    
    -- Unique constraint - one match record per property-client pair
    CONSTRAINT unique_property_client_match UNIQUE (property_id, client_id)
);

-- =====================================================
-- 9. ACTIVITY LOGS TABLE
-- =====================================================
CREATE TABLE activity_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_logs_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- =====================================================
-- 10. REPORTS TABLE
-- =====================================================
CREATE TABLE reports (
    report_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50) NOT NULL CHECK (report_type IN ('sales', 'properties', 'clients', 'financial', 'activity')),
    parameters JSONB NOT NULL,
    created_by UUID NOT NULL,
    is_scheduled BOOLEAN DEFAULT FALSE,
    schedule_frequency VARCHAR(20) CHECK (schedule_frequency IN ('daily', 'weekly', 'monthly', 'quarterly') OR schedule_frequency IS NULL),
    last_run_at TIMESTAMP WITH TIME ZONE,
    next_run_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_reports_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    
    -- Constraints
    CONSTRAINT scheduled_frequency CHECK (
        (is_scheduled = TRUE AND schedule_frequency IS NOT NULL) OR 
        (is_scheduled = FALSE AND schedule_frequency IS NULL)
    )
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- Properties indexes
CREATE INDEX idx_properties_agent ON properties(agent_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_price ON properties(price);
CREATE INDEX idx_properties_type ON properties(property_type);
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
CREATE INDEX idx_properties_bedrooms ON properties(bedrooms);
CREATE INDEX idx_properties_created ON properties(created_at);

-- Clients indexes
CREATE INDEX idx_clients_agent ON clients(agent_id);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_budget ON clients(budget_min, budget_max);
CREATE INDEX idx_clients_email ON clients(email);

-- Appointments indexes
CREATE INDEX idx_appointments_agent ON appointments(agent_id);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_property ON appointments(property_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_agent_date ON appointments(agent_id, appointment_date);

-- Documents indexes
CREATE INDEX idx_documents_property ON documents(property_id);
CREATE INDEX idx_documents_client ON documents(client_id);
CREATE INDEX idx_documents_uploader ON documents(uploaded_by);
CREATE INDEX idx_documents_type ON documents(document_type);
CREATE INDEX idx_documents_created ON documents(created_at);

-- Transactions indexes
CREATE INDEX idx_transactions_agent ON transactions(agent_id);
CREATE INDEX idx_transactions_property ON transactions(property_id);
CREATE INDEX idx_transactions_client ON transactions(client_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);

-- Property matches indexes
CREATE INDEX idx_matches_property ON property_matches(property_id);
CREATE INDEX idx_matches_client ON property_matches(client_id);
CREATE INDEX idx_matches_score ON property_matches(match_score);
CREATE INDEX idx_matches_status ON property_matches(status);

-- Activity logs indexes
CREATE INDEX idx_logs_user ON activity_logs(user_id);
CREATE INDEX idx_logs_entity ON activity_logs(entity_type, entity_id);
CREATE INDEX idx_logs_created ON activity_logs(created_at);
CREATE INDEX idx_logs_action ON activity_logs(action_type);

-- Reports indexes
CREATE INDEX idx_reports_creator ON reports(created_by);
CREATE INDEX idx_reports_type ON reports(report_type);
CREATE INDEX idx_reports_scheduled ON reports(is_scheduled);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON client_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON property_matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SAMPLE DATA INSERTION (Optional)
-- =====================================================

-- Insert sample admin user
INSERT INTO users (username, email, password_hash, first_name, last_name, role) 
VALUES ('admin', 'admin@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'System', 'Administrator', 'admin');

-- Insert sample agent
INSERT INTO users (username, email, password_hash, first_name, last_name, role) 
VALUES ('agent1', 'agent@realestate.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm', 'John', 'Agent', 'agent');

-- Note: Password hash above is for 'password123' - change in production!

-- =====================================================
-- SECURITY IMPLEMENTATION REFERENCE
-- =====================================================
-- 
-- IMPORTANT: After creating the base schema, run the security.sql script
-- to implement comprehensive security measures including:
-- 
-- 1. Database roles and permissions (re_admin, re_manager, re_agent, re_readonly)
-- 2. Row-level security policies for data isolation
-- 3. Encryption functions for sensitive data
-- 4. Enhanced audit logging with security context
-- 5. Password strength validation and secure hashing
-- 6. Security monitoring views
-- 7. Data retention and cleanup policies
-- 
-- Usage: \i security.sql
-- 
-- =====================================================