# Sistema de Gestión de Biblioteca Académica

Proyecto de base de datos relacional para administrar préstamo, devolución
y consulta de libros en una biblioteca académica. Incluye diseño ER,
scripts DDL/DML, consultas SQL (con JOIN, agrupaciones y subconsultas),
un cliente en Python y el entorno de base de datos levantado con **Podman**.

## Stack utilizado

- **Podman** — contenedor con PostgreSQL 16 (base de datos).
- **Git Bash** — terminal para ejecutar comandos de Podman/Git.
- **Python 3** + `psycopg2` — conexión y ejecución de scripts desde código.
- **VS Code** — edición del proyecto (recomendable con la extensión
  "SQLTools" o "PostgreSQL" para explorar la BD, y "Python").

## Estructura del repositorio

```
biblioteca-academica/
├── README.md
├── docs/
│   └── diagrama_er.md          # Diagrama entidad-relación (Mermaid)
├── sql/
│   ├── 01_ddl_create_database.sql
│   ├── 02_dml_insert_data.sql
│   ├── 03_queries_select.sql
│   └── 04_dml_update_delete.sql
├── python/
│   ├── requirements.txt
│   ├── .env.example
│   ├── db_connection.py
│   └── run_scripts.py
├── podman/
│   ├── setup_podman.sh         # Levanta el contenedor PostgreSQL
│   └── load_sql.sh             # Carga los scripts vía psql
└── evidence/                   # Aquí van tus capturas de pantalla
```

## 1. Levantar la base de datos con Podman

Instala Podman Desktop (Windows) y, en Git Bash:

```bash
podman machine init
podman machine start

cd podman
bash setup_podman.sh
```

Esto descarga la imagen `postgres:16`, crea un volumen persistente y
levanta el contenedor `biblioteca_pg` escuchando en `localhost:5432`
con:
- usuario: `biblioteca_user`
- password: `biblioteca_pass`
- base de datos: `biblioteca_academica`

Verifica que esté corriendo:
```bash
podman ps
```

## 2. Cargar el esquema y los datos

**Opción A — directo con psql dentro del contenedor (rápido, sin Python):**
```bash
cd podman
bash load_sql.sh
```

**Opción B — desde Python (recomendado si quieres ver también la salida
de las consultas formateada en consola, como evidencia de ejecución):**
```bash
cd python
python -m venv venv
source venv/Scripts/activate        # Git Bash en Windows
pip install -r requirements.txt

cp .env.example .env                # ajusta credenciales si las cambiaste

python run_scripts.py --all         # ejecuta DDL + DML + todas las consultas
```

Para volver a correr solo las consultas (una vez que ya existen los
datos):
```bash
python run_scripts.py --queries
```

## 3. Evidencia de ejecución

Guarda capturas de pantalla de:
- La salida de `podman ps` mostrando el contenedor activo.
- La salida de `python run_scripts.py --all` con las tablas de resultados.
- Alguna consulta corrida manualmente con `podman exec -it biblioteca_pg psql ...`

Colócalas dentro de `evidence/` y referencia sus nombres en este README
antes de subir el proyecto a GitHub.

## 4. Modelo de datos

Ver [`docs/diagrama_er.md`](docs/diagrama_er.md) para el diagrama
entidad-relación completo (Mermaid, se visualiza directo en GitHub) y
el diccionario de datos.

Tablas: `autores`, `categorias`, `libros`, `usuarios`, `prestamos`,
`detalle_prestamo`, `devoluciones`, `multas`.

## 5. Contenido cubierto

- **DDL**: `CREATE DATABASE`, `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`,
  `NOT NULL`, `UNIQUE`, `CHECK`.
- **DML**: `INSERT`, `UPDATE`, `DELETE`.
- **Consultas**: `SELECT`, `WHERE`, `ORDER BY`, `GROUP BY`, `HAVING`,
  `JOIN`, subconsultas, `UNION`.
- **Álgebra relacional**: selección, proyección, unión, diferencia,
  join relacional (comentados dentro de `03_queries_select.sql`).

## 6. Comandos útiles de Git Bash / Podman

```bash
# Ver logs del contenedor
podman logs biblioteca_pg

# Entrar a psql interactivo
podman exec -it biblioteca_pg psql -U biblioteca_user -d biblioteca_academica

# Detener el contenedor
podman stop biblioteca_pg

# Volver a iniciarlo (los datos persisten en el volumen)
podman start biblioteca_pg

# Eliminar todo (contenedor + volumen) para empezar de cero
podman rm -f biblioteca_pg
podman volume rm biblioteca_pgdata
```

## 7. Subir el proyecto a GitHub

```bash
git init
git add .
git commit -m "Proyecto Biblioteca Académica: DDL, DML, consultas y entorno Podman"
git branch -M main
git remote add origin https://github.com/<tu-usuario>/biblioteca-academica.git
git push -u origin main
```

> Nota: no subas el archivo `.env` (contiene credenciales locales). Ya
> está listo `.env.example` como plantilla y se recomienda agregar un
> `.gitignore` con `venv/`, `.env` y `__pycache__/`.
