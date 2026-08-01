#!/usr/bin/env bash
# =====================================================================
# load_sql.sh
# Copia todos los scripts SQL al contenedor y los ejecuta en orden
# usando psql. Alternativa rápida a usar Python para cargar los datos.
#
# Uso (desde Git Bash, en la carpeta podman/):
#   bash load_sql.sh
# =====================================================================
set -e

CONTAINER_NAME="biblioteca_pg"
DB_USER="biblioteca_user"
DB_NAME="biblioteca_academica"
SQL_DIR="../sql"

SCRIPTS=(
    "01_ddl_create_database.sql"
    "02_dml_insert_data.sql"
    "03_queries_select.sql"
    "04_dml_update_delete.sql"
)

for script in "${SCRIPTS[@]}"; do
    echo ">>> Copiando $script al contenedor..."
    podman cp "$SQL_DIR/$script" "$CONTAINER_NAME":/tmp/"$script"

    echo ">>> Ejecutando $script ..."
    podman exec -it "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -f /tmp/"$script"
    echo ""
done

echo "Todos los scripts se ejecutaron correctamente."
