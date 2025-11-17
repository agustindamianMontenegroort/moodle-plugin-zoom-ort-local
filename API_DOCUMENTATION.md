# 📚 Documentación API - Zoom Meeting ID

API REST para obtener información de reuniones de Zoom desde Moodle.

## 🚀 Inicio Rápido

### Endpoint Base
```
http://localhost:8080/webservice/rest/server.php
```

### Autenticación
Todas las peticiones requieren el parámetro `wstoken`:
```
wstoken=e55a323a4c06f29ae10d0dcf5b5f9a44
```

---

## 📋 Endpoints Disponibles

### 1. Obtener Reuniones de Usuario

Obtiene todas las reuniones de Zoom de los cursos donde un usuario está inscrito.

**Función:** `local_zoommeetingid_get_user_meetings`

**Método:** `POST`

**Parámetros:**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `wstoken` | string | ✅ | Token de autenticación |
| `wsfunction` | string | ✅ | `local_zoommeetingid_get_user_meetings` |
| `moodlewsrestformat` | string | ✅ | Formato de respuesta (`json` o `xml`) |
| `userid` | integer | ✅ | ID del usuario en Moodle |

**Ejemplo de Petición (curl):**
```bash
curl -X POST 'http://localhost:8080/webservice/rest/server.php' \
  -d 'wstoken=e55a323a4c06f29ae10d0dcf5b5f9a44' \
  -d 'wsfunction=local_zoommeetingid_get_user_meetings' \
  -d 'moodlewsrestformat=json' \
  -d 'userid=2'
```

**Ejemplo de Respuesta:**
```json
{
  "userid": 2,
  "username": "admin",
  "fullname": "Administrador Usuario",
  "email": "40131362@comunidadort.edu.ar",
  "totalcourses": 1,
  "totalmeetings": 1,
  "meetings": [
    {
      "meetingid": "7950578606",
      "meetingname": "prueba",
      "courseid": 2,
      "coursename": "prueba",
      "courseshortname": "P1",
      "starttime": 1763337300,
      "duration": 3600,
      "joinurl": "https://us04web.zoom.us/j/7950578606?pwd=...",
      "password": "131239"
    }
  ]
}
```

**Campos de Respuesta:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `userid` | integer | ID del usuario en Moodle |
| `username` | string | Nombre de usuario |
| `fullname` | string | Nombre completo del usuario |
| `email` | string | Email del usuario |
| `totalcourses` | integer | Total de cursos donde está inscrito |
| `totalmeetings` | integer | Total de reuniones de Zoom disponibles |
| `meetings` | array | Array de reuniones de Zoom |

**Campos de Meeting:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `meetingid` | string | ID de la reunión de Zoom |
| `meetingname` | string | Nombre de la reunión |
| `courseid` | integer | ID del curso en Moodle |
| `coursename` | string | Nombre completo del curso |
| `courseshortname` | string | Nombre corto del curso |
| `starttime` | integer | Timestamp de inicio (Unix timestamp) |
| `duration` | integer | Duración en segundos |
| `joinurl` | string | URL para unirse a la reunión |
| `password` | string | Contraseña de la reunión (si existe) |

---

## 🔐 Autenticación

### Token de Acceso
El token actual es:
```
e55a323a4c06f29ae10d0dcf5b5f9a44
```

### Usuario de Servicio Web
- **Username:** `apiuser`
- **Password:** `ApiUser123!`
- **Email:** `api@example.com`

### Regenerar Token
Para regenerar el token, ejecuta:
```bash
docker-compose exec moodle php /tmp/setup_webservice.php
```

---

## 📝 Ejemplos de Uso

### Ejemplo 1: Usuario Admin (ID 2)
```bash
curl -X POST 'http://localhost:8080/webservice/rest/server.php' \
  -d 'wstoken=e55a323a4c06f29ae10d0dcf5b5f9a44' \
  -d 'wsfunction=local_zoommeetingid_get_user_meetings' \
  -d 'moodlewsrestformat=json' \
  -d 'userid=2'
```

### Ejemplo 2: Usuario API (ID 3)
```bash
curl -X POST 'http://localhost:8080/webservice/rest/server.php' \
  -d 'wstoken=e55a323a4c06f29ae10d0dcf5b5f9a44' \
  -d 'wsfunction=local_zoommeetingid_get_user_meetings' \
  -d 'moodlewsrestformat=json' \
  -d 'userid=3'
```

### Ejemplo 3: Con JavaScript (Fetch API)
```javascript
const getMeetings = async (userId) => {
  const params = new URLSearchParams({
    wstoken: 'e55a323a4c06f29ae10d0dcf5b5f9a44',
    wsfunction: 'local_zoommeetingid_get_user_meetings',
    moodlewsrestformat: 'json',
    userid: userId
  });

  const response = await fetch('http://localhost:8080/webservice/rest/server.php', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: params
  });

  return await response.json();
};

// Uso
getMeetings(2).then(data => console.log(data));
```

### Ejemplo 4: Con Python (requests)
```python
import requests

def get_user_meetings(user_id):
    url = 'http://localhost:8080/webservice/rest/server.php'
    data = {
        'wstoken': 'e55a323a4c06f29ae10d0dcf5b5f9a44',
        'wsfunction': 'local_zoommeetingid_get_user_meetings',
        'moodlewsrestformat': 'json',
        'userid': user_id
    }
    
    response = requests.post(url, data=data)
    return response.json()

# Uso
meetings = get_user_meetings(2)
print(meetings)
```

---

## ⚠️ Manejo de Errores

### Error: Token Inválido
```json
{
  "exception": "webservice_access_exception",
  "errorcode": "accessexception",
  "message": "Invalid token - token not found"
}
```

### Error: Usuario No Existe
```json
{
  "exception": "dml_missing_record_exception",
  "errorcode": "invalidrecord",
  "message": "Can't find data record in database table user."
}
```

### Error: Función No Existe
```json
{
  "exception": "webservice_function_exception",
  "errorcode": "functionnotfound",
  "message": "The function does not exist"
}
```

---

## 🧪 Testing

### Postman Collection
Importa la colección de Postman:
```
Zoom_Meeting_API.postman_collection.json
```

### Tests Incluidos
- ✅ Validación de status code 200
- ✅ Verificación de estructura de respuesta
- ✅ Validación de campos requeridos
- ✅ Tests de errores (token inválido, usuario inexistente)

---

## 🔧 Configuración Técnica

### Archivos del Plugin
```
/var/www/html/local/zoommeetingid/
├── classes/
│   └── external.php          # Clase con funciones de API
├── db/
│   ├── access.php            # Permisos
│   ├── install.php           # Script de instalación
│   └── services.php          # Definición de servicios web
├── lang/
│   └── en/
│       └── local_zoommeetingid.php  # Textos en inglés
├── index.php                 # Página principal
├── lib.php                   # Funciones del plugin
├── settings.php              # Configuración
└── version.php               # Versión del plugin
```

### Base de Datos
El plugin consulta la tabla `mdl_zoom` que contiene:
- Meeting ID
- Nombre de reunión
- Curso asociado
- Fecha y hora de inicio
- Duración
- URL de unión
- Contraseña

---

## 📊 Casos de Uso

### 1. Dashboard de Reuniones
Crear un dashboard externo que muestre todas las reuniones de un estudiante.

### 2. Integración con App Móvil
Consumir la API desde una aplicación móvil para mostrar próximas reuniones.

### 3. Notificaciones Automáticas
Sistema que consulta la API y envía recordatorios de reuniones próximas.

### 4. Reportes Personalizados
Generar reportes de asistencia cruzando con datos externos.

---

## 🔄 Actualizar Plugin

Si modificas el código del plugin:

```bash
# Actualizar versión
docker-compose exec moodle php /var/www/html/admin/cli/upgrade.php --non-interactive

# Limpiar caché
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php
```

---

## 📞 Soporte

Para problemas o preguntas:
1. Revisa los logs: `docker-compose logs -f moodle`
2. Verifica que el servicio esté habilitado en Moodle
3. Confirma que el token sea válido

---

## 📄 Licencia

Este plugin es parte del proyecto Moodle y se distribuye bajo licencia GPL v3.

---

**Versión:** 1.1  
**Última actualización:** 17 de noviembre, 2025
