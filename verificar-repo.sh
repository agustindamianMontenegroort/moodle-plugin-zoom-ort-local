#!/bin/bash

# Script para verificar que el repositorio está listo para subir

set -e

echo "🔍 Verificando archivos para el repositorio..."
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar archivos críticos
echo "📋 Verificando archivos críticos..."

CRITICAL_FILES=(
    "README.md"
    ".gitignore"
    "docker-compose.yml"
    "Dockerfile.moodle"
    "init-moodle.sh"
    "plugins/zoommeetingid/version.php"
    "API_DOCUMENTATION.md"
    "Zoom_Meeting_API.postman_collection.json"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$file" ] || [ -d "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file - FALTA"
    fi
done

echo ""
echo "🔒 Buscando archivos sensibles (NO deberían existir)..."

# Buscar archivos sensibles
SENSITIVE_FOUND=0

if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠${NC} .env encontrado - NO DEBERÍA SUBIRSE"
    SENSITIVE_FOUND=1
fi

if [ -d "moodle_data" ]; then
    echo -e "${YELLOW}⚠${NC} moodle_data/ encontrado - NO DEBERÍA SUBIRSE"
    SENSITIVE_FOUND=1
fi

if [ -d "db_data" ]; then
    echo -e "${YELLOW}⚠${NC} db_data/ encontrado - NO DEBERÍA SUBIRSE"
    SENSITIVE_FOUND=1
fi

# Buscar contraseñas en archivos
echo ""
echo "🔐 Buscando posibles contraseñas en el código..."
PASSWORDS=$(grep -r "password.*=.*['\"]" --include="*.php" --include="*.sh" plugins/ 2>/dev/null | grep -v "PARAM\|placeholder\|example\|Password:" | head -5)
if [ -n "$PASSWORDS" ]; then
    echo -e "${YELLOW}⚠${NC} Posibles contraseñas encontradas:"
    echo "$PASSWORDS"
    SENSITIVE_FOUND=1
else
    echo -e "${GREEN}✓${NC} No se encontraron contraseñas hardcodeadas"
fi

echo ""
echo "📦 Archivos que se subirán al repositorio:"
echo ""

# Listar archivos que se subirán
git add -n . 2>/dev/null | head -20 || echo "Ejecuta 'git init' si aún no has inicializado el repositorio"

echo ""
if [ $SENSITIVE_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ Todo parece estar listo para subir al repositorio${NC}"
else
    echo -e "${RED}⚠️  ADVERTENCIA: Se encontraron archivos sensibles. Revisa antes de subir.${NC}"
fi

echo ""
echo "📝 Comandos sugeridos:"
echo ""
echo "# 1. Inicializar Git (si no está inicializado)"
echo "git init"
echo ""
echo "# 2. Agregar archivos"
echo "git add ."
echo ""
echo "# 3. Ver qué se va a subir"
echo "git status"
echo ""
echo "# 4. Commit"
echo "git commit -m 'Initial commit: Moodle + Zoom + API REST'"
echo ""
echo "# 5. Conectar con repositorio remoto"
echo "git remote add origin <URL_DE_TU_REPO>"
echo ""
echo "# 6. Subir al repositorio"
echo "git push -u origin main"
echo ""
