# Plugin Moodle para Meeting ID de Zoom

Este proyecto contiene el desarrollo de un plugin para Moodle que permite obtener las Meeting ID de Zoom usando Docker Compose.

## Requisitos Previos

- Docker
- Docker Compose

## Inicio Rápido

### 1. Iniciar los servicios

```bash
docker-compose up -d
```

Esto iniciará:
- MySQL 8.0 en el puerto 3306
- Moodle con PHP 8.2 y Apache en el puerto 8080

### 2. Inicializar Moodle

La primera vez que inicies los contenedores, necesitas inicializar Moodle. Espera unos segundos a que la base de datos esté lista y luego ejecuta:

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

### 3. Acceder a Moodle

Abre tu navegador en: http://localhost:8080

**Credenciales por defecto:**
- Usuario: `admin`
- Contraseña: `admin123`

## Estructura del Proyecto

```
moodle-zoom-plugin/
├── docker-compose.yml      # Configuración de Docker Compose
├── Dockerfile.moodle       # Dockerfile para la imagen de Moodle
├── .env                    # Variables de entorno (puedes editarlo)
├── init-moodle.sh          # Script de inicialización
├── plugins/                # Directorio para plugins locales
│   └── zoom_meeting_id/    # Plugin que crearemos aquí
└── README.md               # Este archivo
```

## Desarrollo del Plugin

### Instalar tool_pluginskel

1. Accede a Moodle como administrador
2. Ve a: Site administration > Plugins > Install plugins
3. Busca "Plugin skeleton generator" o instálalo desde:
   https://moodle.org/plugins/tool_pluginskel

### Crear el Plugin

1. Ve a: Site administration > Development > Plugin skeleton generator
2. Completa el formulario:
   - **Component name**: `local_zoommeetingid`
   - **Plugin name**: `Zoom Meeting ID`
   - **Author**: Tu nombre
   - **Type**: Local plugin
3. Descarga el plugin generado
4. Extrae el contenido en `plugins/local_zoommeetingid/`

### Estructura del Plugin

El plugin tendrá la siguiente estructura:

```
local_zoommeetingid/
├── version.php
├── lang/
│   └── en/
│       └── local_zoommeetingid.php
├── lib.php
├── settings.php
└── ...
```

## Comandos Útiles

### Ver logs
```bash
docker-compose logs -f moodle
docker-compose logs -f db
```

### Detener servicios
```bash
docker-compose down
```

### Detener y eliminar volúmenes (¡CUIDADO! Esto borra los datos)
```bash
docker-compose down -v
```

### Acceder al contenedor de Moodle
```bash
docker-compose exec moodle bash
```

### Ejecutar comandos CLI de Moodle
```bash
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php
docker-compose exec moodle php /var/www/html/admin/cli/upgrade.php --non-interactive
```

### Reconstruir la imagen
```bash
docker-compose build --no-cache moodle
```

## Configuración

Puedes editar el archivo `.env` para cambiar:
- Contraseñas de base de datos
- Credenciales de administrador de Moodle
- Configuraciones PHP

## Desarrollo del Plugin de Zoom

El plugin `local_zoommeetingid` permitirá:
- Obtener las Meeting ID de las actividades de Zoom en Moodle
- Listar todas las reuniones de Zoom configuradas
- Exportar información de las reuniones

## Notas

- Los plugins locales se montan en `/var/www/html/local` dentro del contenedor
- Los datos de Moodle se persisten en volúmenes Docker
- La base de datos MySQL se persiste en un volumen separado

## Solución de Problemas

### Moodle no inicia
```bash
docker-compose logs moodle
```

### Base de datos no responde
```bash
docker-compose logs db
docker-compose restart db
```

### Reinstalar desde cero
```bash
docker-compose down -v
docker-compose up -d
./init-moodle.sh
```
