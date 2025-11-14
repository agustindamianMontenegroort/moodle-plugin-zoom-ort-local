#!/bin/bash

# Script para iniciar la aplicación Moodle con Docker

echo "🚀 Iniciando aplicación Moodle..."

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Ejecuta: ./install-docker.sh"
    exit 1
fi

# Verificar si docker-compose está disponible
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose no está disponible"
    exit 1
fi

# Navegar al directorio del proyecto
cd "$(dirname "$0")"

# Iniciar contenedores
echo "📦 Iniciando contenedores..."
$COMPOSE_CMD up -d

# Esperar a que los contenedores estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 5

# Verificar estado
echo "📊 Estado de los contenedores:"
$COMPOSE_CMD ps

echo ""
echo "✅ Aplicación iniciada!"
echo ""
echo "🌐 Accede a Moodle en: http://localhost:8080"
echo "   Usuario: admin"
echo "   Contraseña: admin123"
echo ""
echo "📝 Si es la primera vez, ejecuta: ./init-moodle.sh"

