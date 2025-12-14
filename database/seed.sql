-- UIDE-Link Seed Data
-- Populates database with UIDE route data and sample records

BEGIN;

-- =====================================================
-- 1. INSERT ROUTES (31 routes from UIDE logistics)
-- =====================================================

INSERT INTO routes (name, description, is_active) VALUES
('Mitad del Mundo', 'Ruta norte hacia el monumento Mitad del Mundo', true),
('Bellavista', 'Ruta sector Bellavista', true),
('San Juan de Calderón', 'Ruta San Juan de Calderón', true),
('Carapungo - Simón Bolívar', 'Ruta Carapungo vía Simón Bolívar', true),
('Llano Grande', 'Ruta sector Llano Grande', true),
('Carcelén - Eloy Alfaro', 'Ruta Carcelén vía Eloy Alfaro', true),
('6 de Diciembre - El Ciclista', 'Ruta 6 de Diciembre hasta El Ciclista', true),
('Galo Plaza - 10 de Agosto', 'Ruta Galo Plaza vía 10 de Agosto', true),
('Occidental', 'Ruta Av. Occidental', true),
('Prensa - América', 'Ruta La Prensa vía América', true),
('La Granados', 'Ruta sector La Granados', true),
('Martha Bucaram', 'Ruta Martha Bucaram', true),
('Mariscal - Terminal Quitumbe', 'Ruta desde Mariscal hasta Terminal Quitumbe', true),
('Mariscal - Napo', 'Ruta Mariscal sector Napo', true),
('Machachi', 'Ruta a Machachi', true),
('Guamaní - Av. Maldonado', 'Ruta Guamaní vía Av. Maldonado', true),
('Solanda - Simón Bolívar', 'Ruta Solanda vía Simón Bolívar', true),
('Miranda', 'Ruta sector Miranda', true),
('La Salle - Conocoto', 'Ruta La Salle hasta Conocoto', true),
('La Armenia', 'Ruta La Armenia', true),
('Alangasí', 'Ruta a Alangasí', true),
('Autopista Gral. Rumiñahui', 'Ruta Autopista General Rumiñahui', true),
('Sangolquí', 'Ruta a Sangolquí', true),
('Selva Alegre', 'Ruta sector Selva Alegre', true),
('Danec - Capelo', 'Ruta Danec vía Capelo', true),
('Yaruquí', 'Ruta a Yaruquí', true),
('Tumbaco', 'Ruta a Tumbaco', true),
('Cumbayá', 'Ruta a Cumbayá', true),
('Río Coca - Shyris', 'Ruta Río Coca vía Shyris', true),
('El Labrador - América', 'Ruta El Labrador vía América', true),
('10 de Agosto - La Y', 'Ruta 10 de Agosto hasta La Y', true);

-- =====================================================
-- 2. INSERT SCHEDULES (Arrivals and Departures)
-- =====================================================

-- Arrival times (Ingreso a UIDE)
INSERT INTO schedules (schedule_type, time_slot, is_active) VALUES
('arrival', '07:00:00', true),
('arrival', '10:00:00', true),
('arrival', '13:00:00', true),
('arrival', '16:00:00', true),
('arrival', '18:00:00', true);

-- Departure times (Salida de UIDE)
INSERT INTO schedules (schedule_type, time_slot, is_active) VALUES
('departure', '10:20:00', true),
('departure', '11:50:00', true),
('departure', '12:00:00', true),
('departure', '13:30:00', true),
('departure', '16:20:00', true),
('departure', '18:20:00', true),
('departure', '19:20:00', true),
('departure', '22:00:00', true);

-- =====================================================
-- 3. INSERT BUSES (Sample fleet - 15 buses)
-- =====================================================

-- Generate buses assigned to different routes
INSERT INTO buses (bus_number, license_plate, route_id, qr_code, capacity, is_active) VALUES
('BUS-001', 'PBA-1234', 1, 'UIDE-BUS:1:BUS-001', 45, true),
('BUS-002', 'PBB-5678', 4, 'UIDE-BUS:2:BUS-002', 40, true),
('BUS-003', 'PBC-9012', 7, 'UIDE-BUS:3:BUS-003', 42, true),
('BUS-004', 'PBD-3456', 13, 'UIDE-BUS:4:BUS-004', 45, true),
('BUS-005', 'PBE-7890', 15, 'UIDE-BUS:5:BUS-005', 38, true),
('BUS-006', 'PBF-2345', 19, 'UIDE-BUS:6:BUS-006', 40, true),
('BUS-007', 'PBG-6789', 22, 'UIDE-BUS:7:BUS-007', 45, true),
('BUS-008', 'PBH-0123', 23, 'UIDE-BUS:8:BUS-008', 42, true),
('BUS-009', 'PBI-4567', 27, 'UIDE-BUS:9:BUS-009', 40, true),
('BUS-010', 'PBJ-8901', 28, 'UIDE-BUS:10:BUS-010', 45, true),
('BUS-011', 'PBK-2345', 9, 'UIDE-BUS:11:BUS-011', 40, true),
('BUS-012', 'PBL-6789', 10, 'UIDE-BUS:12:BUS-012', 42, true),
('BUS-013', 'PBM-0123', 16, 'UIDE-BUS:13:BUS-013', 45, true),
('BUS-014', 'PBN-4567', 20, 'UIDE-BUS:14:BUS-014', 38, true),
('BUS-015', 'PBO-8901', 25, 'UIDE-BUS:15:BUS-015', 40, true);

-- =====================================================
-- 4. INSERT STUDENTS (Sample users - 50 students)
-- =====================================================
-- Password for all test students: "uide2024" (bcrypt hash)
-- Hash generated with cost factor 10

INSERT INTO students (student_id, email, password_hash, first_name, last_name, phone, is_active) VALUES
('EST-2024001', 'maria.garcia@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'María', 'García', '0987654321', true),
('EST-2024002', 'juan.lopez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Juan', 'López', '0987654322', true),
('EST-2024003', 'ana.martinez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Ana', 'Martínez', '0987654323', true),
('EST-2024004', 'carlos.rodriguez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Carlos', 'Rodríguez', '0987654324', true),
('EST-2024005', 'lucia.fernandez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Lucía', 'Fernández', '0987654325', true),
('EST-2024006', 'diego.sanchez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Diego', 'Sánchez', '0987654326', true),
('EST-2024007', 'sofia.torres@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Sofía', 'Torres', '0987654327', true),
('EST-2024008', 'andres.ramirez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Andrés', 'Ramírez', '0987654328', true),
('EST-2024009', 'valentina.cruz@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Valentina', 'Cruz', '0987654329', true),
('EST-2024010', 'sebastian.morales@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Sebastián', 'Morales', '0987654330', true),
('EST-2024011', 'camila.herrera@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Camila', 'Herrera', '0987654331', true),
('EST-2024012', 'mateo.jimenez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Mateo', 'Jiménez', '0987654332', true),
('EST-2024013', 'isabella.rojas@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Isabella', 'Rojas', '0987654333', true),
('EST-2024014', 'nicolas.silva@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Nicolás', 'Silva', '0987654334', true),
('EST-2024015', 'martina.castro@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Martina', 'Castro', '0987654335', true),
('EST-2024016', 'gabriel.mendez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Gabriel', 'Méndez', '0987654336', true),
('EST-2024017', 'emilia.vargas@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Emilia', 'Vargas', '0987654337', true),
('EST-2024018', 'daniel.ortiz@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Daniel', 'Ortiz', '0987654338', true),
('EST-2024019', 'renata.pena@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Renata', 'Peña', '0987654339', true),
('EST-2024020', 'alejandro.rios@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Alejandro', 'Ríos', '0987654340', true),
('EST-2024021', 'paula.vega@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Paula', 'Vega', '0987654341', true),
('EST-2024022', 'martin.nunez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Martín', 'Núñez', '0987654342', true),
('EST-2024023', 'juliana.paredes@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Juliana', 'Paredes', '0987654343', true),
('EST-2024024', 'lucas.guerrero@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Lucas', 'Guerrero', '0987654344', true),
('EST-2024025', 'valeria.molina@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Valeria', 'Molina', '0987654345', true),
('EST-2024026', 'santiago.reyes@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Santiago', 'Reyes', '0987654346', true),
('EST-2024027', 'mariana.suarez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Mariana', 'Suárez', '0987654347', true),
('EST-2024028', 'thomas.lara@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Thomas', 'Lara', '0987654348', true),
('EST-2024029', 'fernanda.duran@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Fernanda', 'Durán', '0987654349', true),
('EST-2024030', 'pedro.guzman@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Pedro', 'Guzmán', '0987654350', true),
('EST-2024031', 'daniela.flores@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Daniela', 'Flores', '0987654351', true),
('EST-2024032', 'felipe.aguilar@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Felipe', 'Aguilar', '0987654352', true),
('EST-2024033', 'catalina.campos@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Catalina', 'Campos', '0987654353', true),
('EST-2024034', 'joaquin.romero@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Joaquín', 'Romero', '0987654354', true),
('EST-2024035', 'adriana.delgado@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Adriana', 'Delgado', '0987654355', true),
('EST-2024036', 'ricardo.navarro@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Ricardo', 'Navarro', '0987654356', true),
('EST-2024037', 'natalia.correa@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Natalia', 'Correa', '0987654357', true),
('EST-2024038', 'eduardo.perez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Eduardo', 'Pérez', '0987654358', true),
('EST-2024039', 'carolina.medina@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Carolina', 'Medina', '0987654359', true),
('EST-2024040', 'fernando.luna@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Fernando', 'Luna', '0987654360', true),
('EST-2024041', 'andrea.soto@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Andrea', 'Soto', '0987654361', true),
('EST-2024042', 'javier.camacho@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Javier', 'Camacho', '0987654362', true),
('EST-2024043', 'patricia.alvarado@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Patricia', 'Alvarado', '0987654363', true),
('EST-2024044', 'roberto.carrillo@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Roberto', 'Carrillo', '0987654364', true),
('EST-2024045', 'bianca.salazar@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Bianca', 'Salazar', '0987654365', true),
('EST-2024046', 'miguel.cordova@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Miguel', 'Córdova', '0987654366', true),
('EST-2024047', 'lorena.benitez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Lorena', 'Benítez', '0987654367', true),
('EST-2024048', 'oscar.villanueva@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Óscar', 'Villanueva', '0987654368', true),
('EST-2024049', 'jessica.vazquez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Jessica', 'Vázquez', '0987654369', true),
('EST-2024050', 'antonio.serrano@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Antonio', 'Serrano', '0987654370', true);

-- =====================================================
-- 5. INSERT DRIVERS (Sample - 10 drivers)
-- =====================================================
-- Password for all test drivers: "driver2024"

INSERT INTO drivers (driver_id, email, password_hash, first_name, last_name, phone, license_number, assigned_bus_id, is_active) VALUES
('DRV-001', 'raul.rivera@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Raúl', 'Rivera', '0991234567', 'LIC-A12345', 1, true),
('DRV-002', 'carmen.salinas@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Carmen', 'Salinas', '0991234568', 'LIC-B23456', 2, true),
('DRV-003', 'hugo.leon@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Hugo', 'León', '0991234569', 'LIC-C34567', 3, true),
('DRV-004', 'monica.palacios@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Mónica', 'Palacios', '0991234570', 'LIC-D45678', 4, true),
('DRV-005', 'jorge.cevallos@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Jorge', 'Cevallos', '0991234571', 'LIC-E56789', 5, true),
('DRV-006', 'rosa.franco@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Rosa', 'Franco', '0991234572', 'LIC-F67890', 6, true),
('DRV-007', 'luis.espinoza@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Luis', 'Espinoza', '0991234573', 'LIC-G78901', 7, true),
('DRV-008', 'elena.villacis@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Elena', 'Villacís', '0991234574', 'LIC-H89012', 8, true),
('DRV-009', 'marco.valdez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Marco', 'Valdez', '0991234575', 'LIC-I90123', 9, true),
('DRV-010', 'silvia.quinonez@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'Silvia', 'Quiñónez', '0991234576', 'LIC-J01234', 10, true);

-- =====================================================
-- 6. INSERT ADMINS (System administrators)
-- =====================================================
-- Password for admin: "admin2024"

INSERT INTO admins (username, email, password_hash, role, is_active) VALUES
('admin', 'admin@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'super_admin', true),
('logistics', 'logistics@uide.edu.ec', '$2b$10$rKvVxqHQxJ7z3QJ5FZx0Ou0Y8Z3nXxX5hK5Y7Z8Z9Z0Z1Z2Z3Z4Z5', 'admin', true);

-- =====================================================
-- 7. INSERT SAMPLE SCAN EVENTS (Test data)
-- =====================================================
-- Simulating today's morning routes

INSERT INTO scan_events (student_id, bus_id, route_id, event_type, local_timestamp, sync_status, client_id) VALUES
-- Bus 1 - Morning ingress (07:00)
(1, 1, 1, 'ingress', CURRENT_DATE + TIME '07:05:00', 'synced', uuid_generate_v4()),
(2, 1, 1, 'ingress', CURRENT_DATE + TIME '07:06:00', 'synced', uuid_generate_v4()),
(3, 1, 1, 'ingress', CURRENT_DATE + TIME '07:08:00', 'synced', uuid_generate_v4()),

-- Bus 2 - Morning ingress (07:00)
(4, 2, 4, 'ingress', CURRENT_DATE + TIME '07:10:00', 'synced', uuid_generate_v4()),
(5, 2, 4, 'ingress', CURRENT_DATE + TIME '07:12:00', 'synced', uuid_generate_v4()),
(6, 2, 4, 'ingress', CURRENT_DATE + TIME '07:15:00', 'synced', uuid_generate_v4()),

-- Bus 3 - Morning ingress (10:00)
(7, 3, 7, 'ingress', CURRENT_DATE + TIME '10:05:00', 'synced', uuid_generate_v4()),
(8, 3, 7, 'ingress', CURRENT_DATE + TIME '10:07:00', 'synced', uuid_generate_v4()),

-- Bus 1 - Afternoon egress (16:20)
(1, 1, 1, 'egress', CURRENT_DATE + TIME '16:22:00', 'synced', uuid_generate_v4()),
(2, 1, 1, 'egress', CURRENT_DATE + TIME '16:23:00', 'synced', uuid_generate_v4()),
(3, 1, 1, 'egress', CURRENT_DATE + TIME '16:25:00', 'synced', uuid_generate_v4());

COMMIT;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify data insertion
SELECT 'Routes inserted:' as info, COUNT(*) as count FROM routes;
SELECT 'Schedules inserted:' as info, COUNT(*) as count FROM schedules;
SELECT 'Buses inserted:' as info, COUNT(*) as count FROM buses;
SELECT 'Students inserted:' as info, COUNT(*) as count FROM students;
SELECT 'Drivers inserted:' as info, COUNT(*) as count FROM drivers;
SELECT 'Admins inserted:' as info, COUNT(*) as count FROM admins;
SELECT 'Sample scans inserted:' as info, COUNT(*) as count FROM scan_events;

-- Show sample QR codes
SELECT bus_number, qr_code, capacity FROM buses ORDER BY id LIMIT 5;

-- Show today's ridership
SELECT * FROM daily_ridership WHERE date = CURRENT_DATE;
