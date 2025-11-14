#!/bin/bash

# Script para instalar Docker y Docker Compose
# Este script requiere permisos de administrador

echo "🚀 Instalando Docker y Docker Compose..."

# Actualizar el sistema
echo "📦 Actualizando el sistema..."
sudo apt update

# Instalar Docker
echo "🐳 Instalando Docker..."
sudo apt install -y docker.io docker-compose

# Agregar usuario al grupo docker
echo "👤 Agregando usuario al grupo docker..."
sudo usermod -aG docker $USER

# Iniciar y habilitar Docker
echo "▶️  Iniciando servicio Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verificar instalación
echo "✅ Verificando instalación..."
docker --version
docker-compose --version

echo ""
echo "✅ Docker instalado correctamente!"
echo ""
echo "⚠️  IMPORTANTE: Necesitas cerrar sesión y volver a iniciar sesión"
echo "   para que los cambios de grupo surtan efecto."
echo ""
echo "   O ejecuta: newgrp docker"
echo ""
echo "Luego ejecuta: ./start-app.sh"

