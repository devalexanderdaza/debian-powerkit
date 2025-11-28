#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${GREEN}=== Optimización de Memoria para Desarrollo ===${NC}"
echo "Optimizado para sistema con 16GB RAM"

# Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Este script necesita privilegios de administrador.${NC}"
    echo "Por favor, ejecútalo con 'sudo ./optimize_memory.sh'"
    exit 1
fi

# Backup del archivo sysctl.conf
echo -e "${BLUE}Creando backup de sysctl.conf...${NC}"
cp /etc/sysctl.conf /etc/sysctl.conf.backup

# Configurar parámetros del kernel para memoria
echo -e "${BLUE}Configurando parámetros de memoria...${NC}"
cat << EOF > /etc/sysctl.d/99-memory-optimizations.conf
# Optimizar uso de swap
vm.swappiness = 10
vm.vfs_cache_pressure = 50

# Optimizar memoria para desarrollo
vm.dirty_background_ratio = 5
vm.dirty_ratio = 15
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 1500

# Configurar THP para desarrollo
vm.transparent_hugepage = madvise

# Optimizar OOM killer para desarrollo
vm.oom_kill_allocating_task = 1
vm.panic_on_oom = 0
vm.overcommit_memory = 0
vm.overcommit_ratio = 50

# Optimizar compresión de memoria
vm.compaction_proactiveness = 1
vm.page_cluster = 0
EOF

# Configurar ZRAM
echo -e "${BLUE}Configurando ZRAM...${NC}"
apt update
apt install -y zram-tools

# Configurar ZRAM para 16GB de RAM (8GB de ZRAM)
cat << EOF > /etc/default/zramswap
# Compression algorithm (lz4 es más rápido que lzo)
ALGO=lz4

# Porcentaje de RAM a usar para ZRAM (50% = 8GB en tu sistema)
PERCENT=50

# Prioridad de swap (mayor que el archivo de swap)
PRIORITY=100

# Número de streams de compresión (igual al número de CPU threads)
STREAMS=8
EOF

# Instalar earlyoom con configuración optimizada
echo -e "${BLUE}Instalando y configurando earlyoom...${NC}"
apt install -y earlyoom

mkdir -p /etc/systemd/system/earlyoom.service.d/
cat << EOF > /etc/systemd/system/earlyoom.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/earlyoom -m 4 -s 5 -r 60 \
    --avoid '(^|/)(init|systemd|kthreadd|ksoftirqd|migration|rcu_|watchdog)$' \
    --prefer '(^|/)(java|node|python|docker|code|chrome|firefox|electron)$'
EOF

# Crear archivo de swap de emergencia (4GB)
echo -e "${BLUE}Configurando swap de emergencia...${NC}"
if [ ! -f /swapfile ]; then
    echo "Creando archivo de swap de 4GB..."
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    
    # Verificar si la entrada ya existe en fstab
    if ! grep -q "/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw,pri=10 0 0' >> /etc/fstab
    fi
fi

# Habilitar servicios
echo -e "${BLUE}Habilitando servicios...${NC}"
systemctl enable earlyoom
systemctl enable zramswap

# Aplicar cambios
echo -e "${BLUE}Aplicando cambios...${NC}"
sysctl -p /etc/sysctl.d/99-memory-optimizations.conf

echo -e "${GREEN}=== Configuración de memoria completada ===${NC}"
echo -e "Optimizaciones realizadas:"
echo "  - Configurado swappiness a 10 para reducir uso de swap"
echo "  - Configurado ZRAM a 8GB (50% de RAM) con algoritmo lz4"
echo "  - Instalado earlyoom con configuración para desarrollo"
echo "  - Creado swap de emergencia de 4GB"
echo "  - Optimizados parámetros del kernel para desarrollo"
echo
echo -e "${YELLOW}Por favor, reinicia el sistema para aplicar todos los cambios.${NC}"