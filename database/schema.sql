-- UIDE-Link Database Schema
-- Offline-First Bus Telemetry System
-- PostgreSQL 12+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Routes catalog (31 predefined routes)
CREATE TABLE routes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Operation schedules (arrivals and departures)
CREATE TABLE schedules (
    id SERIAL PRIMARY KEY,
    schedule_type VARCHAR(20) NOT NULL CHECK (schedule_type IN ('arrival', 'departure')),
    time_slot TIME NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(schedule_type, time_slot)
);

-- Buses (physical units)
CREATE TABLE buses (
    id SERIAL PRIMARY KEY,
    bus_number VARCHAR(20) NOT NULL UNIQUE,
    license_plate VARCHAR(20) UNIQUE,
    route_id INTEGER REFERENCES routes(id),
    qr_code TEXT NOT NULL UNIQUE, -- Static QR code data
    capacity INTEGER DEFAULT 40,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Students (app users)
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(20) NOT NULL UNIQUE, -- University student ID
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Drivers
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    driver_id VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    license_number VARCHAR(30),
    assigned_bus_id INTEGER REFERENCES buses(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TELEMETRY CORE TABLE
-- =====================================================

-- Scan events (ingress/egress tracking)
CREATE TABLE scan_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
    bus_id INTEGER REFERENCES buses(id) ON DELETE CASCADE,
    route_id INTEGER REFERENCES routes(id),
    
    -- Scan type
    event_type VARCHAR(10) NOT NULL CHECK (event_type IN ('ingress', 'egress')),
    
    -- Timestamps
    local_timestamp TIMESTAMP NOT NULL, -- Client device time (source of truth)
    server_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When synced to server
    
    -- Offline sync management
    sync_status VARCHAR(20) DEFAULT 'synced' CHECK (sync_status IN ('pending', 'synced', 'conflict')),
    client_id UUID, -- Client-generated UUID for idempotency
    
    -- Geolocation (optional)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Metadata
    device_info JSONB, -- Browser, OS, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id) -- Prevent duplicate syncs
);

-- Index for performance
CREATE INDEX idx_scan_events_student ON scan_events(student_id);
CREATE INDEX idx_scan_events_bus ON scan_events(bus_id);
CREATE INDEX idx_scan_events_date ON scan_events(local_timestamp);
CREATE INDEX idx_scan_events_sync_status ON scan_events(sync_status);
CREATE INDEX idx_scan_events_client_id ON scan_events(client_id);

-- =====================================================
-- SYNC QUEUE & CONFLICTS
-- =====================================================

-- Sync queue for failed operations (backup tracking)
CREATE TABLE sync_queue (
    id SERIAL PRIMARY KEY,
    scan_event_id UUID REFERENCES scan_events(id) ON DELETE CASCADE,
    retry_count INTEGER DEFAULT 0,
    last_retry_at TIMESTAMP,
    error_message TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'retrying', 'failed', 'resolved')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conflict resolution log
CREATE TABLE conflict_log (
    id SERIAL PRIMARY KEY,
    scan_event_id UUID REFERENCES scan_events(id),
    conflict_type VARCHAR(50), -- 'duplicate_scan', 'timeline_mismatch', etc.
    original_data JSONB,
    conflicting_data JSONB,
    resolution VARCHAR(20) CHECK (resolution IN ('auto_resolved', 'manual_required', 'ignored')),
    resolved_by INTEGER, -- Admin user who resolved
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ADMIN & AUDIT
-- =====================================================

-- Admin users
CREATE TABLE admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Audit log
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    user_type VARCHAR(20), -- 'student', 'driver', 'admin'
    user_id INTEGER,
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_user ON audit_log(user_type, user_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at);

-- =====================================================
-- VIEWS FOR ANALYTICS
-- =====================================================

-- Daily ridership summary
CREATE OR REPLACE VIEW daily_ridership AS
SELECT 
    DATE(local_timestamp) as date,
    route_id,
    r.name as route_name,
    COUNT(DISTINCT CASE WHEN event_type = 'ingress' THEN student_id END) as total_ingress,
    COUNT(DISTINCT CASE WHEN event_type = 'egress' THEN student_id END) as total_egress,
    COUNT(DISTINCT student_id) as unique_students
FROM scan_events se
LEFT JOIN routes r ON se.route_id = r.id
WHERE sync_status = 'synced'
GROUP BY DATE(local_timestamp), route_id, r.name
ORDER BY date DESC, route_name;

-- Real-time bus occupancy (current passengers)
CREATE OR REPLACE VIEW current_bus_occupancy AS
SELECT 
    b.id as bus_id,
    b.bus_number,
    r.name as route_name,
    COUNT(DISTINCT se.student_id) FILTER (
        WHERE se.event_type = 'ingress' 
        AND se.local_timestamp > NOW() - INTERVAL '4 hours'
        AND NOT EXISTS (
            SELECT 1 FROM scan_events se2 
            WHERE se2.student_id = se.student_id 
            AND se2.bus_id = se.bus_id 
            AND se2.event_type = 'egress' 
            AND se2.local_timestamp > se.local_timestamp
        )
    ) as current_occupancy,
    b.capacity
FROM buses b
LEFT JOIN routes r ON b.route_id = r.id
LEFT JOIN scan_events se ON se.bus_id = b.id
WHERE b.is_active = true
GROUP BY b.id, b.bus_number, r.name, b.capacity;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Update buses.updated_at on modification
CREATE OR REPLACE FUNCTION update_bus_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_bus_timestamp
BEFORE UPDATE ON buses
FOR EACH ROW
EXECUTE FUNCTION update_bus_timestamp();

-- Auto-detect scan conflicts
CREATE OR REPLACE FUNCTION detect_scan_conflicts()
RETURNS TRIGGER AS $$
DECLARE
    recent_scan_count INTEGER;
BEGIN
    -- Check for duplicate scan within 5 minutes
    SELECT COUNT(*) INTO recent_scan_count
    FROM scan_events
    WHERE student_id = NEW.student_id
      AND bus_id = NEW.bus_id
      AND event_type = NEW.event_type
      AND local_timestamp BETWEEN (NEW.local_timestamp - INTERVAL '5 minutes') 
                               AND (NEW.local_timestamp + INTERVAL '5 minutes')
      AND id != NEW.id;
    
    IF recent_scan_count > 0 THEN
        -- Mark as conflict
        NEW.sync_status = 'conflict';
        
        -- Log conflict
        INSERT INTO conflict_log (scan_event_id, conflict_type, conflicting_data, resolution)
        VALUES (NEW.id, 'duplicate_scan', row_to_json(NEW), 'manual_required');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_detect_conflicts
BEFORE INSERT ON scan_events
FOR EACH ROW
EXECUTE FUNCTION detect_scan_conflicts();

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Generate QR code data for bus (static format)
CREATE OR REPLACE FUNCTION generate_bus_qr(p_bus_id INTEGER)
RETURNS TEXT AS $$
DECLARE
    qr_data TEXT;
BEGIN
    -- Format: UIDE-BUS:{bus_id}:{bus_number}
    SELECT CONCAT('UIDE-BUS:', id, ':', bus_number)
    INTO qr_data
    FROM buses
    WHERE id = p_bus_id;
    
    RETURN qr_data;
END;
$$ LANGUAGE plpgsql;

-- Get student scan history
CREATE OR REPLACE FUNCTION get_student_history(p_student_id INTEGER, p_days INTEGER DEFAULT 7)
RETURNS TABLE (
    scan_id UUID,
    event_type VARCHAR,
    bus_number VARCHAR,
    route_name VARCHAR,
    scan_time TIMESTAMP,
    sync_status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        se.id,
        se.event_type,
        b.bus_number,
        r.name as route_name,
        se.local_timestamp,
        se.sync_status
    FROM scan_events se
    LEFT JOIN buses b ON se.bus_id = b.id
    LEFT JOIN routes r ON se.route_id = r.id
    WHERE se.student_id = p_student_id
      AND se.local_timestamp > NOW() - (p_days || ' days')::INTERVAL
    ORDER BY se.local_timestamp DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE scan_events IS 'Core telemetry table storing all bus scan events (ingress/egress)';
COMMENT ON COLUMN scan_events.local_timestamp IS 'Client device timestamp - source of truth for when scan occurred';
COMMENT ON COLUMN scan_events.server_timestamp IS 'Server timestamp when record was synced from offline queue';
COMMENT ON COLUMN scan_events.client_id IS 'Client-generated UUID for idempotency - prevents duplicate syncs';
COMMENT ON COLUMN scan_events.sync_status IS 'Tracks offline sync state: pending (queued), synced (completed), conflict (duplicate detected)';
