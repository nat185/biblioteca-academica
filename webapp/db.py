"""
db.py
Conexión a PostgreSQL (contenedor Podman) para la interfaz web.
Usa RealDictCursor para que cada fila llegue como diccionario y sea
fácil de usar directo en las plantillas Jinja.
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "biblioteca_academica"),
    "user": os.getenv("DB_USER", "biblioteca_user"),
    "password": os.getenv("DB_PASSWORD", "biblioteca_pass"),
}


def get_connection():
    """Nueva conexión a la base de datos (cursor tipo diccionario)."""
    return psycopg2.connect(cursor_factory=RealDictCursor, **DB_CONFIG)


def check_connection():
    """Prueba la conexión y regresa (ok: bool, version_o_error: str)."""
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()["version"]
        cur.close()
        conn.close()
        return True, version
    except Exception as e:
        return False, str(e)


def connection_info():
    """Datos de conexión seguros para mostrar en pantalla (sin password)."""
    safe = dict(DB_CONFIG)
    safe.pop("password", None)
    safe["password_hint"] = "•" * len(DB_CONFIG["password"])
    return safe
