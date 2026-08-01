"""
run_scripts.py
Ejecuta los scripts SQL del proyecto en orden (DDL -> DML -> queries)
y muestra el resultado de cada consulta en consola. Sirve como
"evidencia de ejecución" (puedes capturar la salida con un
screenshot o redirigirla a un archivo de texto).

Uso desde Git Bash, con el contenedor Podman ya corriendo:
    cd python
    python -m venv venv
    source venv/Scripts/activate      # Windows Git Bash
    pip install -r requirements.txt
    python run_scripts.py
"""

import sys
from pathlib import Path

from tabulate import tabulate
from db_connection import get_connection

SQL_DIR = Path(__file__).resolve().parent.parent / "sql"

SETUP_SCRIPTS = [
    "01_ddl_create_database.sql",
    "02_dml_insert_data.sql",
]

QUERY_SCRIPT = "03_queries_select.sql"


def run_setup(conn):
    """Ejecuta DDL + DML como sentencias de definición/manipulación."""
    cur = conn.cursor()
    for filename in SETUP_SCRIPTS:
        path = SQL_DIR / filename
        print(f"\n>>> Ejecutando {filename} ...")
        sql_text = path.read_text(encoding="utf-8")
        cur.execute(sql_text)
        conn.commit()
        print(f"    OK: {filename} aplicado.")
    cur.close()


def split_statements(sql_text: str):
    """Separa el archivo de consultas en sentencias individuales por ';'
    ignorando líneas de comentario."""
    statements = []
    current = []
    for line in sql_text.splitlines():
        stripped = line.strip()
        if stripped.startswith("--") or not stripped:
            continue
        current.append(line)
        if stripped.endswith(";"):
            statements.append("\n".join(current))
            current = []
    return statements


def run_queries(conn):
    cur = conn.cursor()
    path = SQL_DIR / QUERY_SCRIPT
    sql_text = path.read_text(encoding="utf-8")
    statements = split_statements(sql_text)

    for i, stmt in enumerate(statements, start=1):
        print(f"\n===== Consulta {i} =====")
        print(stmt.strip()[:200], "...\n" if len(stmt) > 200 else "\n")
        try:
            cur.execute(stmt)
            rows = cur.fetchall()
            headers = [desc[0] for desc in cur.description]
            print(tabulate(rows, headers=headers, tablefmt="grid"))
        except Exception as e:
            print(f"Error ejecutando la consulta: {e}")
            conn.rollback()
    cur.close()


def main():
    conn = get_connection()
    try:
        if "--setup" in sys.argv or "--all" in sys.argv:
            run_setup(conn)
        if "--queries" in sys.argv or "--all" in sys.argv or len(sys.argv) == 1:
            run_queries(conn)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
