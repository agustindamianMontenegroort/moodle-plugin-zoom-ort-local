# Instrucciones de Instalación

## Paso 1: Iniciar el Ambiente Docker

```bash
cd ~/Documentos/moodle-zoom-plugin
docker-compose up -d
```

Espera unos minutos a que los contenedores se inicien completamente.

## Paso 2: Inicializar Moodle

Ejecuta el script de inicialización:

```bash
./init-moodle.sh
```

O manualmente:

```bash
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
```

## Paso 3: Instalar el Plugin

El plugin ya está en la carpeta `plugins/local/zoommeetingid/`. Para instalarlo:

1. Accede a Moodle: http://localhost:8080
2. Inicia sesión con:
   - Usuario: `admin`
   - Contraseña: `admin123`
3. Ve a: **Site administration > Notifications**
4. Moodle detectará el nuevo plugin y te pedirá que actualices la base de datos
5. Haz clic en "Upgrade Moodle database now"
6. Confirma la instalación

## Paso 4: Verificar la Instalación

1. Ve a: **Site administration > Plugins > Local plugins**
2. Deberías ver "Zoom Meeting ID" en la lista
3. Haz clic en el plugin para acceder a la configuración
4. Desde ahí puedes acceder a la página principal del plugin

## Paso 5: Acceder al Plugin

Puedes acceder directamente a:
http://localhost:8080/local/zoommeetingid/index.php

O desde el menú de administración:
**Site administration > Plugins > Local plugins > Zoom Meeting ID**

## Nota sobre el Plugin de Zoom

Este plugin requiere que tengas instalado el módulo `mod_zoom` en tu Moodle. Si no lo tienes:

1. Descárgalo desde: https://moodle.org/plugins/mod_zoom
2. Instálalo en Moodle
3. Configura las credenciales de Zoom API

El plugin `local_zoommeetingid` leerá las actividades de Zoom creadas con `mod_zoom` y mostrará sus Meeting IDs.

## Solución de Problemas

### El plugin no aparece en Moodle

Verifica que el plugin esté en la ubicación correcta:
```bash
docker-compose exec moodle ls -la /var/www/html/local/
```

Deberías ver la carpeta `zoommeetingid`.

### Error de permisos

```bash
docker-compose exec moodle chown -R www-data:www-data /var/www/html/local/zoommeetingid
docker-compose exec moodle chmod -R 755 /var/www/html/local/zoommeetingid
```

### Reinstalar el plugin

```bash
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php
docker-compose exec moodle php /var/www/html/admin/cli/upgrade.php --non-interactive
```

