"""
config.py
Metadatos de cada tabla: qué columnas mostrar, cuáles son editables,
tipos de campo para el formulario y relaciones (llaves foráneas) que
se resuelven como listas desplegables.

Añadir una tabla nueva a la interfaz = agregar una entrada aquí.
No se necesita tocar app.py ni las plantillas HTML.
"""

TABLES = {
    "autores": {
        "label": "Autores",
        "icon": "quill",
        "pk": "id_autor",
        "search_field": "nombre",
        "display": lambda r: f"{r['nombre']} {r['apellido']}",
        "columns": [
            {"name": "id_autor", "label": "ID", "type": "readonly"},
            {"name": "nombre", "label": "Nombre", "type": "text", "required": True},
            {"name": "apellido", "label": "Apellido", "type": "text", "required": True},
            {"name": "nacionalidad", "label": "Nacionalidad", "type": "text"},
        ],
    },
    "categorias": {
        "label": "Categorías",
        "icon": "tag",
        "pk": "id_categoria",
        "search_field": "nombre",
        "display": lambda r: r["nombre"],
        "columns": [
            {"name": "id_categoria", "label": "ID", "type": "readonly"},
            {"name": "nombre", "label": "Nombre", "type": "text", "required": True},
            {"name": "descripcion", "label": "Descripción", "type": "textarea"},
        ],
    },
    "libros": {
        "label": "Libros",
        "icon": "book",
        "pk": "id_libro",
        "search_field": "titulo",
        "display": lambda r: r["titulo"],
        "columns": [
            {"name": "id_libro", "label": "ID", "type": "readonly"},
            {"name": "titulo", "label": "Título", "type": "text", "required": True},
            {"name": "isbn", "label": "ISBN", "type": "text"},
            {"name": "anio_publicacion", "label": "Año", "type": "number"},
            {"name": "id_autor", "label": "Autor", "type": "fk", "fk_table": "autores", "required": True},
            {"name": "id_categoria", "label": "Categoría", "type": "fk", "fk_table": "categorias", "required": True},
            {"name": "ejemplares_totales", "label": "Ejemplares totales", "type": "number", "required": True},
            {"name": "ejemplares_disponibles", "label": "Ejemplares disponibles", "type": "number", "required": True},
        ],
    },
    "usuarios": {
        "label": "Usuarios",
        "icon": "user",
        "pk": "id_usuario",
        "search_field": "apellido",
        "display": lambda r: f"{r['nombre']} {r['apellido']}",
        "columns": [
            {"name": "id_usuario", "label": "ID", "type": "readonly"},
            {"name": "nombre", "label": "Nombre", "type": "text", "required": True},
            {"name": "apellido", "label": "Apellido", "type": "text", "required": True},
            {"name": "email", "label": "Email", "type": "email", "required": True},
            {"name": "telefono", "label": "Teléfono", "type": "text"},
            {"name": "tipo_usuario", "label": "Tipo", "type": "select",
             "options": ["estudiante", "docente", "administrativo"], "required": True},
            {"name": "fecha_registro", "label": "Fecha de registro", "type": "date"},
        ],
    },
    "prestamos": {
        "label": "Préstamos",
        "icon": "swap",
        "pk": "id_prestamo",
        "search_field": None,
        "display": lambda r: f"#{r['id_prestamo']}",
        "columns": [
            {"name": "id_prestamo", "label": "ID", "type": "readonly"},
            {"name": "id_usuario", "label": "Usuario", "type": "fk", "fk_table": "usuarios", "required": True},
            {"name": "fecha_prestamo", "label": "Fecha de préstamo", "type": "date", "required": True},
            {"name": "fecha_devolucion_esperada", "label": "Devolución esperada", "type": "date", "required": True},
            {"name": "estado", "label": "Estado", "type": "select",
             "options": ["activo", "devuelto", "vencido"], "required": True},
        ],
    },
    "detalle_prestamo": {
        "label": "Detalle de préstamos",
        "icon": "list",
        "pk": "id_detalle",
        "search_field": None,
        "display": lambda r: f"#{r['id_detalle']}",
        "columns": [
            {"name": "id_detalle", "label": "ID", "type": "readonly"},
            {"name": "id_prestamo", "label": "Préstamo", "type": "fk", "fk_table": "prestamos", "required": True},
            {"name": "id_libro", "label": "Libro", "type": "fk", "fk_table": "libros", "required": True},
            {"name": "cantidad", "label": "Cantidad", "type": "number", "required": True},
        ],
    },
    "devoluciones": {
        "label": "Devoluciones",
        "icon": "return",
        "pk": "id_devolucion",
        "search_field": None,
        "display": lambda r: f"#{r['id_devolucion']}",
        "columns": [
            {"name": "id_devolucion", "label": "ID", "type": "readonly"},
            {"name": "id_prestamo", "label": "Préstamo", "type": "fk", "fk_table": "prestamos", "required": True},
            {"name": "fecha_devolucion", "label": "Fecha de devolución", "type": "date", "required": True},
            {"name": "estado_libro", "label": "Estado del libro", "type": "select",
             "options": ["bueno", "danado", "perdido"], "required": True},
        ],
    },
    "multas": {
        "label": "Multas",
        "icon": "coin",
        "pk": "id_multa",
        "search_field": None,
        "display": lambda r: f"#{r['id_multa']}",
        "columns": [
            {"name": "id_multa", "label": "ID", "type": "readonly"},
            {"name": "id_prestamo", "label": "Préstamo", "type": "fk", "fk_table": "prestamos", "required": True},
            {"name": "monto", "label": "Monto", "type": "number", "step": "0.01", "required": True},
            {"name": "fecha_generada", "label": "Fecha generada", "type": "date", "required": True},
            {"name": "pagada", "label": "Pagada", "type": "checkbox"},
        ],
    },
}

# Orden en el que aparecen en la barra lateral
NAV_ORDER = [
    "libros", "autores", "categorias", "usuarios",
    "prestamos", "detalle_prestamo", "devoluciones", "multas",
]
