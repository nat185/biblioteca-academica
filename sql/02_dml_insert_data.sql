-- =====================================================================
-- 02_dml_insert_data.sql
-- Sentencias DML: INSERT (datos de prueba)
-- =====================================================================

-- ---------------------------------------------------------------------
-- autores
-- ---------------------------------------------------------------------
INSERT INTO autores (nombre, apellido, nacionalidad) VALUES
('Gabriel', 'García Márquez', 'Colombiana'),
('Jorge', 'Luis Borges', 'Argentina'),
('Isabel', 'Allende', 'Chilena'),
('Robert C.', 'Martin', 'Estadounidense'),
('Martin', 'Kleppmann', 'Alemana'),
('Yuval Noah', 'Harari', 'Israelí');

-- ---------------------------------------------------------------------
-- categorias
-- ---------------------------------------------------------------------
INSERT INTO categorias (nombre, descripcion) VALUES
('Literatura', 'Novelas y cuentos'),
('Tecnología', 'Programación y sistemas'),
('Ciencia', 'Divulgación científica'),
('Historia', 'Ensayos e historia general');

-- ---------------------------------------------------------------------
-- libros
-- ---------------------------------------------------------------------
INSERT INTO libros (titulo, isbn, anio_publicacion, id_autor, id_categoria, ejemplares_totales, ejemplares_disponibles) VALUES
('Cien años de soledad',      '9780307474728', 1967, 1, 1, 5, 3),
('El aleph',                  '9788420633343', 1949, 2, 1, 3, 3),
('La casa de los espíritus',  '9780525433454', 1982, 3, 1, 4, 2),
('Clean Code',                '9780132350884', 2008, 4, 2, 6, 4),
('Designing Data-Intensive Applications', '9781449373320', 2017, 5, 2, 4, 1),
('Sapiens',                   '9780062316097', 2011, 6, 3, 5, 5),
('Homo Deus',                 '9781910701881', 2016, 6, 4, 3, 0);

-- ---------------------------------------------------------------------
-- usuarios
-- ---------------------------------------------------------------------
INSERT INTO usuarios (nombre, apellido, email, telefono, tipo_usuario, fecha_registro) VALUES
('Ana',     'Torres',   'ana.torres@uni.edu',   '5551000001', 'estudiante',    '2025-02-10'),
('Luis',    'Ramírez',  'luis.ramirez@uni.edu', '5551000002', 'estudiante',    '2025-02-11'),
('Marta',   'Gómez',    'marta.gomez@uni.edu',  '5551000003', 'docente',       '2024-08-01'),
('Carlos',  'Pérez',    'carlos.perez@uni.edu', '5551000004', 'estudiante',    '2025-03-05'),
('Sofía',   'Herrera',  'sofia.herrera@uni.edu','5551000005', 'administrativo','2023-01-15');

-- ---------------------------------------------------------------------
-- prestamos
-- ---------------------------------------------------------------------
INSERT INTO prestamos (id_usuario, fecha_prestamo, fecha_devolucion_esperada, estado) VALUES
(1, '2026-06-01', '2026-06-15', 'devuelto'),
(2, '2026-06-20', '2026-07-04', 'vencido'),   -- ya pasó la fecha esperada y sigue sin devolver
(3, '2026-07-01', '2026-07-20', 'activo'),
(1, '2026-07-10', '2026-07-25', 'activo'),
(4, '2026-05-01', '2026-05-15', 'vencido'),
(4, '2026-07-15', '2026-07-30', 'activo');

-- ---------------------------------------------------------------------
-- detalle_prestamo
-- ---------------------------------------------------------------------
INSERT INTO detalle_prestamo (id_prestamo, id_libro, cantidad) VALUES
(1, 1, 1),
(2, 4, 1),
(2, 5, 1),
(3, 6, 1),
(4, 2, 1),
(5, 5, 1),
(6, 3, 1);

-- ---------------------------------------------------------------------
-- devoluciones (solo para el préstamo ya devuelto)
-- ---------------------------------------------------------------------
INSERT INTO devoluciones (id_prestamo, fecha_devolucion, estado_libro) VALUES
(1, '2026-06-14', 'bueno');

-- ---------------------------------------------------------------------
-- multas (por préstamos vencidos)
-- ---------------------------------------------------------------------
INSERT INTO multas (id_prestamo, monto, fecha_generada, pagada) VALUES
(2, 50.00, '2026-07-05', FALSE),
(5, 120.00, '2026-05-16', TRUE);
