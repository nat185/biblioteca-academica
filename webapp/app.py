"""
app.py
Interfaz web para el Sistema de Gestión de Biblioteca Académica.

Rutas principales:
  /                         -> dashboard con estadísticas
  /conexion                 -> estado de conexión y credenciales
  /<tabla>                  -> listado + búsqueda de una tabla
  /<tabla>/nuevo             -> formulario de alta
  /<tabla>/<id>/editar       -> formulario de edición
  /<tabla>/<id>/eliminar     -> elimina un registro (POST)

Ejecutar:
    cd webapp
    python -m venv venv && source venv/Scripts/activate
    pip install -r requirements.txt
    cp .env.example .env
    flask --app app run --debug
"""

from flask import Flask, render_template, request, redirect, url_for, flash
from psycopg2 import sql, errors

from config import TABLES, NAV_ORDER
import db

app = Flask(__name__)
app.secret_key = "biblioteca-academica-dev-key"  # cambia esto en producción


def get_table_or_404(table_name):
    if table_name not in TABLES:
        raise ValueError(f"Tabla desconocida: {table_name}")
    return TABLES[table_name]


def fetch_fk_options(fk_table):
    """Devuelve [(id, texto_para_mostrar), ...] para llenar un <select>."""
    meta = TABLES[fk_table]
    conn = db.get_connection()
    cur = conn.cursor()
    cur.execute(sql.SQL("SELECT * FROM {} ORDER BY 1").format(sql.Identifier(fk_table)))
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [(row[meta["pk"]], meta["display"](row)) for row in rows]


def resolve_fk_labels(table_name, rows):
    """Para mostrar el nombre en vez del id crudo en las tablas de listado."""
    meta = TABLES[table_name]
    fk_columns = [c for c in meta["columns"] if c["type"] == "fk"]
    if not fk_columns:
        return rows
    caches = {}
    for col in fk_columns:
        fk_table = col["fk_table"]
        if fk_table not in caches:
            caches[fk_table] = dict(fetch_fk_options(fk_table))
    for row in rows:
        for col in fk_columns:
            fk_table = col["fk_table"]
            raw_id = row.get(col["name"])
            row[col["name"] + "_label"] = caches[fk_table].get(raw_id, raw_id)
    return rows


@app.context_processor
def inject_globals():
    ok, _ = db.check_connection()
    return {
        "nav_tables": [(t, TABLES[t]["label"]) for t in NAV_ORDER],
        "conn_ok": ok,
    }


# ---------------------------------------------------------------------
# Dashboard
# ---------------------------------------------------------------------
@app.route("/")
def dashboard():
    ok, info = db.check_connection()
    stats = {}
    alerts = {"vencidos": [], "multas_pendientes": []}

    if ok:
        conn = db.get_connection()
        cur = conn.cursor()
        for table_name, meta in TABLES.items():
            cur.execute(sql.SQL("SELECT COUNT(*) AS total FROM {}").format(sql.Identifier(table_name)))
            stats[table_name] = cur.fetchone()["total"]

        cur.execute("""
            SELECT p.id_prestamo, u.nombre, u.apellido, p.fecha_devolucion_esperada
            FROM prestamos p
            JOIN usuarios u ON u.id_usuario = p.id_usuario
            WHERE p.estado = 'vencido'
               OR (p.estado = 'activo' AND p.fecha_devolucion_esperada < CURRENT_DATE)
            ORDER BY p.fecha_devolucion_esperada
            LIMIT 5
        """)
        alerts["vencidos"] = cur.fetchall()

        cur.execute("""
            SELECT m.id_multa, u.nombre, u.apellido, m.monto
            FROM multas m
            JOIN prestamos p ON p.id_prestamo = m.id_prestamo
            JOIN usuarios u ON u.id_usuario = p.id_usuario
            WHERE m.pagada = FALSE
            ORDER BY m.fecha_generada
            LIMIT 5
        """)
        alerts["multas_pendientes"] = cur.fetchall()

        cur.close()
        conn.close()

    return render_template(
        "dashboard.html",
        ok=ok, info=info, stats=stats, tables=TABLES, alerts=alerts,
    )


# ---------------------------------------------------------------------
# Conexión (credenciales / estado)
# ---------------------------------------------------------------------
@app.route("/conexion")
def conexion():
    ok, info = db.check_connection()
    creds = db.connection_info()
    return render_template("connection.html", ok=ok, info=info, creds=creds)


# ---------------------------------------------------------------------
# Listado + búsqueda
# ---------------------------------------------------------------------
@app.route("/<table_name>")
def list_view(table_name):
    meta = get_table_or_404(table_name)
    q = request.args.get("q", "").strip()

    conn = db.get_connection()
    cur = conn.cursor()

    base_query = sql.SQL("SELECT * FROM {}").format(sql.Identifier(table_name))
    if q and meta["search_field"]:
        query = base_query + sql.SQL(" WHERE {} ILIKE %s ORDER BY 1").format(
            sql.Identifier(meta["search_field"])
        )
        cur.execute(query, (f"%{q}%",))
    else:
        query = base_query + sql.SQL(" ORDER BY 1")
        cur.execute(query)

    rows = cur.fetchall()
    cur.close()
    conn.close()

    rows = resolve_fk_labels(table_name, rows)

    return render_template(
        "list.html", table_name=table_name, meta=meta, rows=rows, q=q,
    )


# ---------------------------------------------------------------------
# Alta
# ---------------------------------------------------------------------
@app.route("/<table_name>/nuevo", methods=["GET", "POST"])
def create_view(table_name):
    meta = get_table_or_404(table_name)
    fk_options = {
        c["name"]: fetch_fk_options(c["fk_table"])
        for c in meta["columns"] if c["type"] == "fk"
    }

    if request.method == "POST":
        editable = [c for c in meta["columns"] if c["type"] != "readonly"]
        values = []
        columns = []
        for col in editable:
            if col["type"] == "checkbox":
                values.append(col["name"] in request.form)
            else:
                val = request.form.get(col["name"], "").strip()
                values.append(val if val != "" else None)
            columns.append(col["name"])

        query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
            sql.Identifier(table_name),
            sql.SQL(", ").join(map(sql.Identifier, columns)),
            sql.SQL(", ").join(sql.Placeholder() * len(columns)),
        )
        try:
            conn = db.get_connection()
            cur = conn.cursor()
            cur.execute(query, values)
            conn.commit()
            cur.close()
            conn.close()
            flash(f"Registro creado en {meta['label']}.", "success")
            return redirect(url_for("list_view", table_name=table_name))
        except errors.Error as e:
            flash(f"No se pudo guardar: {e}", "error")

    return render_template(
        "form.html", table_name=table_name, meta=meta, row=None,
        fk_options=fk_options, mode="nuevo",
    )


# ---------------------------------------------------------------------
# Edición
# ---------------------------------------------------------------------
@app.route("/<table_name>/<int:record_id>/editar", methods=["GET", "POST"])
def edit_view(table_name, record_id):
    meta = get_table_or_404(table_name)
    pk = meta["pk"]
    fk_options = {
        c["name"]: fetch_fk_options(c["fk_table"])
        for c in meta["columns"] if c["type"] == "fk"
    }

    conn = db.get_connection()
    cur = conn.cursor()

    if request.method == "POST":
        editable = [c for c in meta["columns"] if c["type"] != "readonly"]
        assignments = []
        values = []
        for col in editable:
            if col["type"] == "checkbox":
                values.append(col["name"] in request.form)
            else:
                val = request.form.get(col["name"], "").strip()
                values.append(val if val != "" else None)
            assignments.append(sql.SQL("{} = %s").format(sql.Identifier(col["name"])))
        values.append(record_id)

        query = sql.SQL("UPDATE {} SET {} WHERE {} = %s").format(
            sql.Identifier(table_name),
            sql.SQL(", ").join(assignments),
            sql.Identifier(pk),
        )
        try:
            cur.execute(query, values)
            conn.commit()
            flash(f"Registro #{record_id} actualizado en {meta['label']}.", "success")
            cur.close()
            conn.close()
            return redirect(url_for("list_view", table_name=table_name))
        except errors.Error as e:
            flash(f"No se pudo actualizar: {e}", "error")

    cur.execute(
        sql.SQL("SELECT * FROM {} WHERE {} = %s").format(
            sql.Identifier(table_name), sql.Identifier(pk)
        ),
        (record_id,),
    )
    row = cur.fetchone()
    cur.close()
    conn.close()

    return render_template(
        "form.html", table_name=table_name, meta=meta, row=row,
        fk_options=fk_options, mode="editar",
    )


# ---------------------------------------------------------------------
# Eliminar
# ---------------------------------------------------------------------
@app.route("/<table_name>/<int:record_id>/eliminar", methods=["POST"])
def delete_view(table_name, record_id):
    meta = get_table_or_404(table_name)
    pk = meta["pk"]
    try:
        conn = db.get_connection()
        cur = conn.cursor()
        cur.execute(
            sql.SQL("DELETE FROM {} WHERE {} = %s").format(
                sql.Identifier(table_name), sql.Identifier(pk)
            ),
            (record_id,),
        )
        conn.commit()
        cur.close()
        conn.close()
        flash(f"Registro #{record_id} eliminado de {meta['label']}.", "success")
    except errors.Error as e:
        flash(f"No se pudo eliminar (puede estar referenciado en otra tabla): {e}", "error")
    return redirect(url_for("list_view", table_name=table_name))


if __name__ == "__main__":
    app.run(debug=True)
