#!/bin/bash

# Script para inicializar Moodle después de que el contenedor esté corriendo
# Este script se ejecuta manualmente la primera vez

echo "Esperando a que la base de datos esté lista..."
sleep 10

echo "Inicializando Moodle..."
docker-compose exec moodle php /var/www/html/admin/cli/install_database.php \
    --agree-license \
    --adminuser=admin \
    --adminpass=admin123 \
    --adminemail=admin@example.com \
    --fullname="Moodle Zoom Plugin Dev" \
    --shortname=zoomdev \
    --wwwroot=http://localhost:8080 \
    --dataroot=/var/moodledata \
    --dbtype=mysqli \
    --dbhost=db \
    --dbname=moodle \
    --dbuser=moodle \
    --dbpass=moodle \
    --non-interactive

echo "Moodle inicializado correctamente!"
echo "Accede a http://localhost:8080"
echo "Usuario: admin"
echo "Contraseña: admin123"

