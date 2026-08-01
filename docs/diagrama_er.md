# Diagrama Entidad-Relación

> GitHub renderiza automáticamente los bloques ```mermaid``` en el README o en cualquier .md. También puedes pegar este código en https://mermaid.live para exportarlo como PNG/PDF y adjuntarlo como evidencia.

```mermaid
erDiagram
    AUTORES ||--o{ LIBROS : escribe
    CATEGORIAS ||--o{ LIBROS : clasifica
    USUARIOS ||--o{ PRESTAMOS : realiza
    PRESTAMOS ||--o{ DETALLE_PRESTAMO : contiene
    LIBROS ||--o{ DETALLE_PRESTAMO : incluye
    PRESTAMOS ||--o{ DEVOLUCIONES : genera
    PRESTAMOS ||--o{ MULTAS : puede_generar

    AUTORES {
        int id_autor PK
        string nombre
        string apellido
        string nacionalidad
    }
    CATEGORIAS {
        int id_categoria PK
        string nombre
        string descripcion
    }
    LIBROS {
        int id_libro PK
        string titulo
        string isbn
        int anio_publicacion
        int id_autor FK
        int id_categoria FK
        int ejemplares_totales
        int ejemplares_disponibles
    }
    USUARIOS {
        int id_usuario PK
        string nombre
        string apellido
        string email
        string telefono
        string tipo_usuario
        date fecha_registro
    }
    PRESTAMOS {
        int id_prestamo PK
        int id_usuario FK
        date fecha_prestamo
        date fecha_devolucion_esperada
        string estado
    }
    DETALLE_PRESTAMO {
        int id_detalle PK
        int id_prestamo FK
        int id_libro FK
        int cantidad
    }
    DEVOLUCIONES {
        int id_devolucion PK
        int id_prestamo FK
        date fecha_devolucion
        string estado_libro
    }
    MULTAS {
        int id_multa PK
        int id_prestamo FK
        numeric monto
        date fecha_generada
        boolean pagada
    }
```

## Diccionario de datos (resumen)

| Tabla             | Atributo clave         | Relación                                   |
|--------------------|------------------------|---------------------------------------------|
| autores            | id_autor (PK)           | 1 autor → N libros                          |
| categorias         | id_categoria (PK)       | 1 categoría → N libros                      |
| libros             | id_libro (PK)           | referencia a autor y categoría (FK)         |
| usuarios           | id_usuario (PK)         | 1 usuario → N préstamos                     |
| prestamos          | id_prestamo (PK)        | referencia a usuario (FK)                   |
| detalle_prestamo   | id_detalle (PK)         | resuelve relación N:M entre préstamos-libros|
| devoluciones       | id_devolucion (PK)      | referencia a préstamo (FK)                  |
| multas             | id_multa (PK)           | referencia a préstamo (FK)                  |
