-- ===============================
-- schema.sql (No-login QR bus usage tracking) - PostgreSQL
-- ===============================

-- Optional but useful for UUID generation + hashing helpers
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------- Types ----------
DO $$ BEGIN
  CREATE TYPE trip_type AS ENUM ('ENTRY','EXIT');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------- Core catalogs ----------
CREATE TABLE IF NOT EXISTS routes (
  id          BIGSERIAL PRIMARY KEY,
  code        TEXT UNIQUE NOT NULL,     -- e.g., "ARMENIA"
  name        TEXT NOT NULL,            -- e.g., "La Armenia"
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS buses (
  id            BIGSERIAL PRIMARY KEY,
  bus_number    TEXT UNIQUE NOT NULL,   -- e.g., "BUS-07"
  license_plate TEXT UNIQUE,            -- e.g., "ABC-1234"
  capacity      INT,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------- QR slots (what each QR means) ----------
CREATE TABLE IF NOT EXISTS qr_slots (
  id             BIGSERIAL PRIMARY KEY,

  bus_id         BIGINT NOT NULL REFERENCES buses(id) ON DELETE RESTRICT,
  route_id       BIGINT NOT NULL REFERENCES routes(id) ON DELETE RESTRICT,

  trip_type      trip_type NOT NULL,    -- ENTRY / EXIT
  scheduled_time TIME NOT NULL,         -- e.g., 10:00

  -- Token is what you embed in the QR URL: https://domain/s/{token}
  token          TEXT UNIQUE NOT NULL,

  -- Server-side validation/fraud resistance: store a hash derived from token + secret salt.
  -- In production, generate token + HMAC/sha hash in backend and store only the hash.
  secret_hash    TEXT NOT NULL,

  -- Optional validity windows (you can enforce scan acceptance using these)
  valid_from     TIMESTAMPTZ,
  valid_to       TIMESTAMPTZ,

  is_active      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Prevent duplicate "slots" (same bus+route+type+time)
CREATE UNIQUE INDEX IF NOT EXISTS uq_qr_slot_identity
ON qr_slots(bus_id, route_id, trip_type, scheduled_time);

-- ---------- Scan events (each scan = 1 row) ----------
CREATE TABLE IF NOT EXISTS scan_events (
  id              BIGSERIAL PRIMARY KEY,

  qr_slot_id      BIGINT NOT NULL REFERENCES qr_slots(id) ON DELETE RESTRICT,

  -- Timestamps
  scanned_at      TIMESTAMPTZ NOT NULL DEFAULT now(), -- server time of record
  client_ts       TIMESTAMPTZ,                        -- optional client timestamp

  -- Idempotency: client generates UUID per attempt so refresh/retry won't double-count
  client_event_id UUID NOT NULL,

  -- Optional anonymized metadata (helpful for rate-limit / dedupe / auditing)
  device_hash     TEXT,
  ip_hash         TEXT,
  user_agent      TEXT,

  -- Optional geo fields (useful if scanning at stops)
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,

  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Idempotency guarantee
CREATE UNIQUE INDEX IF NOT EXISTS uq_scan_client_event
ON scan_events(client_event_id);

-- Reporting helper index
CREATE INDEX IF NOT EXISTS idx_scan_events_slot_time
ON scan_events(qr_slot_id, scanned_at);

-- ---------- Aggregated counters (fast dashboards) ----------
CREATE TABLE IF NOT EXISTS scan_counters (
  id         BIGSERIAL PRIMARY KEY,
  qr_slot_id BIGINT NOT NULL REFERENCES qr_slots(id) ON DELETE RESTRICT,
  day        DATE NOT NULL,
  count      BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(qr_slot_id, day)
);

CREATE INDEX IF NOT EXISTS idx_scan_counters_day
ON scan_counters(day);

-- ---------- (Optional) Views for reporting ----------
-- A convenient view joining slot metadata for reporting
CREATE OR REPLACE VIEW v_scan_counters_expanded AS
SELECT
  c.day,
  c.count,
  qs.id AS qr_slot_id,
  r.code AS route_code,
  r.name AS route_name,
  b.bus_number,
  b.license_plate,
  qs.trip_type,
  qs.scheduled_time,
  c.updated_at
FROM scan_counters c
JOIN qr_slots qs ON qs.id = c.qr_slot_id
JOIN routes r    ON r.id = qs.route_id
JOIN buses b     ON b.id = qs.bus_id;
