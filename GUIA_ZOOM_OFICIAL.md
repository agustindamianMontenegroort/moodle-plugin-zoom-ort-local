# Guía de Instalación y Configuración del Plugin Oficial de Zoom

Esta guía te llevará paso a paso por el proceso de instalación y configuración del plugin oficial de Zoom para Moodle.

## Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación del Plugin](#instalación-del-plugin)
3. [Configuración de Zoom API](#configuración-de-zoom-api)
4. [Configuración en Moodle](#configuración-en-moodle)
5. [Uso del Plugin](#uso-del-plugin)
6. [Solución de Problemas](#solución-de-problemas)

---

## Requisitos Previos

Antes de comenzar, asegúrate de tener:

- ✅ Docker y Docker Compose instalados
- ✅ Moodle corriendo en el contenedor (`docker-compose up -d`)
- ✅ Moodle inicializado (`./init-moodle.sh`)
- ✅ Cuenta de Zoom (gratuita o de pago)
- ✅ Permisos de administrador en Zoom

---

## Instalación del Plugin

### IMPORTANTE: Descargar el Plugin Oficial

El plugin oficial de Zoom **NO está incluido** en este repositorio. Debes descargarlo desde:

🔗 **https://moodle.org/plugins/mod_zoom**

**Pasos para descargar:**

1. Ve a https://moodle.org/plugins/mod_zoom
2. Busca la sección "Version" y selecciona:
   - **Moodle 4.2** (o la versión que estés usando)
3. Haz clic en el botón **"Download"**
4. Guarda el archivo ZIP
5. Descomprime el archivo (obtendrás una carpeta llamada `zoom`)

---

### Método 1: Script Automatizado (Recomendado)

1. **Coloca la carpeta descomprimida** (`zoom`) en la raíz del proyecto

2. **Ejecuta el script de instalación:**

```bash
./install-zoom-plugin.sh
```

3. **Sigue las instrucciones en pantalla**

El script hará todo automáticamente:
- Copia el plugin al contenedor
- Configura los permisos
- Limpia la caché

### Método 2: Manual

Si prefieres hacerlo manualmente:

```bash
# 1. Asegúrate de tener la carpeta 'zoom' en la raíz del proyecto

# 2. Copiar al contenedor
docker cp zoom moodle_app:/var/www/html/mod/

# 3. Ajustar permisos
docker-compose exec moodle chown -R www-data:www-data /var/www/html/mod/zoom
docker-compose exec moodle chmod -R 755 /var/www/html/mod/zoom

# 4. Limpiar caché
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php
```

---

## Configuración de Zoom API

Para que el plugin funcione, necesitas crear una aplicación en Zoom Marketplace y obtener las credenciales de la API.

### Paso 1: Acceder a Zoom Marketplace

1. Ve a: https://marketplace.zoom.us/
2. Inicia sesión con tu cuenta de Zoom
3. Haz clic en **"Develop"** en la esquina superior derecha
4. Selecciona **"Build App"**

### Paso 2: Crear una Server-to-Server OAuth App

1. Selecciona **"Server-to-Server OAuth"**
2. Haz clic en **"Create"**
3. Completa el formulario:
   - **App Name**: `Moodle Zoom Integration`
   - **Company Name**: Tu nombre o nombre de tu organización
   - **Developer Contact**: Tu email
   - **Short Description**: `Integración de Zoom con Moodle`

4. Haz clic en **"Create"**

### Paso 3: Obtener las Credenciales

Después de crear la app, verás tres credenciales importantes:

```
📋 Account ID: xxxxxxxxxxxx
🔑 Client ID: xxxxxxxxxxxx
🔐 Client Secret: xxxxxxxxxxxx
```

**⚠️ IMPORTANTE:** Guarda estas credenciales en un lugar seguro. Las necesitarás para configurar Moodle.

### Paso 4: Configurar los Scopes (Permisos)

1. Ve a la pestaña **"Scopes"**
2. Haz clic en **"+ Add Scopes"**
3. Selecciona los siguientes scopes:

**Requeridos:**
- ✅ `meeting:read:admin` - Leer información de reuniones
- ✅ `meeting:write:admin` - Crear y modificar reuniones
- ✅ `user:read:admin` - Leer información de usuarios
- ✅ `recording:read:admin` - Leer grabaciones (opcional pero recomendado)
- ✅ `report:read:admin` - Leer reportes (opcional pero recomendado)

4. Haz clic en **"Done"**
5. Haz clic en **"Continue"**

### Paso 5: Activar la App

1. Ve a la pestaña **"Activation"**
2. Completa el formulario con información breve
3. Haz clic en **"Activate your app"**

---

## Configuración en Moodle

### Paso 1: Actualizar la Base de Datos

1. Accede a Moodle: http://localhost:8080
2. Inicia sesión con:
   - Usuario: `admin`
   - Contraseña: `admin123`
3. Serás redirigido automáticamente a: **Site administration → Notifications**
4. Verás que Moodle detectó el nuevo plugin `mod_zoom`
5. Haz clic en **"Upgrade Moodle database now"**
6. Espera a que termine la instalación

### Paso 2: Configurar las Credenciales de Zoom

1. Ve a: **Site administration → Plugins → Activity modules → Zoom meeting**

2. Completa los siguientes campos:

   **Autenticación:**
   - **Account ID**: Pega el Account ID de Zoom
   - **Client ID**: Pega el Client ID de Zoom
   - **Client Secret**: Pega el Client Secret de Zoom

   **Configuración General:**
   - **Default meeting duration**: `30` (minutos)
   - **Force participants to join before host**: `No` (recomendado)
   - **Join before host**: `Yes` (permite unirse antes)
   - **Host video**: `Yes` (video del anfitrión activado)
   - **Participants video**: `Yes` (video de participantes activado)
   - **Mute participants upon entry**: `No` (no silenciar al entrar)
   - **Waiting room**: `No` (desactivado para cursos)
   - **Audio**: `Both` (teléfono y computadora)

3. Haz clic en **"Save changes"**

### Paso 3: Verificar la Conexión

1. En la misma página, busca el botón **"Test connection"** o similar
2. Si aparece un mensaje de éxito, la configuración es correcta
3. Si hay un error, verifica las credenciales

---

## Uso del Plugin

### Crear una Reunión de Zoom en un Curso

1. **Accede a un curso** en Moodle
2. **Activa la edición** (botón "Turn editing on")
3. **Añade una actividad o recurso**
4. Selecciona **"Zoom meeting"**
5. Completa el formulario:
   - **Meeting name**: Nombre de la reunión
   - **Description**: Descripción de la reunión
   - **When**: Fecha y hora de inicio
   - **Duration**: Duración en minutos
   - **Recurring meeting**: Si es recurrente
   - **Meeting options**: Opciones adicionales
6. Haz clic en **"Save and display"**

### Ver las Reuniones Creadas

Desde tu curso, verás la actividad de Zoom con:
- 🔗 Link para unirse a la reunión
- 📅 Fecha y hora de la reunión
- 👥 Lista de participantes
- 📹 Grabaciones (si las hay)

### Unirse a una Reunión

Los estudiantes pueden:
1. Hacer clic en la actividad de Zoom
2. Hacer clic en el botón **"Join meeting"**
3. Serán redirigidos a Zoom (web o aplicación)

---

## Integración con tu Plugin Personalizado

Tu plugin `local_zoommeetingid` puede complementar el plugin oficial:

- **`mod_zoom`** (oficial): Crea y gestiona las reuniones
- **`local_zoommeetingid`** (personalizado): Lista y exporta los Meeting IDs

Para acceder a las reuniones de Zoom desde tu plugin personalizado:

```php
// En tu código PHP
global $DB;

// Obtener todas las reuniones de Zoom
$zoommeetings = $DB->get_records('zoom');

// Cada reunión tiene:
// - meeting_id: El ID de la reunión de Zoom
// - name: Nombre de la reunión
// - intro: Descripción
// - start_time: Fecha de inicio
// - duration: Duración en segundos
```

---

## Solución de Problemas

### Error: "Invalid access token"

**Causa:** Las credenciales de la API son incorrectas o la app no está activada.

**Solución:**
1. Verifica que copiaste correctamente las credenciales
2. Asegúrate de que la app está activada en Zoom Marketplace
3. Verifica que los scopes están configurados correctamente

### Error: "Plugin not found"

**Causa:** El plugin no está en la ubicación correcta.

**Solución:**
```bash
# Verificar la ubicación
docker-compose exec moodle ls -la /var/www/html/mod/zoom

# Si no existe, reinstalar
./install-zoom-plugin.sh
```

### Error de permisos

**Causa:** Los archivos no tienen los permisos correctos.

**Solución:**
```bash
docker-compose exec moodle chown -R www-data:www-data /var/www/html/mod/zoom
docker-compose exec moodle chmod -R 755 /var/www/html/mod/zoom
```

### Las reuniones no se crean

**Causa:** Puede ser un problema de versión o configuración.

**Solución:**
1. Verifica los logs:
```bash
docker-compose logs -f moodle
```

2. Limpia la caché:
```bash
docker-compose exec moodle php /var/www/html/admin/cli/purge_caches.php
```

3. Verifica la configuración de la API en Zoom

### Reinstalar el plugin

Si necesitas reinstalar el plugin completamente:

```bash
# 1. Eliminar el plugin
docker-compose exec moodle rm -rf /var/www/html/mod/zoom

# 2. Reinstalar
./install-zoom-plugin.sh

# 3. Actualizar la base de datos desde Moodle
# Site administration → Notifications → Upgrade database
```

---

## Recursos Adicionales

- **Documentación Oficial**: https://github.com/zoom/moodle-mod_zoom
- **Zoom API Reference**: https://developers.zoom.us/docs/api/
- **Moodle Plugins Directory**: https://moodle.org/plugins/mod_zoom
- **Soporte de Zoom**: https://support.zoom.us/

---

## Preguntas Frecuentes

### ¿El plugin es gratuito?

Sí, el plugin es gratuito y de código abierto. Sin embargo, necesitas una cuenta de Zoom (puede ser gratuita o de pago).

### ¿Funciona con cuentas gratuitas de Zoom?

Sí, pero las cuentas gratuitas tienen limitaciones:
- Reuniones de hasta 40 minutos con 3+ participantes
- Reuniones ilimitadas con 1 participante
- Funcionalidades básicas

### ¿Puedo usar Zoom sin la aplicación?

Sí, Zoom funciona desde el navegador web, aunque la aplicación ofrece mejor rendimiento.

### ¿Se graban las reuniones automáticamente?

No, debes activar la grabación manualmente en cada reunión o configurarlo como opción predeterminada.

### ¿Los estudiantes necesitan cuenta de Zoom?

No necesariamente. Pueden unirse como invitados si configuras las reuniones correctamente.

---

## Contacto y Soporte

Si tienes problemas con el plugin:

1. Revisa esta guía
2. Consulta los logs de Moodle
3. Revisa la documentación oficial en GitHub
4. Abre un issue en: https://github.com/zoom/moodle-mod_zoom/issues

---

**Última actualización:** 16 de noviembre, 2025

