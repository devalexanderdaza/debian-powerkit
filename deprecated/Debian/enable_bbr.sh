#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Archivos de configuración
SYSCTL_NET_FILE="/etc/sysctl.d/99-network-optimization.conf"

# Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}Este script necesita privilegios de administrador.${NC}"
    echo "Por favor, ejecútalo con 'sudo ./optimize_network.sh'"
    exit 1
fi

echo -e "${GREEN}=== Optimización de Red para Desarrollo ===${NC}"

# Verificar el estado actual de BBR
current_cc=$(sysctl -n net.ipv4.tcp_congestion_control)
echo -e "${BLUE}Estado actual del control de congestión: $current_cc${NC}"

# Crear archivo de configuración con optimizaciones
echo -e "${BLUE}Configurando optimizaciones de red...${NC}"
cat << EOF > "$SYSCTL_NET_FILE"
# Habilitar BBR
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Optimizar el buffer de red
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 1048576 16777216
net.ipv4.tcp_wmem = 4096 1048576 16777216

# Optimizar conexiones TCP
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Optimizar el backlog para desarrollo
net.core.somaxconn = 65536
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_syn_backlog = 8192

# Optimizar el rendimiento de red
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_low_latency = 1

# Optimizar el reuso de puertos
net.ipv4.tcp_tw_reuse = 1

# Optimizar el buffer de memoria para aplicaciones de red
net.ipv4.tcp_mem = 786432 1048576 1572864

# Optimizar el manejo de conexiones
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_syncookies = 1

# Optimizar para desarrollo web
net.ipv4.ip_local_port_range = 1024 65535
EOF

# Aplicar cambios
echo -e "${BLUE}Aplicando cambios...${NC}"
sysctl -p "$SYSCTL_NET_FILE"

# Verificar el estado final
final_cc=$(sysctl -n net.ipv4.tcp_congestion_control)
echo
echo -e "${GREEN}=== Optimización completada ===${NC}"
echo "Se han realizado las siguientes optimizaciones:"
echo "  - Control de congestión: $final_cc"
echo "  - Optimizado buffers de red para desarrollo"
echo "  - Configurado TCP para baja latencia"
echo "  - Optimizado keepalive para desarrollo"
echo "  - Ajustado backlog para mejor rendimiento"
echo "  - Optimizado reuso de puertos"
echo
echo -e "${YELLOW}Los cambios han sido aplicados y son permanentes.${NC}"
echo -e "${YELLOW}No es necesario reiniciar, pero puedes hacerlo si lo deseas.${NC}"