#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Verificar si se ejecuta como root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${YELLOW}Este script NO debe ejecutarse como root${NC}"
    exit 1
fi

echo -e "${GREEN}=== Configuración de Node.js ===${NC}"

# Crear directorios de caché
echo -e "${BLUE}Configurando directorios de caché...${NC}"
mkdir -p ~/.npm-cache
mkdir -p ~/.yarn-cache
mkdir -p ~/.pnpm-store

# Configurar npm
echo -e "${BLUE}Configurando npm...${NC}"
npm config set cache ~/.npm-cache
npm config set progress false
npm config set audit false
npm config set fund false
npm config set maxsockets 8
npm config set registry https://registry.npmjs.org/
npm config set fetch-retries 3
npm config set fetch-retry-mintimeout 5000
npm config set fetch-retry-maxtimeout 60000
npm config set cache-min 3600
npm config set scripts-prepend-node-path true

# Configurar yarn
echo -e "${BLUE}Configurando yarn...${NC}"
yarn config set cache-folder ~/.yarn-cache
yarn config set network-timeout 300000
yarn config set --home enableTelemetry 0

# Configurar pnpm
echo -e "${BLUE}Configurando pnpm...${NC}"
pnpm config set store-dir ~/.pnpm-store
pnpm config set cache-dir ~/.pnpm-cache
pnpm config set registry https://registry.npmjs.org/

# Habilitar corepack para gestión de package managers
echo -e "${BLUE}Habilitando corepack...${NC}"
corepack enable

# Configurar variables de entorno
echo -e "${BLUE}Configurando variables de entorno...${NC}"
cat << EOF >> ~/.bashrc

# Node.js environment
export NODE_ENV=development
export NODE_OPTIONS="--max-old-space-size=8192 --max-http-header-size=16384"
export NODE_EXTRA_CA_CERTS=~/.node/ca.pem

# NPM configuration
export NPM_CONFIG_CACHE=~/.npm-cache
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org/
export NPM_CONFIG_PROGRESS=false
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false

# Yarn configuration
export YARN_CACHE_FOLDER=~/.yarn-cache
export YARN_ENABLE_TELEMETRY=0

# PNPM configuration
export PNPM_HOME=~/.pnpm
export PATH="\$PNPM_HOME:\$PATH"
EOF

# Crear archivo de configuración para desarrollo
echo -e "${BLUE}Creando configuración de desarrollo...${NC}"
mkdir -p ~/.node/config
cat << EOF > ~/.node/config/development.json
{
  "maxWorkers": 4,
  "watchOptions": {
    "followSymlinks": false,
    "ignored": [
      "**/node_modules/**",
      "**/dist/**",
      "**/coverage/**",
      "**/.git/**"
    ]
  },
  "resolver": {
    "cachedFs": true,
    "cache": true
  }
}
EOF

echo -e "${GREEN}=== Configuración de Node.js completada ===${NC}"
echo "Se han realizado las siguientes configuraciones:"
echo "  - Configurados directorios de caché"
echo "  - Optimizada configuración de npm"
echo "  - Optimizada configuración de yarn"
echo "  - Configurado pnpm"
echo "  - Habilitado corepack"
echo "  - Configuradas variables de entorno"
echo "  - Creada configuración de desarrollo"
echo
echo -e "${YELLOW}Para aplicar los cambios, ejecuta:${NC}"
echo "source ~/.bashrc"