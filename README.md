# 🎓 Moodle + Plugin Zoom Meeting ID

Sistema completo de Moodle con Docker que incluye:
- ✅ Plugin oficial de Zoom para crear reuniones
- ✅ Plugin personalizado con API REST para consultar reuniones
- ✅ Base de datos MySQL 8.0
- ✅ Configuración lista para desarrollo

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- [Docker](https://docs.docker.com/get-docker/) (versión 20.10 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versión 2.0 o superior)
- Git
- 4GB de RAM libres
- 10GB de espacio en disco

### Verificar instalación:
```bash
docker --version
docker-compose --version
git --version
```

---

## 🚀 Instalación desde Cero

### Paso 1: Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd moodle-zoom-plugin
```

### Paso 2: Levantar los Contenedores

```bash
# Construir e iniciar los contenedores
docker-compose up -d

# Esperar a que la base de datos esté lista (30-60 segundos)
docker-compose logs -f db
# Presiona Ctrl+C cuando veas: "ready for connections"
```

### Paso 3: Inicializar Moodle

```bash
# Espera 1 minuto después de levantar los contenedores
./init-moodle.sh
```

### Paso 4: Acceder a Moodle

Abre tu navegador en: **http://localhost:8080**

**Credenciales:**
- Usuario: `admin`
- Contraseña: `admin123`

---

## 🔧 Configuración del Plugin de Zoom

### Opción A: Instalación Automática (Recomendado)

Si ya tienes el plugin oficial de Zoom descargado en una carpeta:

1. Coloca la carpeta del plugin en la raíz del proyecto
2. Ejecuta:
```bash
./install-zoom-plugin.sh
```

### Opción B: Instalación Manual

1. Descarga el plugin oficial de Zoom:
   - Visita: https://moodle.org/plugins/mod_zoom
   - O desde GitHub: https://github.com/zoom/moodle-mod_zoom

2. Descomprime y copia al contenedor:
```bash
docker cp zoom/ moodle_app:/var/www/html/mod/
docker-compose exec moodle chown -R www-data:www-data /var/www/html/mod/zoom
docker-compose exec moodle chmod -R 755 /var/www/html/mod/zoom
```

3. En Moodle, ve a:
   ```
   Site administration → Notifications → Upgrade Moodle database now
   ```

### Configurar Credenciales de Zoom

1. **Crear una App en Zoom Marketplace:**
   - Ve a: https://marketplace.zoom.us/
   - Crea una app tipo "Server-to-Server OAuth"
   - Obtén: Account ID, Client ID, Client Secret

2. **Configurar en Moodle:**
   ```
   Site administration → Plugins → Activity modules → Zoom meeting
   ```
   - Ingresa las credenciales de Zoom
   - Guarda los cambios

3. **Configurar Scopes (Permisos):**
   En Zoom Marketplace, agrega estos permisos:
   - `meeting:read:admin`
   - `meeting:write:admin`
   - `user:read:admin`

4. **Agregar tu usuario a Zoom:**
   ```
   Zoom Admin → User Management → Add Users
   ```
   - Agrega el mismo email que usas en Moodle

📚 **Guía detallada:** Ver `GUIA_ZOOM_OFICIAL.md`

---

## 🔌 API REST - Plugin Personalizado

El plugin personalizado (`local_zoommeetingid`) incluye una API REST para consultar reuniones.

### Configuración Automática de la API

```bash
docker-compose exec moodle php /tmp/setup_webservice.php
```

Este script:
- ✅ Habilita servicios web
- ✅ Activa protocolo REST
- ✅ Crea usuario `apiuser`
- ✅ Genera token de acceso
- ✅ Configura permisos

### Probar la API

**Endpoint:**
```
POST http://localhost:8080/webservice/rest/server.php
```

**Parámetros:**
```
wstoken=<TU_TOKEN>
wsfunction=local_zoommeetingid_get_user_meetings
moodlewsrestformat=json
userid=2
```

**Ejemplo con curl:**
```bash
curl -X POST 'http://localhost:8080/webservice/rest/server.php' \
  -d 'wstoken=<TU_TOKEN>' \
  -d 'wsfunction=local_zoommeetingid_get_user_meetings' \
  -d 'moodlewsrestformat=json' \
  -d 'userid=2'
```

### Colección de Postman

Importa la colección en Postman:
```
Zoom_Meeting_API.postman_collection.json
```

📚 **Documentación completa:** Ver `API_DOCUMENTATION.md`

---

## 📁 Estructura del Proyecto

```
moodle-zoom-plugin/
├── docker-compose.yml              # Configuración de Docker
├── Dockerfile.moodle              # Imagen de Moodle
├── .gitignore                     # Archivos excluidos del repo
├── init-moodle.sh                 # Script de inicialización
├── install-zoom-plugin.sh         # Instalador del plugin oficial
├── start-app.sh                   # Script de inicio rápido
│
├── plugins/                       # Plugins personalizados
│   └── zoommeetingid/            # Plugin con API REST
│       ├── classes/
│       │   └── external.php      # Funciones de API
│       ├── db/
│       │   ├── access.php        # Permisos
│       │   ├── install.php       # Script de instalación
│       │   └── services.php      # Definición de servicios web
│       ├── lang/
│       │   └── en/
│       │       └── local_zoommeetingid.php
│       ├── index.php
│       ├── lib.php
│       ├── settings.php
│       └── version.php
│
├── Zoom_Meeting_API.postman_collection.json  # Colección Postman
├── API_DOCUMENTATION.md           # Documentación de API
├── GUIA_ZOOM_OFICIAL.md          # Guía del plugin oficial
├── GUIA_USO.md                   # Guía de uso general
├── INSTALACION.md                # Guía de instalación detallada
└── README.md                     # Este archivo
```

---

## 🎯 Casos de Uso

### 1. Crear una Reunión de Zoom

1. Accede a Moodle
2. Ve a un curso
3. Activa la edición
4. Añade actividad → "Reunión Zoom"
5. Completa el formulario y guarda

### 2. Consultar Reuniones vía API

```bash
curl -X POST 'http://localhost:8080/webservice/rest/server.php' \
  -d 'wstoken=<TU_TOKEN>' \
  -d 'wsfunction=local_zoommeetingid_get_user_meetings' \
  -d 'moodlewsrestformat=json' \
  -d 'userid=2'
```

### 3. Integrar con Aplicación Externa

Usa la API REST para:
- Mostrar próximas reuniones en un dashboard
- Enviar notificaciones automáticas
- Crear reportes personalizados
- Integrar con apps móviles

---

## 🔧 Comandos Útiles

### Docker

```bash
# Ver logs de Moodle
docker-compose logs -f moodle

# Ver logs de la base de datos
docker-compose logs -f db

# Reiniciar contenedores
docker-compose restart

# Detener contenedores
docker-compose down

# Eliminar todo (¡CUIDADO! Borra datos)
docker-compose down -v

# Acceder al contenedor de Moodle
docker-compose exec moodle bash
```

### Moodle

```bash
# Limpiar caché
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php

# Actualizar plugins
docker-compose exec moodle php /var/www/html/admin/cli/upgrade.php --non-interactive

# Backup de la base de datos
docker-compose exec db mysqldump -u root -proot moodle > backup_$(date +%Y%m%d).sql

# Restaurar base de datos
docker-compose exec -T db mysql -u root -proot moodle < backup.sql
```

---

## 🐛 Solución de Problemas

### Problema: Los contenedores no inician

```bash
# Ver qué está fallando
docker-compose logs

# Verificar puertos en uso
sudo netstat -tulpn | grep :8080
sudo netstat -tulpn | grep :3306

# Detener y limpiar
docker-compose down -v
docker-compose up -d
```

### Problema: Error de conexión a la base de datos

```bash
# Verificar que la BD esté lista
docker-compose exec db mysql -u root -proot -e "SELECT 1"

# Reiniciar la base de datos
docker-compose restart db
```

### Problema: Plugin de Zoom no funciona

```bash
# Limpiar caché del plugin
docker-compose exec moodle php -r "
define('CLI_SCRIPT', true);
require_once('/var/www/html/config.php');
\$cache = cache::make('mod_zoom', 'zoomid');
\$cache->purge();
purge_all_caches();
"

# Verificar credenciales
# Administración del Sitio → Plugins → Activity modules → Zoom meeting
```

### Problema: API REST no responde

```bash
# Verificar servicios web habilitados
docker-compose exec db mysql -u root -proot moodle -e "
SELECT * FROM mdl_config WHERE name='enablewebservices';
"

# Reconfigurar servicios web
docker-compose exec moodle php /tmp/setup_webservice.php
```

---

## 📚 Documentación Adicional

- **Plugin oficial de Zoom:** https://github.com/zoom/moodle-mod_zoom
- **Moodle Web Services:** https://docs.moodle.org/en/Web_services
- **Zoom API:** https://developers.zoom.us/docs/api/
- **Docker Compose:** https://docs.docker.com/compose/

---

## 🔐 Seguridad

### Recomendaciones para Producción:

1. **Cambiar credenciales por defecto:**
   - Usuario admin de Moodle
   - Contraseña de MySQL
   - Tokens de API

2. **Usar HTTPS:**
   - Configurar reverse proxy (nginx/traefik)
   - Obtener certificado SSL (Let's Encrypt)

3. **Backup regular:**
   ```bash
   # Automatizar con cron
   0 2 * * * docker-compose exec db mysqldump -u root -proot moodle > /backups/moodle_$(date +\%Y\%m\%d).sql
   ```

4. **Restringir acceso a la API:**
   - Limitar IPs permitidas
   - Usar tokens con expiración
   - Implementar rate limiting

---

## 🤝 Contribuir

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

---

## 📝 Licencia

Este proyecto utiliza:
- Moodle: GPL v3
- Plugin oficial de Zoom: GPL v3
- Plugin personalizado: GPL v3

---

## 👥 Autores

- Plugin personalizado: [Tu nombre]
- Configuración Docker: [Tu nombre]

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisa la sección de [Solución de Problemas](#-solución-de-problemas)
2. Consulta la documentación en `/docs`
3. Abre un issue en GitHub

---

## ✅ Checklist de Verificación

Antes de considerar la instalación completa, verifica:

- [ ] Docker y Docker Compose instalados
- [ ] Contenedores corriendo (`docker-compose ps`)
- [ ] Moodle accesible en http://localhost:8080
- [ ] Login con admin/admin123 funciona
- [ ] Plugin de Zoom instalado y configurado
- [ ] Al menos una reunión de Zoom creada
- [ ] API REST configurada
- [ ] Token de API generado
- [ ] Colección de Postman funciona
- [ ] curl de prueba devuelve datos

---

**Versión:** 1.0  
**Última actualización:** Noviembre 2025  
**Compatible con:** Moodle 4.2+
