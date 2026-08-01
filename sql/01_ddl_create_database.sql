-- =====================================================================
-- 01_ddl_create_database.sql
-- Sistema de Gestión de Biblioteca Académica
-- Sentencias DDL: CREATE DATABASE, CREATE TABLE, PK, FK, NOT NULL,
--                  UNIQUE, CHECK
-- Motor: PostgreSQL (correr en contenedor Podman)
-- =====================================================================

-- Ejecutar esta línea conectado a la base "postgres" (fuera de una
-- transacción). Si tu cliente ya te conecta a una BD por defecto,
-- comenta esta línea y crea la BD manualmente una sola vez:
--   CREATE DATABASE biblioteca_academica;
-- \c biblioteca_academica   -- (en psql, para conectarte a ella)

-- ---------------------------------------------------------------------
-- Limpieza (para poder re-ejecutar el script en desarrollo)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS multas CASCADE;
DROP TABLE IF EXISTS devoluciones CASCADE;
DROP TABLE IF EXISTS detalle_prestamo CASCADE;
DROP TABLE IF EXISTS prestamos CASCADE;
DROP TABLE IF EXISTS libros CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS autores CASCADE;

-- ---------------------------------------------------------------------
-- Tabla: autores
-- ---------------------------------------------------------------------
CREATE TABLE autores (
    id_autor        SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    nacionalidad    VARCHAR(50)
);

-- ---------------------------------------------------------------------
-- Tabla: categorias
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id_categoria    SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(255)
);

-- ---------------------------------------------------------------------
-- Tabla: libros
-- ---------------------------------------------------------------------
CREATE TABLE libros (
    id_libro                SERIAL PRIMARY KEY,
    titulo                  VARCHAR(200) NOT NULL,
    isbn                    VARCHAR(20) UNIQUE,
    anio_publicacion        INT CHECK (anio_publicacion > 1400),
    id_autor                INT NOT NULL REFERENCES autores(id_autor),
    id_categoria            INT NOT NULL REFERENCES categorias(id_categoria),
    ejemplares_totales      INT NOT NULL CHECK (ejemplares_totales >= 0),
    ejemplares_disponibles  INT NOT NULL CHECK (ejemplares_disponibles >= 0)
);

-- ---------------------------------------------------------------------
-- Tabla: usuarios
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario      SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    tipo_usuario    VARCHAR(20) NOT NULL
                    CHECK (tipo_usuario IN ('estudiante','docente','administrativo')),
    fecha_registro  DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------------------
-- Tabla: prestamos
-- ---------------------------------------------------------------------
CREATE TABLE prestamos (
    id_prestamo                 SERIAL PRIMARY KEY,
    id_usuario                  INT NOT NULL REFERENCES usuarios(id_usuario),
    fecha_prestamo               DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_devolucion_esperada   DATE NOT NULL,
    estado                      VARCHAR(20) NOT NULL DEFAULT 'activo'
                                 CHECK (estado IN ('activo','devuelto','vencido'))
);

-- ---------------------------------------------------------------------
-- Tabla: detalle_prestamo (permite prestar varios libros en un mismo
-- préstamo; relación N:M resuelta entre prestamos y libros)
-- ---------------------------------------------------------------------
CREATE TABLE detalle_prestamo (
    id_detalle      SERIAL PRIMARY KEY,
    id_prestamo     INT NOT NULL REFERENCES prestamos(id_prestamo),
    id_libro        INT NOT NULL REFERENCES libros(id_libro),
    cantidad        INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    UNIQUE (id_prestamo, id_libro)
);

-- ---------------------------------------------------------------------
-- Tabla: devoluciones
-- ---------------------------------------------------------------------
CREATE TABLE devoluciones (
    id_devolucion       SERIAL PRIMARY KEY,
    id_prestamo         INT NOT NULL REFERENCES prestamos(id_prestamo),
    fecha_devolucion    DATE NOT NULL DEFAULT CURRENT_DATE,
    estado_libro        VARCHAR(20) NOT NULL
                        CHECK (estado_libro IN ('bueno','danado','perdido'))
);

-- ---------------------------------------------------------------------
-- Tabla: multas
-- ---------------------------------------------------------------------
CREATE TABLE multas (
    id_multa            SERIAL PRIMARY KEY,
    id_prestamo         INT NOT NULL REFERENCES prestamos(id_prestamo),
    monto               NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
    fecha_generada      DATE NOT NULL DEFAULT CURRENT_DATE,
    pagada              BOOLEAN NOT NULL DEFAULT FALSE
);

-- ---------------------------------------------------------------------
-- Índices útiles (no obligatorios, pero buena práctica)
-- ---------------------------------------------------------------------
CREATE INDEX idx_libros_autor      ON libros(id_autor);
CREATE INDEX idx_libros_categoria  ON libros(id_categoria);
CREATE INDEX idx_prestamos_usuario ON prestamos(id_usuario);
CREATE INDEX idx_detalle_prestamo  ON detalle_prestamo(id_prestamo);
