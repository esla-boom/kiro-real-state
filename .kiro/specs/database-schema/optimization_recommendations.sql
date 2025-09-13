-- Real Estate Dashboard Database Optimization Recommendations
-- This file contains specific optimization strategies based on performance testing results
-- Implement these recommendations as your database grows and performance requirements increase

-- =====================================================
-- IMMEDIATE OPTIMIZATIONS (0-1000 records per table)
-- =====================================================

-- 1. Query Optimization
-- Add missing indexes for common query patterns
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_properties_agent_status_price 
ON properties(agent_id, status, price DESC) 
WHERE status IN ('available', 'pending');

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_clients_agent_status_budget 
ON clients(agent_id, status, budget_max DESC) 
WHERE status = 'active';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_appointments_agent_date_status 
ON appointments(agent_id, appointment_date, status) 
WHERE status IN ('scheduled', 'confirmed');

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transactions_agent_date_type 
ON transactions(agent_id, transaction_date DESC, transaction_type) 
WHERE status = 'paid';

-- 2. Partial Indexes for Common Filters
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_properties_available_price 
ON properties(price) 
WHERE status = 'available';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_property_matches_high_score 
ON property_matches(match_score DESC, created_at DESC) 
WHERE match_score >= 80 AND status IN ('new', 'sent');

-- 3. JSON Indexes for Preference Matching
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_client_preferences_amenities 
ON client_preferences USING GIN (amenities);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_property_matches_criteria 
ON property_matches USING GIN (match_criteria);

-- =====================================================
-- MEDIUM SCALE OPTIMIZATIONS (1000-10000 records)
-- =====================================================

-- 1. Materialized Views for Complex Queries
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_agent_performance AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(DISTINCT p.property_id) as active_properties,
    COUNT(DISTINCT c.client_id) as active_clients,
    COUNT(DISTINCT a.appointment_id) as monthly_appointments,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'commission' THEN t.amount ELSE 0 END), 0) as monthly_commission,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'expense' THEN t.amount ELSE 0 END), 0) as monthly_expenses,
    CURRENT_DATE as last_updated
FROM users u
LEFT JOIN properties p ON u.user_id = p.agent_id AND p.status IN ('available', 'pending')
LEFT JOIN clients c ON u.user_id = c.agent_id AND c.status = 'active'
LEFT JOIN appointments a ON u.user_id = a.agent_id AND a.appointment_date >= DATE_TRUNC('month', CURRENT_DATE)
LEFT JOIN transactions t ON u.user_id = t.agent_id AND t.transaction_date >= DATE_TRUNC('month', CURRENT_DATE) AND t.status = 'paid'
WHERE u.role = 'agent' AND u.status = 'active'
GROUP BY u.user_id, u.first_name, u.last_name;

CREATE UNIQUE INDEX ON mv_agent_performance(user_id);

-- Refresh materialized view daily
-- Add to cron job: REFRESH MATERIALIZED VIEW CONCURRENTLY mv_agent_performance;

-- 2. Property Search Optimization View
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_property_search AS
SELECT 
    p.property_id,
    p.title,
    p.address,
    p.latitude,
    p.longitude,
    p.price,
    p.area_sqm,
    p.bedrooms,
    p.bathrooms,
    p.property_type,
    p.status,
    p.agent_id,
    u.first_name as agent_first_name,
    u.last_name as agent_last_name,
    u.phone as agent_phone,
    COUNT(DISTINCT a.appointment_id) as viewing_count,
    MAX(a.appointment_date) as last_viewing,
    AVG(pm.match_score) as avg_match_score,
    COUNT(DISTINCT pm.client_id) as interested_clients,
    EXTRACT(DAYS FROM CURRENT_DATE - p.created_at) as days_on_market
FROM properties p
JOIN users u ON p.agent_id = u.user_id
LEFT JOIN appointments a ON p.property_id = a.property_id AND a.appointment_type = 'viewing'
LEFT JOIN property_matches pm ON p.property_id = pm.property_id AND pm.status IN ('interested', 'sent')
WHERE p.status IN ('available', 'pending')
GROUP BY p.property_id, p.title, p.address, p.latitude, p.longitude, p.price, 
         p.area_sqm, p.bedrooms, p.bathrooms, p.property_type, p.status, 
         p.agent_id, u.first_name, u.last_name, u.phone, p.created_at;

CREATE INDEX ON mv_property_search(status, price);
CREATE INDEX ON mv_property_search(property_type, bedrooms, bathrooms);
CREATE INDEX ON mv_property_search(latitude, longitude);
CREATE INDEX ON mv_property_search(agent_id, status);

-- 3. Connection Pooling Configuration
-- Recommended PgBouncer configuration:
/*
[databases]
realestate_db = host=localhost port=5432 dbname=realestate_dashboard

[pgbouncer]
listen_port = 6432
listen_addr = 127.0.0.1
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20
reserve_pool_size = 5
*/

-- =====================================================
-- LARGE SCALE OPTIMIZATIONS (10000+ records)
-- =====================================================

-- 1. Table Partitioning for High-Volume Tables

-- Activity Logs Partitioning (by month)
-- First, create partitioned table structure
/*
-- Create new partitioned table
CREATE TABLE activity_logs_partitioned (
    LIKE activity_logs INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- Create monthly partitions for current and future months
CREATE TABLE activity_logs_2024_12 PARTITION OF activity_logs_partitioned
    FOR VALUES FROM ('2024-12-01') TO ('2025-01-01');

CREATE TABLE activity_logs_2025_01 PARTITION OF activity_logs_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- Migration script to move data
INSERT INTO activity_logs_partitioned SELECT * FROM activity_logs;

-- After verification, rename tables
ALTER TABLE activity_logs RENAME TO activity_logs_old;
ALTER TABLE activity_logs_partitioned RENAME TO activity_logs;
*/

-- Transactions Partitioning (by year)
/*
CREATE TABLE transactions_partitioned (
    LIKE transactions INCLUDING ALL
) PARTITION BY RANGE (transaction_date);

CREATE TABLE transactions_2024 PARTITION OF transactions_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE transactions_2025 PARTITION OF transactions_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
*/

-- 2. Advanced Indexing Strategies

-- Covering indexes for common queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_properties_search_covering 
ON properties(status, property_type, bedrooms, bathrooms) 
INCLUDE (property_id, title, price, address, agent_id)
WHERE status IN ('available', 'pending');

-- Hash indexes for exact match queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email_hash 
ON users USING HASH (email);

-- Expression indexes for computed values
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_properties_price_per_sqm 
ON properties((price / NULLIF(area_sqm, 0))) 
WHERE area_sqm > 0 AND status = 'available';

-- 3. Query Result Caching Strategy
-- Implement application-level caching for:
-- - Property search results (cache for 5 minutes)
-- - Agent performance metrics (cache for 1 hour)
-- - Popular property listings (cache for 15 minutes)
-- - Client preference matches (cache for 30 minutes)

-- =====================================================
-- ARCHIVAL AND CLEANUP STRATEGIES
-- =====================================================

-- 1. Activity Logs Archival (keep 2 years, archive older)
CREATE OR REPLACE FUNCTION archive_old_activity_logs()
RETURNS INTEGER AS $
DECLARE
    archived_count INTEGER;
BEGIN
    -- Create archive table if not exists
    CREATE TABLE IF NOT EXISTS activity_logs_archive (
        LIKE activity_logs INCLUDING ALL
    );
    
    -- Move old logs to archive
    WITH moved_logs AS (
        DELETE FROM activity_logs 
        WHERE created_at < CURRENT_DATE - INTERVAL '2 years'
        RETURNING *
    )
    INSERT INTO activity_logs_archive 
    SELECT * FROM moved_logs;
    
    GET DIAGNOSTICS archived_count = ROW_COUNT;
    
    RAISE NOTICE 'Archived % activity log records', archived_count;
    RETURN archived_count;
END;
$ LANGUAGE plpgsql;

-- 2. Transaction Archival (keep 7 years for tax compliance)
CREATE OR REPLACE FUNCTION archive_old_transactions()
RETURNS INTEGER AS $
DECLARE
    archived_count INTEGER;
BEGIN
    CREATE TABLE IF NOT EXISTS transactions_archive (
        LIKE transactions INCLUDING ALL
    );
    
    WITH moved_transactions AS (
        DELETE FROM transactions 
        WHERE transaction_date < CURRENT_DATE - INTERVAL '7 years'
        AND status = 'paid'
        RETURNING *
    )
    INSERT INTO transactions_archive 
    SELECT * FROM moved_transactions;
    
    GET DIAGNOSTICS archived_count = ROW_COUNT;
    
    RAISE NOTICE 'Archived % transaction records', archived_count;
    RETURN archived_count;
END;
$ LANGUAGE plpgsql;

-- 3. Completed Appointments Cleanup (keep 1 year)
CREATE OR REPLACE FUNCTION cleanup_old_appointments()
RETURNS INTEGER AS $
DECLARE
    cleaned_count INTEGER;
BEGIN
    DELETE FROM appointments 
    WHERE appointment_date < CURRENT_DATE - INTERVAL '1 year'
    AND status IN ('completed', 'cancelled', 'no_show');
    
    GET DIAGNOSTICS cleaned_count = ROW_COUNT;
    
    RAISE NOTICE 'Cleaned up % old appointment records', cleaned_count;
    RETURN cleaned_count;
END;
$ LANGUAGE plpgsql;

-- Schedule these functions to run monthly
-- Add to cron job or use pg_cron extension:
-- SELECT cron.schedule('archive-logs', '0 2 1 * *', 'SELECT archive_old_activity_logs();');
-- SELECT cron.schedule('archive-transactions', '0 3 1 * *', 'SELECT archive_old_transactions();');
-- SELECT cron.schedule('cleanup-appointments', '0 4 1 * *', 'SELECT cleanup_old_appointments();');

-- =====================================================
-- MONITORING AND ALERTING
-- =====================================================

-- 1. Performance Monitoring Function
CREATE OR REPLACE FUNCTION check_database_health()
RETURNS TABLE (
    metric_name TEXT,
    current_value TEXT,
    threshold TEXT,
    status TEXT,
    recommendation TEXT
) AS $
DECLARE
    cache_hit_ratio NUMERIC;
    index_usage_ratio NUMERIC;
    active_connections INTEGER;
    database_size_gb NUMERIC;
    largest_table_size_gb NUMERIC;
BEGIN
    -- Calculate metrics
    SELECT ROUND(100.0 * sum(blks_hit) / (sum(blks_hit) + sum(blks_read)), 2)
    INTO cache_hit_ratio
    FROM pg_stat_database WHERE datname = current_database();
    
    SELECT ROUND(100.0 * sum(idx_scan) / (sum(idx_scan) + sum(seq_scan)), 2)
    INTO index_usage_ratio
    FROM pg_stat_user_tables WHERE schemaname = 'public';
    
    SELECT count(*) INTO active_connections
    FROM pg_stat_activity WHERE datname = current_database() AND state = 'active';
    
    SELECT ROUND(pg_database_size(current_database()) / 1024.0^3, 2) INTO database_size_gb;
    
    SELECT ROUND(MAX(pg_total_relation_size(schemaname||'.'||tablename)) / 1024.0^3, 2)
    INTO largest_table_size_gb
    FROM pg_stat_user_tables WHERE schemaname = 'public';
    
    -- Return results
    RETURN QUERY VALUES
        ('Cache Hit Ratio', cache_hit_ratio::TEXT || '%', '>95%', 
         CASE WHEN cache_hit_ratio >= 95 THEN 'OK' ELSE 'WARNING' END,
         CASE WHEN cache_hit_ratio < 95 THEN 'Increase shared_buffers' ELSE 'Good' END),
        
        ('Index Usage Ratio', index_usage_ratio::TEXT || '%', '>80%',
         CASE WHEN index_usage_ratio >= 80 THEN 'OK' ELSE 'WARNING' END,
         CASE WHEN index_usage_ratio < 80 THEN 'Review missing indexes' ELSE 'Good' END),
        
        ('Active Connections', active_connections::TEXT, '<50',
         CASE WHEN active_connections < 50 THEN 'OK' ELSE 'WARNING' END,
         CASE WHEN active_connections >= 50 THEN 'Implement connection pooling' ELSE 'Good' END),
        
        ('Database Size', database_size_gb::TEXT || ' GB', '<10 GB',
         CASE WHEN database_size_gb < 10 THEN 'OK' ELSE 'INFO' END,
         CASE WHEN database_size_gb >= 10 THEN 'Consider archival strategy' ELSE 'Good' END),
        
        ('Largest Table', largest_table_size_gb::TEXT || ' GB', '<2 GB',
         CASE WHEN largest_table_size_gb < 2 THEN 'OK' ELSE 'INFO' END,
         CASE WHEN largest_table_size_gb >= 2 THEN 'Consider partitioning' ELSE 'Good' END);
END;
$ LANGUAGE plpgsql;

-- 2. Slow Query Detection
CREATE OR REPLACE FUNCTION detect_slow_queries(threshold_ms INTEGER DEFAULT 1000)
RETURNS TABLE (
    query_text TEXT,
    avg_time_ms NUMERIC,
    total_calls BIGINT,
    total_time_ms NUMERIC
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        LEFT(query, 200) as query_text,
        ROUND(mean_time, 2) as avg_time_ms,
        calls as total_calls,
        ROUND(total_time, 2) as total_time_ms
    FROM pg_stat_statements 
    WHERE mean_time > threshold_ms
    ORDER BY total_time DESC
    LIMIT 10;
END;
$ LANGUAGE plpgsql;

-- =====================================================
-- BACKUP AND RECOVERY OPTIMIZATION
-- =====================================================

-- 1. Backup Strategy Recommendations
/*
Daily Full Backup:
pg_dump -h localhost -U postgres -d realestate_dashboard -f backup_$(date +%Y%m%d).sql

Hourly WAL Archiving:
archive_command = 'cp %p /backup/wal_archive/%f'

Point-in-time Recovery Setup:
wal_level = replica
archive_mode = on
max_wal_senders = 3
*/

-- 2. Backup Verification Function
CREATE OR REPLACE FUNCTION verify_backup_integrity()
RETURNS TABLE (
    table_name TEXT,
    record_count BIGINT,
    last_modified TIMESTAMP WITH TIME ZONE
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        t.n_tup_ins + t.n_tup_upd as record_count,
        GREATEST(
            COALESCE(t.last_vacuum, '1970-01-01'::timestamp with time zone),
            COALESCE(t.last_autovacuum, '1970-01-01'::timestamp with time zone),
            COALESCE(t.last_analyze, '1970-01-01'::timestamp with time zone),
            COALESCE(t.last_autoanalyze, '1970-01-01'::timestamp with time zone)
        ) as last_modified
    FROM pg_stat_user_tables t
    WHERE t.schemaname = 'public'
    ORDER BY record_count DESC;
END;
$ LANGUAGE plpgsql;

-- =====================================================
-- IMPLEMENTATION CHECKLIST
-- =====================================================

/*
IMMEDIATE ACTIONS (Week 1):
□ Implement missing indexes for common queries
□ Set up connection pooling with PgBouncer
□ Configure basic monitoring with performance views
□ Implement query result caching in application

SHORT TERM (Month 1):
□ Create materialized views for complex reports
□ Set up automated VACUUM and ANALYZE schedules
□ Implement basic archival for activity logs
□ Configure backup strategy with WAL archiving

MEDIUM TERM (Quarter 1):
□ Implement table partitioning for high-volume tables
□ Set up read replicas for reporting queries
□ Advanced monitoring and alerting system
□ Performance testing with realistic data volumes

LONG TERM (Year 1):
□ Advanced partitioning strategies
□ Multi-master replication if needed
□ Advanced caching layers (Redis/Memcached)
□ Database sharding if single-server limits reached

MONITORING SCHEDULE:
□ Daily: Check database health metrics
□ Weekly: Review slow query reports
□ Monthly: Run archival and cleanup procedures
□ Quarterly: Full performance review and optimization
*/

-- =====================================================
-- END OF OPTIMIZATION RECOMMENDATIONS
-- =====================================================