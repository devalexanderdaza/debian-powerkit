#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Archivos de configuración
UDEV_RULE_FILE="/etc/udev/rules.d/60-nvme-optimization.rules"
SYSCTL_FILE="/etc/sysctl.d/99-disk-optimizations.conf"

# Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Este script necesita privilegios de administrador.${NC}"
    echo "Por favor, ejecútalo con 'sudo ./optimize_io_scheduler.sh'"
    exit 1
fi

echo -e "${GREEN}=== Optimización de I/O para SSD NVMe ===${NC}"
echo "Optimizado para KBG40ZNS256G NVMe KIOXIA"

# Verificar el disco NVMe
nvme_disk=$(lsblk -d -o NAME,MODEL | grep 'NVMe' | head -n 1 | awk '{print $1}')
if [ -z "$nvme_disk" ]; then
    echo -e "${YELLOW}No se encontró un disco NVMe. Abortando.${NC}"
    exit 1
fi

# Backup de archivos importantes
echo -e "${BLUE}Creando backups...${NC}"
cp /etc/fstab /etc/fstab.backup
cp /etc/sysctl.conf /etc/sysctl.conf.backup

# Configurar optimizaciones del kernel para NVMe
echo -e "${BLUE}Configurando optimizaciones del kernel...${NC}"
cat << EOF > "$SYSCTL_FILE"
# Optimizar el subsistema de I/O
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 1500

# Optimizar el planificador de I/O
kernel.io_delay_type = 0

# Optimizar el cache de disco
vm.vfs_cache_pressure = 50
vm.laptop_mode = 5

# Optimizar el rendimiento de NVMe
dev.nvme.poll_queues = 0
dev.nvme.max_retries = 5
EOF

# Configurar reglas udev para NVMe
echo -e "${BLUE}Configurando reglas udev para NVMe...${NC}"
cat << EOF > "$UDEV_RULE_FILE"
# Optimizaciones para NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/read_ahead_kb}="2048"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/nr_requests}="2048"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/wbt_lat_usec}="0"
EOF

# Optimizar opciones de montaje en fstab
echo -e "${BLUE}Optimizando opciones de montaje...${NC}"
root_uuid=$(findmnt -n -o UUID /)
efi_uuid=$(findmnt -n -o UUID /boot/efi)

# Crear nuevo fstab con optimizaciones
cat << EOF > /etc/fstab.new
# Particiones optimizadas para NVMe
UUID=$root_uuid / ext4 defaults,noatime,nodiratime,discard=async 0 1
UUID=$efi_uuid /boot/efi vfat defaults,noatime 0 1

# Temp directories en tmpfs
tmpfs /tmp tmpfs defaults,noatime,mode=1777,size=4G 0 0
EOF

# Verificar y aplicar el nuevo fstab
if diff -q /etc/fstab.new /etc/fstab >/dev/null; then
    echo "fstab ya está optimizado"
    rm /etc/fstab.new
else
    mv /etc/fstab.new /etc/fstab
fi

# Aplicar optimizaciones inmediatas
echo -e "${BLUE}Aplicando optimizaciones...${NC}"
sysctl -p "$SYSCTL_FILE"
udevadm control --reload-rules
udevadm trigger --type=devices --action=change

echo -e "${BLUE}Configurando atributos de disco...${NC}"
# Configurar atributos de disco NVMe
echo "none" > "/sys/block/$nvme_disk/queue/scheduler"
echo "2048" > "/sys/block/$nvme_disk/queue/read_ahead_kb"
echo "2048" > "/sys/block/$nvme_disk/queue/nr_requests"

echo -e "${GREEN}=== Optimización completada ===${NC}"
echo "Se han realizado las siguientes optimizaciones:"
echo "  - Configurado planificador a 'none' para mejor rendimiento NVMe"
echo "  - Optimizado parámetros del kernel para SSD"
echo "  - Ajustado opciones de montaje para mejor rendimiento"
echo "  - Configurado cache y writeback para SSD"
echo "  - Habilitado TRIM asíncrono"
echo
echo -e "${YELLOW}IMPORTANTE: Reinicia el sistema para aplicar todos los cambios.${NC}"