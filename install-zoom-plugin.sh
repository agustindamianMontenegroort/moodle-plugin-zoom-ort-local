#!/bin/bash

# Script para instalar el plugin oficial de Zoom en Moodle
# Autor: Script automatizado
# Fecha: 2025-11-16

set -e  # Detener en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Instalador del Plugin Oficial de Zoom${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Verificar que Docker esté corriendo
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker no está corriendo o no tienes permisos.${NC}"
    exit 1
fi

# Verificar que el contenedor de Moodle esté corriendo
if ! docker ps | grep -q moodle_app; then
    echo -e "${RED}Error: El contenedor 'moodle_app' no está corriendo.${NC}"
    echo -e "${YELLOW}Ejecuta primero: docker-compose up -d${NC}"
    exit 1
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
echo -e "${GREEN}✓${NC} Directorio temporal creado: $TEMP_DIR"

# Descargar el plugin oficial de Zoom
echo -e "\n${BLUE}Descargando el plugin oficial de Zoom...${NC}"
cd "$TEMP_DIR"

# Descargar la última versión estable
# Usamos moodle.org que es más confiable
echo "Descargando desde moodle.org..."
ZOOM_PLUGIN_URL="https://moodle.org/plugins/download.php/30693/mod_zoom_moodle44_2024022900.zip"
curl -L "$ZOOM_PLUGIN_URL" -o zoom-plugin.zip

# Si falla, intentar con GitHub usando git clone
if [ ! -s zoom-plugin.zip ] || [ $(stat -f%z zoom-plugin.zip 2>/dev/null || stat -c%s zoom-plugin.zip) -lt 1000 ]; then
    echo -e "${YELLOW}Descarga directa falló, intentando con git clone...${NC}"
    rm -f zoom-plugin.zip
    git clone --depth 1 https://github.com/zoom/moodle-mod_zoom.git zoom
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Plugin clonado exitosamente"
    else
        echo -e "${RED}Error al descargar el plugin.${NC}"
        echo -e "${YELLOW}Por favor, descarga manualmente desde:${NC}"
        echo -e "https://moodle.org/plugins/mod_zoom"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Plugin descargado exitosamente"

# Descomprimir el plugin (solo si se descargó un zip)
if [ -f zoom-plugin.zip ]; then
    echo -e "\n${BLUE}Descomprimiendo el plugin...${NC}"
    unzip -q zoom-plugin.zip
    
    # Renombrar la carpeta (puede ser mod_zoom, moodle-mod_zoom, etc.)
    if [ -d "zoom" ]; then
        echo -e "${GREEN}✓${NC} Plugin ya está en directorio 'zoom'"
    elif [ -d "mod_zoom" ]; then
        mv mod_zoom zoom
    else
        # Buscar cualquier carpeta que contenga zoom
        ZOOM_DIR=$(ls -d *zoom* 2>/dev/null | head -n 1)
        if [ -n "$ZOOM_DIR" ]; then
            mv "$ZOOM_DIR" zoom
        fi
    fi
    
    echo -e "${GREEN}✓${NC} Plugin descomprimido"
fi

# Verificar que tenemos el directorio zoom
if [ ! -d "zoom" ]; then
    echo -e "${RED}Error: No se pudo preparar el directorio del plugin.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copiar el plugin al contenedor
echo -e "\n${BLUE}Copiando el plugin al contenedor de Moodle...${NC}"
docker cp zoom moodle_app:/tmp/

# Verificar si ya existe el plugin en Moodle
echo -e "\n${BLUE}Verificando instalación previa...${NC}"
if docker-compose exec -T moodle test -d /var/www/html/mod/zoom; then
    echo -e "${YELLOW}⚠ El plugin ya existe en Moodle.${NC}"
    read -p "¿Deseas sobrescribirlo? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}Eliminando versión anterior...${NC}"
        docker-compose exec -T moodle rm -rf /var/www/html/mod/zoom
    else
        echo -e "${YELLOW}Instalación cancelada.${NC}"
        rm -rf "$TEMP_DIR"
        exit 0
    fi
fi

# Mover el plugin a la ubicación correcta
echo -e "${BLUE}Instalando el plugin en Moodle...${NC}"
docker-compose exec -T moodle bash -c "mv /tmp/zoom /var/www/html/mod/"

# Ajustar permisos
echo -e "${BLUE}Ajustando permisos...${NC}"
docker-compose exec -T moodle chown -R www-data:www-data /var/www/html/mod/zoom
docker-compose exec -T moodle chmod -R 755 /var/www/html/mod/zoom

echo -e "${GREEN}✓${NC} Permisos ajustados"

# Limpiar directorio temporal
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓${NC} Archivos temporales eliminados"

# Limpiar caché de Moodle
echo -e "\n${BLUE}Limpiando caché de Moodle...${NC}"
docker-compose exec -T moodle php /var/www/html/admin/cli/purge_caches.php 2>/dev/null || true
echo -e "${GREEN}✓${NC} Caché limpiado"

# Verificar la instalación
echo -e "\n${BLUE}Verificando instalación...${NC}"
if docker-compose exec -T moodle test -f /var/www/html/mod/zoom/version.php; then
    echo -e "${GREEN}✓${NC} Plugin instalado correctamente en: /var/www/html/mod/zoom"
    
    # Obtener la versión del plugin
    VERSION=$(docker-compose exec -T moodle grep "plugin->version" /var/www/html/mod/zoom/version.php | awk -F'=' '{print $2}' | tr -d ' ;' || echo "desconocida")
    echo -e "${GREEN}✓${NC} Versión del plugin: ${VERSION}"
else
    echo -e "${RED}Error: No se pudo verificar la instalación del plugin.${NC}"
    exit 1
fi

# Instrucciones finales
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}¡Instalación completada exitosamente!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}PASOS SIGUIENTES:${NC}"
echo -e "\n1. ${BLUE}Accede a Moodle:${NC}"
echo -e "   http://localhost:8080"
echo -e "\n2. ${BLUE}Inicia sesión como administrador:${NC}"
echo -e "   Usuario: ${GREEN}admin${NC}"
echo -e "   Contraseña: ${GREEN}admin123${NC}"
echo -e "\n3. ${BLUE}Ve a la página de notificaciones:${NC}"
echo -e "   Site administration → Notifications"
echo -e "\n4. ${BLUE}Actualiza la base de datos:${NC}"
echo -e "   Haz clic en '${GREEN}Upgrade Moodle database now${NC}'"
echo -e "\n5. ${BLUE}Configura las credenciales de Zoom:${NC}"
echo -e "   Site administration → Plugins → Activity modules → Zoom meeting"
echo -e "\n   ${YELLOW}Necesitarás:${NC}"
echo -e "   - Account ID"
echo -e "   - Client ID"
echo -e "   - Client Secret"
echo -e "\n   ${YELLOW}Obténlos desde:${NC}"
echo -e "   https://marketplace.zoom.us/"
echo -e "   (Crea una app tipo 'Server-to-Server OAuth')"
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Documentación del plugin:${NC}"
echo -e "https://github.com/zoom/moodle-mod_zoom"
echo -e "${BLUE}========================================${NC}"
echo ""


