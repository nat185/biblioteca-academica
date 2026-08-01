-- =====================================================================
-- 03_queries_select.sql
-- Consultas SQL: SELECT, WHERE, ORDER BY, GROUP BY, HAVING, JOIN,
--                subconsultas
-- Cada consulta indica, en comentario, la operación de álgebra
-- relacional principal que representa.
-- =====================================================================

-- 1) Listar todos los libros
-- Álgebra relacional: proyección (π) sobre "libros"
SELECT id_libro, titulo, isbn, anio_publicacion
FROM libros
ORDER BY titulo;

-- 2) Mostrar libros por categoría (ej. "Tecnología")
-- Álgebra relacional: selección (σ) + join (⋈) + proyección (π)
SELECT l.titulo, c.nombre AS categoria
FROM libros l
JOIN categorias c ON l.id_categoria = c.id_categoria
WHERE c.nombre = 'Tecnología'
ORDER BY l.titulo;

-- 3) Mostrar libros prestados por usuario (préstamos activos o vencidos)
-- Álgebra relacional: join múltiple (⋈) + selección (σ)
SELECT u.nombre, u.apellido, l.titulo, p.fecha_prestamo, p.estado
FROM prestamos p
JOIN usuarios u          ON p.id_usuario = u.id_usuario
JOIN detalle_prestamo dp ON dp.id_prestamo = p.id_prestamo
JOIN libros l             ON l.id_libro = dp.id_libro
ORDER BY u.apellido, p.fecha_prestamo;

-- 4) Mostrar préstamos vencidos
-- Álgebra relacional: selección (σ)
SELECT p.id_prestamo, u.nombre, u.apellido, p.fecha_devolucion_esperada
FROM prestamos p
JOIN usuarios u ON u.id_usuario = p.id_usuario
WHERE p.estado = 'vencido'
   OR (p.estado = 'activo' AND p.fecha_devolucion_esperada < CURRENT_DATE)
ORDER BY p.fecha_devolucion_esperada;

-- 5) Mostrar autores con más libros registrados
-- Álgebra relacional: join (⋈) + agregación (agrupamiento)
SELECT a.nombre, a.apellido, COUNT(l.id_libro) AS total_libros
FROM autores a
JOIN libros l ON l.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre, a.apellido
ORDER BY total_libros DESC;

-- 6) Mostrar el número de préstamos por categoría
-- Álgebra relacional: join múltiple (⋈) + agregación
SELECT c.nombre AS categoria, COUNT(dp.id_detalle) AS total_prestamos
FROM categorias c
JOIN libros l              ON l.id_categoria = c.id_categoria
JOIN detalle_prestamo dp   ON dp.id_libro = l.id_libro
GROUP BY c.id_categoria, c.nombre
ORDER BY total_prestamos DESC;

-- 7) Mostrar usuarios con más préstamos (más de 1 préstamo)
-- Álgebra relacional: join (⋈) + agregación + HAVING (selección post-grupo)
SELECT u.nombre, u.apellido, COUNT(p.id_prestamo) AS total_prestamos
FROM usuarios u
JOIN prestamos p ON p.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nombre, u.apellido
HAVING COUNT(p.id_prestamo) > 1
ORDER BY total_prestamos DESC;

-- 8) Mostrar libros disponibles (ejemplares_disponibles > 0)
-- Álgebra relacional: selección (σ) + proyección (π)
SELECT titulo, ejemplares_disponibles
FROM libros
WHERE ejemplares_disponibles > 0
ORDER BY ejemplares_disponibles DESC;

-- 9) Mostrar el historial completo de préstamos de un usuario específico
--    (subconsulta para obtener el id del usuario por su email)
-- Álgebra relacional: subconsulta (selección anidada) + join
SELECT p.id_prestamo, l.titulo, p.fecha_prestamo, p.estado
FROM prestamos p
JOIN detalle_prestamo dp ON dp.id_prestamo = p.id_prestamo
JOIN libros l ON l.id_libro = dp.id_libro
WHERE p.id_usuario = (
    SELECT id_usuario FROM usuarios WHERE email = 'ana.torres@uni.edu'
)
ORDER BY p.fecha_prestamo;

-- 10) Consulta con al menos dos tablas relacionadas: libros que nunca
--     han sido prestados (subconsulta con NOT IN)
-- Álgebra relacional: diferencia (libros - libros_prestados)
SELECT titulo
FROM libros
WHERE id_libro NOT IN (
    SELECT DISTINCT id_libro FROM detalle_prestamo
);

-- 11) Extra: usuarios con multas pendientes de pago
-- Álgebra relacional: join (⋈) + selección (σ)
SELECT u.nombre, u.apellido, m.monto, m.fecha_generada
FROM multas m
JOIN prestamos p ON p.id_prestamo = m.id_prestamo
JOIN usuarios u   ON u.id_usuario = p.id_usuario
WHERE m.pagada = FALSE;

-- 12) Extra: total de libros por autor y por categoría (ejemplo de
--     UNION - álgebra relacional: unión de dos proyecciones compatibles)
SELECT 'Autor' AS tipo, a.nombre || ' ' || a.apellido AS nombre, COUNT(l.id_libro) AS total
FROM autores a JOIN libros l ON l.id_autor = a.id_autor
GROUP BY a.id_autor, nombre
UNION
SELECT 'Categoria' AS tipo, c.nombre, COUNT(l.id_libro)
FROM categorias c JOIN libros l ON l.id_categoria = c.id_categoria
GROUP BY c.id_categoria, c.nombre
ORDER BY tipo, total DESC;
