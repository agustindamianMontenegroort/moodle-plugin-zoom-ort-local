# Guía de Funcionamiento y Pruebas del Plugin Zoom Meeting ID

## 📋 ¿Cómo Funciona el Plugin?

### Propósito
El plugin `local_zoommeetingid` permite a los administradores de Moodle:
- **Ver todas las reuniones de Zoom** creadas en los cursos
- **Buscar y filtrar** reuniones por curso, nombre, fecha
- **Exportar** la información de las reuniones en formato CSV o JSON
- **Obtener Meeting IDs** y contraseñas de las reuniones de Zoom

### Arquitectura

```
┌─────────────────────────────────────────┐
│   Usuario (Administrador)               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│   index.php (Interfaz Web)              │
│   - Formulario de filtros               │
│   - Tabla de resultados                 │
│   - Botones de exportación              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│   lib.php (Lógica de Negocio)           │
│   - local_zoommeetingid_get_all_meetings()│
│   - local_zoommeetingid_get_courses_with_zoom()│
│   - local_zoommeetingid_export_csv()    │
│   - local_zoommeetingid_export_json()   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│   Base de Datos Moodle                  │
│   - Tabla {zoom} (del plugin mod_zoom)  │
│   - Tabla {course}                      │
│   - Tabla {course_modules}              │
└─────────────────────────────────────────┘
```

### Flujo de Funcionamiento

1. **Usuario accede a la página** (`/local/zoommeetingid/index.php`)
2. **Sistema verifica permisos** (requiere `local/zoommeetingid:view`)
3. **Se cargan los filtros disponibles** (cursos con Zoom)
4. **Usuario aplica filtros** (opcional):
   - Selecciona un curso
   - Busca por texto (nombre o Meeting ID)
   - Filtra por rango de fechas
5. **Sistema consulta la base de datos** con los filtros aplicados
6. **Se muestran los resultados** en una tabla paginada (20 por página)
7. **Usuario puede exportar** los resultados filtrados en CSV o JSON

### Características Principales

#### 1. Filtros Inteligentes
- **Filtro por curso**: Dropdown con todos los cursos que tienen actividades Zoom
- **Búsqueda de texto**: Busca en el nombre de la reunión o en el Meeting ID
- **Filtro por fecha**: Rango de fechas de inicio y fin
- **Combinación de filtros**: Todos los filtros se pueden usar simultáneamente

#### 2. Paginación
- Muestra 20 resultados por página
- Navegación entre páginas manteniendo los filtros

#### 3. Exportación
- **CSV**: Para abrir en Excel o Google Sheets
- **JSON**: Para procesamiento programático
- **Respetan filtros**: Solo exporta lo que está visible/filtrado

#### 4. Seguridad
- Requiere permisos específicos (`local/zoommeetingid:view`)
- Protección contra SQL injection (consultas preparadas)
- Validación de parámetros de entrada

---

## 🧪 Cómo Probar el Plugin

### Requisitos Previos

1. **Docker y Docker Compose** instalados
2. **Plugin mod_zoom** instalado en Moodle (opcional, pero necesario para tener datos de prueba)
3. **Acceso de administrador** a Moodle

### Paso 1: Iniciar el Ambiente

```bash
# Navegar al directorio del proyecto
cd ~/Documentos/moodle-zoom-plugin

# Iniciar los contenedores Docker
docker-compose up -d

# Verificar que los contenedores estén corriendo
docker-compose ps
```

Deberías ver:
- `moodle_db` (MySQL) - Estado: Up
- `moodle_app` (Moodle) - Estado: Up

### Paso 2: Inicializar Moodle (Solo la primera vez)

```bash
# Esperar unos segundos a que la base de datos esté lista
sleep 10

# Ejecutar el script de inicialización
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

### Paso 3: Instalar el Plugin

1. **Accede a Moodle**:
   - URL: http://localhost:8080
   - Usuario: `admin`
   - Contraseña: `admin123`

2. **Instalar el plugin**:
   - Ve a: **Site administration > Notifications**
   - Moodle detectará el plugin automáticamente
   - Haz clic en **"Upgrade Moodle database now"**
   - Confirma la instalación

3. **Verificar la instalación**:
   - Ve a: **Site administration > Plugins > Local plugins**
   - Deberías ver **"Zoom Meeting ID"** en la lista

### Paso 4: Crear Datos de Prueba (Opcional)

Si tienes el plugin `mod_zoom` instalado, puedes crear reuniones de prueba:

1. **Crear un curso de prueba**:
   - Ve a: **Site administration > Courses > Add a new course**
   - Crea un curso llamado "Curso de Prueba Zoom"

2. **Agregar una actividad Zoom**:
   - Entra al curso
   - Activa edición
   - Agrega una actividad: **Zoom Meeting**
   - Configura la reunión con:
     - Nombre: "Reunión de Prueba 1"
     - Fecha y hora
     - Duración

3. **Repite** para crear varias reuniones en diferentes cursos

### Paso 5: Probar el Plugin

#### 5.1 Acceder al Plugin

**Opción A - Desde el menú**:
- Ve a: **Site administration > Plugins > Local plugins > Zoom Meeting ID**

**Opción B - URL directa**:
- http://localhost:8080/local/zoommeetingid/index.php

#### 5.2 Probar los Filtros

**Prueba 1: Ver todas las reuniones**
- Deja todos los filtros vacíos
- Haz clic en "Filtrar"
- Deberías ver todas las reuniones de Zoom del sistema

**Prueba 2: Filtrar por curso**
- Selecciona un curso del dropdown
- Haz clic en "Filtrar"
- Solo deberías ver reuniones de ese curso

**Prueba 3: Búsqueda por texto**
- Escribe parte del nombre de una reunión en el campo "Buscar"
- Haz clic en "Filtrar"
- Deberías ver solo las reuniones que coincidan

**Prueba 4: Filtrar por fecha**
- Selecciona una fecha de inicio
- Selecciona una fecha de fin
- Haz clic en "Filtrar"
- Solo deberías ver reuniones en ese rango

**Prueba 5: Combinar filtros**
- Selecciona un curso
- Escribe un texto de búsqueda
- Selecciona un rango de fechas
- Haz clic en "Filtrar"
- Deberías ver solo las reuniones que cumplan todas las condiciones

**Prueba 6: Limpiar filtros**
- Con filtros aplicados, haz clic en "Limpiar"
- Deberías volver a ver todas las reuniones

#### 5.3 Probar la Paginación

Si tienes más de 20 reuniones:
- Deberías ver números de página en la parte inferior
- Haz clic en diferentes páginas
- Los filtros se mantienen al cambiar de página

#### 5.4 Probar la Exportación

**Exportar a CSV**:
1. Aplica algunos filtros (opcional)
2. Haz clic en "Exportar a CSV"
3. Se descargará un archivo `zoom_meetings_YYYY-MM-DD.csv`
4. Ábrelo en Excel o un editor de texto
5. Verifica que contenga los datos correctos

**Exportar a JSON**:
1. Aplica algunos filtros (opcional)
2. Haz clic en "Exportar a JSON"
3. Se descargará un archivo `zoom_meetings_YYYY-MM-DD.json`
4. Ábrelo en un editor de texto
5. Verifica que el JSON sea válido y contenga los datos

**Verificar que los filtros se aplican en la exportación**:
1. Filtra por un curso específico
2. Exporta a CSV
3. Verifica que el CSV solo contenga reuniones de ese curso

#### 5.5 Probar Casos Especiales

**Caso 1: Sin reuniones de Zoom**
- Si no hay reuniones, deberías ver el mensaje: "No se encontraron actividades de Zoom"

**Caso 2: Sin plugin mod_zoom instalado**
- El plugin debería funcionar sin errores
- Mostrará "No se encontraron actividades de Zoom"

**Caso 3: Búsqueda sin resultados**
- Busca un texto que no existe
- Deberías ver "No se encontraron actividades de Zoom"

### Paso 6: Verificar Logs (Si hay problemas)

```bash
# Ver logs de Moodle
docker-compose logs moodle

# Ver logs de la base de datos
docker-compose logs db

# Ver logs en tiempo real
docker-compose logs -f moodle
```

### Paso 7: Limpiar y Reiniciar (Si es necesario)

```bash
# Detener los contenedores
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Borra todos los datos)
docker-compose down -v

# Reiniciar desde cero
docker-compose up -d
./init-moodle.sh
```

---

## 🔍 Verificación de Funcionalidades

### Checklist de Pruebas

- [ ] El plugin se instala correctamente
- [ ] Se puede acceder desde el menú de administración
- [ ] Se muestran todas las reuniones sin filtros
- [ ] El filtro por curso funciona
- [ ] La búsqueda por texto funciona
- [ ] Los filtros de fecha funcionan
- [ ] Se pueden combinar múltiples filtros
- [ ] El botón "Limpiar" resetea los filtros
- [ ] La paginación funciona correctamente
- [ ] La exportación CSV funciona
- [ ] La exportación JSON funciona
- [ ] Los filtros se aplican en las exportaciones
- [ ] Se muestra el contador de resultados
- [ ] Los enlaces de "URL de Unión" funcionan
- [ ] Se manejan correctamente los casos sin datos

---

## 🐛 Solución de Problemas Comunes

### Problema: "No se encontraron actividades de Zoom"

**Causas posibles**:
1. No hay reuniones de Zoom creadas
2. El plugin `mod_zoom` no está instalado
3. Las reuniones están en cursos eliminados

**Solución**:
- Verifica que tengas el plugin `mod_zoom` instalado
- Crea algunas reuniones de prueba
- Verifica que las reuniones no estén en proceso de eliminación

### Problema: El plugin no aparece en Moodle

**Solución**:
```bash
# Verificar que el plugin esté en la ubicación correcta
docker-compose exec moodle ls -la /var/www/html/local/

# Deberías ver: zoommeetingid/

# Si no está, verifica el volumen en docker-compose.yml
# Debería estar montado: ./plugins:/var/www/html/local
```

### Problema: Error de permisos

**Solución**:
```bash
docker-compose exec moodle chown -R www-data:www-data /var/www/html/local/zoommeetingid
docker-compose exec moodle chmod -R 755 /var/www/html/local/zoommeetingid
```

### Problema: Error al exportar

**Solución**:
- Verifica los logs: `docker-compose logs moodle`
- Asegúrate de que hay datos para exportar
- Verifica que PHP tenga permisos para escribir archivos temporales

---

## 📊 Estructura de Datos

### Información que muestra el plugin:

- **Meeting ID**: ID único de la reunión de Zoom
- **Nombre de Reunión**: Nombre de la actividad Zoom
- **Curso**: Nombre del curso donde está la reunión
- **Hora de Inicio**: Fecha y hora de inicio formateada
- **Duración**: Duración en minutos
- **Contraseña**: Muestra `***` si tiene contraseña, `-` si no
- **URL de Unión**: Enlace directo para unirse a la reunión

### Formato de Exportación CSV:

```csv
ID,Curso,Nombre de Reunión,Meeting ID,Contraseña,Hora de Inicio,Duración (min),URL de Unión
1,Curso de Prueba,Reunión 1,123456789,abc123,15/11/2024 10:00,60,https://zoom.us/j/123456789
```

### Formato de Exportación JSON:

```json
[
  {
    "id": 1,
    "courseid": 2,
    "coursename": "Curso de Prueba",
    "name": "Reunión 1",
    "meeting_id": "123456789",
    "password": "abc123",
    "start_time": "15/11/2024 10:00",
    "duration": 60,
    "join_url": "https://zoom.us/j/123456789"
  }
]
```

---

## 🎯 Casos de Uso

1. **Administrador necesita listar todas las reuniones**:
   - Accede al plugin sin filtros
   - Exporta a CSV para análisis

2. **Buscar reuniones de un curso específico**:
   - Filtra por curso
   - Ve los detalles de las reuniones

3. **Encontrar reuniones en un período**:
   - Filtra por rango de fechas
   - Exporta para compartir con otros

4. **Buscar una reunión específica**:
   - Usa la búsqueda por texto
   - Encuentra rápidamente por nombre o Meeting ID

---

## 📝 Notas Importantes

- El plugin **NO crea** reuniones de Zoom, solo las **lee** de la base de datos
- Requiere que el plugin `mod_zoom` esté instalado y configurado
- Solo usuarios con el permiso `local/zoommeetingid:view` pueden acceder
- Los datos se leen directamente de la base de datos de Moodle
- No se almacenan datos adicionales, solo se consultan los existentes

---

¡Listo! Ahora ya sabes cómo funciona y cómo probar el plugin. 🚀

