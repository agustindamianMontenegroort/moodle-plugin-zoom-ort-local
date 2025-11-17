# 📋 Qué Archivos Subir al Repositorio

Esta guía lista exactamente qué archivos DEBEN y NO DEBEN subirse al repositorio Git.

---

## ✅ ARCHIVOS QUE DEBEN ESTAR EN EL REPO

### 📁 Raíz del Proyecto
```
✅ .gitignore                                # Exclusiones de Git
✅ README.md                                 # Documentación principal
✅ docker-compose.yml                        # Configuración de Docker
✅ Dockerfile.moodle                        # Imagen de Moodle
✅ init-moodle.sh                           # Script de inicialización
✅ start-app.sh                             # Script de inicio rápido
✅ install-docker.sh                        # Instalador de Docker
✅ install-zoom-plugin.sh                   # Instalador del plugin oficial
✅ fix-docker-compose.sh                    # Script de reparación
```

### 📄 Documentación
```
✅ GUIA_USO.md                              # Guía de uso
✅ GUIA_ZOOM_OFICIAL.md                     # Guía del plugin de Zoom
✅ INSTALACION.md                           # Guía de instalación
✅ API_DOCUMENTATION.md                     # Documentación de API
✅ QUE_SUBIR_AL_REPO.md                     # Este archivo
```

### 🔌 Plugin Personalizado (TODO)
```
✅ plugins/
   └── zoommeetingid/
       ├── classes/
       │   └── external.php                 # Funciones de API
       ├── db/
       │   ├── access.php                   # Permisos
       │   ├── install.php                  # Script de instalación
       │   └── services.php                 # Servicios web
       ├── lang/
       │   └── en/
       │       └── local_zoommeetingid.php  # Textos
       ├── index.php                        # Página principal
       ├── lib.php                          # Funciones
       ├── settings.php                     # Configuración
       └── version.php                      # Versión
```

### 🧪 Testing y API
```
✅ Zoom_Meeting_API.postman_collection.json # Colección de Postman
```

---

## ❌ ARCHIVOS QUE NO DEBEN SUBIRSE

### 🔒 Datos Sensibles (MUY IMPORTANTE)
```
❌ .env                                     # Contraseñas y variables de entorno
❌ tokens.txt                               # Tokens de API
❌ credentials.txt                          # Credenciales de Zoom
❌ config.php                               # Config de Moodle con passwords
❌ backup*.sql                              # Backups de base de datos
```

### 💾 Volúmenes y Datos Persistentes
```
❌ moodle_data/                             # Datos de Moodle
❌ moodledata/                              # Archivos de usuarios
❌ db_data/                                 # Base de datos MySQL
❌ volumes/                                 # Cualquier volumen
```

### 🗂️ Archivos Temporales
```
❌ tmp/                                     # Archivos temporales
❌ *.log                                    # Logs
❌ *.tmp                                    # Temporales
❌ *.swp, *.swo                            # Swap files de editores
❌ *~                                       # Backups de editores
```

### 💻 IDEs y Sistemas Operativos
```
❌ .vscode/                                 # Visual Studio Code
❌ .idea/                                   # JetBrains IDEs
❌ *.iml                                    # IntelliJ
❌ .DS_Store                                # macOS
```

### 📦 Dependencias
```
❌ node_modules/                            # Node.js
❌ __pycache__/                             # Python
❌ venv/                                    # Python virtual env
❌ vendor/                                  # PHP Composer (si usas)
```

---

## 📋 Checklist Antes de Subir al Repo

Antes de hacer `git push`, verifica:

### 1. Limpieza de Archivos Sensibles
```bash
# Buscar archivos con contraseñas
grep -r "password" * --exclude-dir={node_modules,.git,vendor}

# Buscar tokens
grep -r "token" * --exclude-dir={node_modules,.git,vendor}

# Buscar API keys
grep -r "api_key\|apikey\|secret" * --exclude-dir={node_modules,.git,vendor}
```

### 2. Verificar .gitignore
```bash
# Ver qué se va a subir
git status

# Ver qué está ignorado
git status --ignored
```

### 3. Limpiar Archivos de Testing
```bash
# Eliminar archivos temporales
rm -rf tmp/
rm -f *.log
rm -f *.tmp
```

### 4. Actualizar Documentación
```bash
# Verificar que README esté actualizado
cat README.md

# Verificar que versiones sean correctas
grep "version" plugins/zoommeetingid/version.php
```

---

## 🔄 Comandos Git Recomendados

### Primera vez (Subir al repo)
```bash
cd /home/agus/Documentos/moodle-zoom-plugin

# Inicializar Git (si no está inicializado)
git init

# Agregar todos los archivos (respetando .gitignore)
git add .

# Ver qué se va a subir
git status

# Commit inicial
git commit -m "Initial commit: Moodle + Zoom plugin + API REST"

# Conectar con tu repositorio remoto
git remote add origin <URL_DE_TU_REPO>

# Subir al repositorio
git push -u origin main
```

### Actualizaciones posteriores
```bash
# Ver cambios
git status
git diff

# Agregar cambios específicos
git add archivo_modificado.php
git add documentacion/

# O agregar todo
git add .

# Commit con mensaje descriptivo
git commit -m "Descripción de los cambios"

# Subir cambios
git push
```

---

## 📦 Estructura Recomendada del Repositorio

```
moodle-zoom-plugin/                         # Repositorio público
│
├── .gitignore                              # ✅ Subir
├── README.md                               # ✅ Subir
├── LICENSE                                 # ✅ Subir (si lo creas)
│
├── docker/                                 # ✅ Subir todo
│   ├── docker-compose.yml
│   ├── Dockerfile.moodle
│   └── .env.example                        # ✅ Ejemplo (sin credenciales reales)
│
├── scripts/                                # ✅ Subir todo
│   ├── init-moodle.sh
│   ├── install-zoom-plugin.sh
│   ├── start-app.sh
│   └── setup-webservice.sh
│
├── plugins/                                # ✅ Subir todo
│   └── zoommeetingid/
│       └── [todos los archivos del plugin]
│
├── docs/                                   # ✅ Subir toda la documentación
│   ├── API_DOCUMENTATION.md
│   ├── GUIA_ZOOM_OFICIAL.md
│   ├── INSTALACION.md
│   └── GUIA_USO.md
│
├── postman/                                # ✅ Subir colecciones
│   └── Zoom_Meeting_API.postman_collection.json
│
└── examples/                               # ✅ Ejemplos de uso
    ├── curl_examples.sh
    ├── python_client.py
    └── javascript_client.js
```

---

## 🔐 Archivo .env.example

Crea un `.env.example` con valores de ejemplo (SIN credenciales reales):

```bash
# Crear archivo de ejemplo
cat > .env.example << 'EOF'
# MySQL Configuration
MYSQL_ROOT_PASSWORD=tu_password_seguro_aqui
MYSQL_DATABASE=moodle
MYSQL_USER=moodle
MYSQL_PASSWORD=tu_password_moodle_aqui

# Moodle Configuration
MOODLE_ADMIN_USER=admin
MOODLE_ADMIN_PASSWORD=tu_password_admin_aqui
MOODLE_ADMIN_EMAIL=admin@example.com

# Zoom API (obtener de https://marketplace.zoom.us/)
ZOOM_ACCOUNT_ID=tu_account_id
ZOOM_CLIENT_ID=tu_client_id
ZOOM_CLIENT_SECRET=tu_client_secret
EOF
```

Los usuarios deberán copiar `.env.example` a `.env` y completar con sus datos.

---

## 🚀 Instrucciones para Nuevos Usuarios

En tu README.md, incluye estas instrucciones:

```markdown
## Configuración Inicial

1. Clonar el repositorio:
   ```bash
   git clone <tu-repo>
   cd moodle-zoom-plugin
   ```

2. Copiar y configurar variables de entorno:
   ```bash
   cp .env.example .env
   nano .env  # Editar con tus credenciales
   ```

3. Levantar el proyecto:
   ```bash
   docker-compose up -d
   ./init-moodle.sh
   ```
```

---

## ✅ Lista de Verificación Final

Antes de hacer public tu repositorio:

- [ ] `.gitignore` actualizado
- [ ] No hay contraseñas en el código
- [ ] No hay tokens reales en el código
- [ ] `.env.example` creado (sin credenciales reales)
- [ ] README.md completo y actualizado
- [ ] Documentación en `/docs` completa
- [ ] Colección de Postman incluida
- [ ] Scripts ejecutables (`chmod +x *.sh`)
- [ ] LICENSE agregado (GPL v3 recomendado)
- [ ] Sin archivos de datos persistentes
- [ ] Sin backups de base de datos

---

## 📝 Notas Adicionales

### Tamaño del Repositorio
El repositorio debería pesar aproximadamente:
- **Sin datos**: ~5-10 MB
- **Con datos/volúmenes** (NO SUBIR): ~500+ MB

### Branch Strategy
Recomendado:
- `main` - Versión estable
- `develop` - Desarrollo activo
- `feature/*` - Nuevas funcionalidades

### Tags
Crear tags para versiones:
```bash
git tag -a v1.0.0 -m "Primera versión estable"
git push origin v1.0.0
```

---

## 🆘 Si Subiste Algo por Error

Si accidentalmente subiste credenciales o datos sensibles:

```bash
# Eliminar archivo del historial
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch ruta/al/archivo" \
  --prune-empty --tag-name-filter cat -- --all

# Forzar push
git push origin --force --all
git push origin --force --tags

# IMPORTANTE: Cambiar inmediatamente las credenciales expuestas
```

---

**Última actualización:** Noviembre 2025
