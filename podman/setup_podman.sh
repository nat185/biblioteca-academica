#!/usr/bin/env bash
# =====================================================================
# setup_podman.sh
# Crea y levanta un contenedor de PostgreSQL con Podman para el
# proyecto de Biblioteca Académica.
#
# Uso (desde Git Bash, en la carpeta podman/):
#   bash setup_podman.sh
#
# Requiere tener Podman instalado y Podman Machine iniciada en Windows:
#   podman machine init
#   podman machine start
# =====================================================================
set -e

CONTAINER_NAME="biblioteca_pg"
DB_NAME="biblioteca_academica"
DB_USER="biblioteca_user"
DB_PASSWORD="biblioteca_pass"
DB_PORT="5432"
VOLUME_NAME="biblioteca_pgdata"

echo ">>> Descargando imagen oficial de PostgreSQL (si no existe)..."
podman pull docker.io/library/postgres:16

echo ">>> Creando volumen persistente para los datos..."
podman volume create "$VOLUME_NAME" || true

# Si ya existe un contenedor previo con el mismo nombre, lo removemos
if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo ">>> Contenedor existente encontrado, eliminándolo..."
    podman rm -f "$CONTAINER_NAME"
fi

echo ">>> Levantando el contenedor $CONTAINER_NAME ..."
podman run -d \
    --name "$CONTAINER_NAME" \
    -e POSTGRES_DB="$DB_NAME" \
    -e POSTGRES_USER="$DB_USER" \
    -e POSTGRES_PASSWORD="$DB_PASSWORD" \
    -p "$DB_PORT":5432 \
    -v "$VOLUME_NAME":/var/lib/postgresql/data \
    docker.io/library/postgres:16

echo ">>> Esperando a que PostgreSQL esté listo..."
sleep 5
podman exec "$CONTAINER_NAME" pg_isready -U "$DB_USER"

echo ""
echo "Contenedor '$CONTAINER_NAME' corriendo en el puerto $DB_PORT."
echo "Cadena de conexión: postgresql://$DB_USER:$DB_PASSWORD@localhost:$DB_PORT/$DB_NAME"
echo ""
echo "Para conectarte con psql dentro del contenedor:"
echo "   podman exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME"
echo ""
echo "Para copiar y ejecutar los scripts SQL directamente con psql:"
echo "   podman cp ../sql/01_ddl_create_database.sql $CONTAINER_NAME:/tmp/"
echo "   podman exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -f /tmp/01_ddl_create_database.sql"
