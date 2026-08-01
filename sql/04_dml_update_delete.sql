-- =====================================================================
-- 04_dml_update_delete.sql
-- Sentencias DML: UPDATE, DELETE
-- =====================================================================

-- 1) Actualizar el estado de un préstamo a "devuelto" y registrar la
--    devolución (ejemplo: préstamo id 3)
UPDATE prestamos
SET estado = 'devuelto'
WHERE id_prestamo = 3;

INSERT INTO devoluciones (id_prestamo, fecha_devolucion, estado_libro)
VALUES (3, CURRENT_DATE, 'bueno');

-- Y devolver el ejemplar al inventario disponible
UPDATE libros
SET ejemplares_disponibles = ejemplares_disponibles + 1
WHERE id_libro = (
    SELECT id_libro FROM detalle_prestamo WHERE id_prestamo = 3 LIMIT 1
);

-- 2) Marcar una multa como pagada
UPDATE multas
SET pagada = TRUE
WHERE id_multa = 1;

-- 3) Corregir el teléfono de un usuario
UPDATE usuarios
SET telefono = '5559998888'
WHERE email = 'carlos.perez@uni.edu';

-- 4) Eliminar una multa que fue pagada y ya no debe seguir en el
--    reporte de pendientes (ejemplo de DELETE controlado)
DELETE FROM multas
WHERE pagada = TRUE AND fecha_generada < '2026-01-01';

-- 5) Eliminar un préstamo de prueba y su detalle asociado
--    (respetando integridad referencial: primero el detalle, luego el
--    préstamo)
DELETE FROM detalle_prestamo WHERE id_prestamo = 6;
DELETE FROM prestamos WHERE id_prestamo = 6;
