#!/bin/bash

# Script para instalar el plugin oficial de Zoom en Moodle
# El plugin debe ser descargado previamente desde: https://moodle.org/plugins/mod_zoom

set -e

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

echo -e "${YELLOW}📥 DESCARGAR PLUGIN OFICIAL${NC}"
echo ""
echo "Por favor, descarga el plugin oficial de Zoom desde:"
echo -e "${GREEN}https://moodle.org/plugins/mod_zoom${NC}"
echo ""
echo "Pasos:"
echo "1. Ve a la página web"
echo "2. Selecciona tu versión de Moodle"
echo "3. Descarga el archivo ZIP"
echo "4. Descomprime el archivo"
echo "5. Coloca la carpeta 'zoom' en la raíz de este proyecto"
echo ""
read -p "¿Ya descargaste y descomprimiste el plugin? (s/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Descarga el plugin primero y vuelve a ejecutar este script.${NC}"
    exit 0
fi

# Buscar la carpeta del plugin
ZOOM_DIR=""

# Buscar en la raíz del proyecto
if [ -d "zoom" ]; then
    ZOOM_DIR="zoom"
elif [ -d "mod_zoom" ]; then
    ZOOM_DIR="mod_zoom"
else
    # Buscar carpetas que contengan zoom
    ZOOM_DIR=$(find . -maxdepth 2 -type d -name "*zoom*" 2>/dev/null | head -n 1)
fi

if [ -z "$ZOOM_DIR" ]; then
    echo -e "${RED}Error: No se encontró la carpeta del plugin de Zoom.${NC}"
    echo -e "${YELLOW}Asegúrate de que la carpeta 'zoom' esté en la raíz del proyecto.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Plugin encontrado en: $ZOOM_DIR"
echo ""

# Verificar que tenga el archivo version.php
if [ ! -f "$ZOOM_DIR/version.php" ]; then
    echo -e "${RED}Error: La carpeta no parece ser un plugin válido de Zoom.${NC}"
    echo -e "${YELLOW}Verifica que sea la carpeta correcta.${NC}"
    exit 1
fi

# Copiar el plugin al contenedor
echo -e "${BLUE}Copiando el plugin al contenedor de Moodle...${NC}"
docker cp "$ZOOM_DIR" moodle_app:/tmp/zoom_temp

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
        docker-compose exec -T moodle rm -rf /tmp/zoom_temp
        exit 0
    fi
fi

# Mover el plugin a la ubicación correcta
echo -e "${BLUE}Instalando el plugin en Moodle...${NC}"
docker-compose exec -T moodle bash -c "mv /tmp/zoom_temp /var/www/html/mod/zoom"

# Ajustar permisos
echo -e "${BLUE}Ajustando permisos...${NC}"
docker-compose exec -T moodle chown -R www-data:www-data /var/www/html/mod/zoom
docker-compose exec -T moodle chmod -R 755 /var/www/html/mod/zoom

echo -e "${GREEN}✓${NC} Permisos ajustados"

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
echo -e "   ${GREEN}https://marketplace.zoom.us/${NC}"
echo -e "   (Crea una app tipo 'Server-to-Server OAuth')"
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Documentación completa:${NC}"
echo -e "Ver archivo: ${GREEN}GUIA_ZOOM_OFICIAL.md${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
