"""
db_connection.py
Módulo de conexión a la base de datos PostgreSQL que corre dentro
del contenedor Podman (ver podman/setup_podman.sh).

Uso:
    from db_connection import get_connection
    conn = get_connection()
"""

import os
import psycopg2
from dotenv import load_dotenv

# Carga las variables definidas en el archivo .env (crear una copia
# de .env.example y renombrarla a .env)
load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "dbname": os.getenv("DB_NAME", "biblioteca_academica"),
    "user": os.getenv("DB_USER", "biblioteca_user"),
    "password": os.getenv("DB_PASSWORD", "biblioteca_pass"),
}


def get_connection():
    """Crea y devuelve una conexión a la base de datos."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except psycopg2.OperationalError as e:
        print("No se pudo conectar a la base de datos.")
        print("Verifica que el contenedor de Podman esté corriendo:")
        print("   podman ps")
        raise e


if __name__ == "__main__":
    conn = get_connection()
    print("Conexión exitosa a:", DB_CONFIG["dbname"])
    conn.close()
