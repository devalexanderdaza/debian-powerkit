#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Este script necesita privilegios de administrador.${NC}"
    echo "Por favor, ejecútalo con 'sudo ./configure_dev_env.sh'"
    exit 1
fi

echo -e "${GREEN}=== Configuración de Entorno de Desarrollo ===${NC}"
echo "Optimizado para Intel Core i7-10610U con 16GB RAM"

# Configurar límites del sistema para desarrollo
echo -e "${BLUE}Configurando límites del sistema...${NC}"
cat << EOF > /etc/security/limits.d/99-development.conf
# Aumentar límites para desarrollo
*         soft    nofile          524288
*         hard    nofile          524288
*         soft    nproc           32768
*         hard    nproc           32768
# Límites específicos para desarrollo
*         soft    memlock         unlimited
*         hard    memlock         unlimited
EOF

# Configurar inotify para IDEs
echo -e "${BLUE}Configurando inotify para IDEs...${NC}"
cat << EOF > /etc/sysctl.d/99-inotify.conf
# Aumentar límites de inotify para IDEs
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.inotify.max_queued_events = 32768
EOF

# Configurar ccache
echo -e "${BLUE}Configurando ccache...${NC}"
mkdir -p /etc/ccache
cat << EOF > /etc/ccache/ccache.conf
# Configuración general
max_size = 20G
compression = true
compression_level = 1
compiler_check = content
cache_dir = /var/cache/ccache
temporary_dir = /var/tmp/ccache
umask = 002
hash_dir = true
stats = true

# Optimizaciones de caché
sloppiness = file_macro,time_macros,include_file_mtime,include_file_ctime
EOF

# Crear directorio de caché y establecer permisos
mkdir -p /var/cache/ccache
chown -R root:developers /var/cache/ccache 2>/dev/null || chown -R root:sudo /var/cache/ccache
chmod 2775 /var/cache/ccache

# Configurar variables de entorno globales
echo -e "${BLUE}Configurando variables de entorno...${NC}"
cat << EOF > /etc/profile.d/development.sh
# Path
export PATH=\$HOME/.local/bin:\$PATH

# Node.js
export NODE_OPTIONS="--max-old-space-size=8192"

# Python
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1
export PIP_NO_CACHE_DIR=0

# Ccache
export CCACHE_DIR=/var/cache/ccache
export CCACHE_UMASK=002
export CC="ccache gcc"
export CXX="ccache g++"

# General development
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=vim
EOF

# Configurar Git globalmente
echo -e "${BLUE}Configurando Git...${NC}"
git config --system core.compression 9
git config --system core.bigFileThreshold 1m
git config --system pack.window 0
git config --system pack.threads 4
git config --system core.preloadIndex true
git config --system core.fsmonitor true
git config --system core.untrackedCache true
git config --system http.postBuffer 524288000

# Aplicar cambios
echo -e "${BLUE}Aplicando cambios...${NC}"
sysctl -p /etc/sysctl.d/99-inotify.conf

echo -e "${GREEN}=== Configuración completada ===${NC}"
echo "Se han realizado las siguientes optimizaciones:"
echo "  - Configurados límites del sistema para desarrollo"
echo "  - Optimizado inotify para IDEs"
echo "  - Configurado ccache con 20GB de caché"
echo "  - Configuradas variables de entorno para desarrollo"
echo "  - Optimizado Git para mejor rendimiento"
echo
echo -e "${YELLOW}Notas importantes:${NC}"
echo "1. Los cambios en los límites del sistema requieren reinicio"
echo "2. Algunas configuraciones de Git pueden necesitar ajustes según tus necesidades"
echo "3. El caché de ccache se construirá con el tiempo"
echo
echo -e "Para aplicar todos los cambios, por favor reinicia el sistema."