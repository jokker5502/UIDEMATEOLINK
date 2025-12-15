-- ===============================
-- seed.sql (Sample data for No-login QR bus usage tracking)
-- ===============================

-- NOTE:
-- These are example tokens and secret_hash values for local development.
-- In production, generate strong random tokens in your backend and store secret_hash as:
--   encode(digest(token || ':' || <SERVER_SALT>, 'sha256'), 'hex')
-- Keep SERVER_SALT in environment variables, not in the database.

-- Clean (optional) - uncomment if you want a fresh seed each time
-- TRUNCATE scan_events, scan_counters, qr_slots, buses, routes RESTART IDENTITY CASCADE;

-- ---------- Routes ----------
INSERT INTO routes (code, name, description) VALUES
  ('ARMENIA', 'La Armenia', 'Ruta hacia el sector La Armenia'),
  ('VALLE',   'Valle de los Chillos', 'Ruta hacia el Valle de los Chillos'),
  ('CENTRO',  'Centro', 'Ruta hacia el Centro')
ON CONFLICT (code) DO NOTHING;

-- ---------- Buses ----------
INSERT INTO buses (bus_number, license_plate, capacity) VALUES
  ('BUS-01', 'ABC-1234', 40),
  ('BUS-02', 'DEF-5678', 40),
  ('BUS-03', 'GHI-9012', 35)
ON CONFLICT (bus_number) DO NOTHING;

-- ---------- QR Slots ----------
-- Demo salt used ONLY for seed/dev
-- In your backend, replace with env var and store only the resulting hash
WITH cfg AS (SELECT 'demo_salt_change_me'::text AS salt),
r AS (SELECT id, code FROM routes),
b AS (SELECT id, bus_number FROM buses)
INSERT INTO qr_slots (bus_id, route_id, trip_type, scheduled_time, token, secret_hash, valid_from, valid_to)
SELECT
  b.id,
  r.id,
  x.trip_type::trip_type,
  x.scheduled_time::time,
  x.token,
  encode(digest(x.token || ':' || cfg.salt, 'sha256'), 'hex') AS secret_hash,
  now() - interval '30 days',
  now() + interval '365 days'
FROM cfg
JOIN (VALUES
  ('BUS-01','ARMENIA','ENTRY','10:00','slot_BUS01_ARMENIA_ENTRY_1000'),
  ('BUS-01','ARMENIA','EXIT', '17:00','slot_BUS01_ARMENIA_EXIT_1700'),
  ('BUS-02','VALLE',  'ENTRY','08:00','slot_BUS02_VALLE_ENTRY_0800'),
  ('BUS-02','VALLE',  'EXIT', '16:00','slot_BUS02_VALLE_EXIT_1600'),
  ('BUS-03','CENTRO', 'ENTRY','09:00','slot_BUS03_CENTRO_ENTRY_0900'),
  ('BUS-03','CENTRO', 'EXIT', '18:00','slot_BUS03_CENTRO_EXIT_1800')
) AS x(bus_number, route_code, trip_type, scheduled_time, token)
  ON TRUE
JOIN b ON b.bus_number = x.bus_number
JOIN r ON r.code = x.route_code
ON CONFLICT (token) DO NOTHING;

-- ---------- Seed a couple of counters (optional) ----------
-- Useful to see dashboards immediately
INSERT INTO scan_counters (qr_slot_id, day, count)
SELECT id, CURRENT_DATE, 0
FROM qr_slots
ON CONFLICT (qr_slot_id, day) DO NOTHING;
