#!/bin/bash

# =================================================================================================
#
#    ██████╗ ██████╗ ████████╗██╗███╗   ███╗██╗███████╗███████╗██╗ ██████╗ ███╗   ██╗
#   ██╔═══██╗██╔══██╗╚══██╔══╝██║████╗ ████║██║██╔════╝██╔════╝██║██╔═══██╗████╗  ██║
#   ██║   ██║██████╔╝   ██║   ██║██╔████╔██║██║█████╗  ███████╗██║██║   ██║██╔██╗ ██║
#   ██║   ██║██╔═══╝    ██║   ██║██║╚██╔╝██║██║██╔══╝  ╚════██║██║██║   ██║██║╚██╗██║
#   ╚██████╔╝██║        ██║   ██║██║ ╚═╝ ██║██║███████╗███████║██║╚██████╔╝██║ ╚████║
#    ╚═════╝ ╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚═╝╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝
#
#   SCRIPT DE OPTIMIZACIÓN INTEGRAL PARA SISTEMAS DEBIAN (VERSIÓN INTERACTIVA)
#
#   Autor: Tu Nombre/Alias
#   Versión: 3.0
#
#   Este script aplica una serie de optimizaciones de rendimiento para CPU,
#   memoria, I/O y red. Ahora incluye un menú interactivo, creación de respaldos
#   y una lógica mejorada para evitar configuraciones duplicadas.
#
# =================================================================================================

# --- Configuración y Funciones Auxiliares ---

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Función para crear una copia de seguridad de un archivo si no existe ya una.
backup_file() {
    local file="$1"
    local backup_path="${file}.bak-$(date +%Y%m%d-%H%M%S)"
    if [ -f "$file" ]; then
        log_info "Creando copia de seguridad de '$file' en '$backup_path'..."
        cp "$file" "$backup_path"
    else
        log_warn "El archivo '$file' no existe, no se puede crear copia de seguridad."
    fi
}

# Función para establecer un parámetro en un archivo de configuración (como sysctl.conf)
# Evita duplicados: si el parámetro existe, lo actualiza; si no, lo añade.
set_config_param() {
    local file="$1"
    local param_name="$2"
    local param_value="$3"
    local line="${param_name}=${param_value}"

    # Escapar caracteres especiales para sed
    local escaped_line=$(printf '%s\n' "$line" | sed -e 's/[\/&]/\\&/g')
    local escaped_param_name=$(printf '%s\n' "$param_name" | sed -e 's/[\/&]/\\&/g')

    if grep -q "^${escaped_param_name}=" "$file"; then
        # El parámetro ya existe, reemplazar la línea
        log_info "Actualizando parámetro '$param_name' en '$file'."
        sed -i "s/^${escaped_param_name}=.*/${escaped_line}/" "$file"
    else
        # El parámetro no existe, añadirlo al final
        log_info "Añadiendo parámetro '$param_name' a '$file'."
        echo "$line" >> "$file"
    fi
}


# --- Verificación Inicial ---

if [[ $EUID -ne 0 ]]; then
   log_error "Este script debe ser ejecutado como root. Usa: sudo ./optimize.sh"
fi

# Verificar si 'dialog' está instalado
if ! command -v dialog &> /dev/null; then
    log_warn "'dialog' no está instalado. Es necesario para la interfaz interactiva."
    apt-get update && apt-get install -y dialog
fi


# --- Módulos de Optimización ---

# 1. Optimizador de CPU
optimize_cpu() {
    log_info "Configurando el gobernador de la CPU a 'performance'..."
    if ! command -v cpupower &> /dev/null; then
        log_warn "cpupower no encontrado. Instalando linux-cpupower..."
        apt-get update && apt-get install -y linux-cpupower
    fi
    
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu"
    done
    
    # Hacer el cambio persistente con un servicio systemd
    local service_file="/etc/systemd/system/cpupower.service"
    log_info "Creando servicio systemd para persistir el gobernador de CPU..."
    cat > "$service_file" <<EOL
[Unit]
Description=Set CPU governor to performance

[Service]
Type=oneshot
ExecStart=/bin/sh -c "for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo 'performance' > \$cpu; done"

[Install]
WantedBy=multi-user.target
EOL
    systemctl enable --now cpupower.service
    log_info "Gobernador de CPU configurado y servicio systemd creado."
}

# 2. Optimización de Memoria y Swappiness
optimize_memory() {
    log_info "Ajustando la configuración de memoria virtual (sysctl)..."
    local sysctl_conf="/etc/sysctl.conf"
    
    backup_file "$sysctl_conf"
    
    # Reducir la tendencia a usar swap
    set_config_param "$sysctl_conf" "vm.swappiness" "10"
    
    # Mejorar la gestión de caché
    set_config_param "$sysctl_conf" "vm.vfs_cache_pressure" "50"
    
    # Aplicar cambios
    sysctl -p
    log_info "Parámetros de memoria virtual optimizados."
}

# 3. Configuración de ZRAM
setup_zram() {
    if command -v zramctl &> /dev/null; then
        log_info "zram-tools ya está instalado. Omitiendo instalación."
    else
        log_info "Instalando zram-tools..."
        apt-get update && apt-get install -y zram-tools
    fi
    
    local zram_conf="/etc/default/zramswap"
    log_info "Configurando ZRAM..."
    backup_file "$zram_conf"
    
    # Configurar zram para usar el 50% de la RAM y el algoritmo lz4
    cat > "$zram_conf" <<EOL
# Configuration for zram-tools
# ALGO can be lzo, lz4, lzo-rle, zstd. lz4 is fast.
ALGO=lz4

# PERCENT is the percentage of RAM to use for zram
PERCENT=50
EOL
    
    systemctl restart zramswap.service
    log_info "ZRAM configurado y activado."
}

# 4. Optimización de Red (BBR)
enable_bbr() {
    log_info "Habilitando el algoritmo de control de congestión BBR..."
    local sysctl_conf="/etc/sysctl.conf"
    
    # No es necesario un nuevo backup si optimize_memory ya lo hizo
    if [ ! -f "${sysctl_conf}.bak-$(date +%Y%m%d)"* ]; then
        backup_file "$sysctl_conf"
    fi
    
    set_config_param "$sysctl_conf" "net.core.default_qdisc" "fq"
    set_config_param "$sysctl_conf" "net.ipv4.tcp_congestion_control" "bbr"
    
    sysctl -p
    log_info "BBR habilitado. El rendimiento de la red debería mejorar."
}

# 5. Aumentar el límite de inotify watches
increase_inotify() {
    log_info "Aumentando el límite de inotify watches para mejorar la respuesta de IDEs..."
    local sysctl_conf="/etc/sysctl.conf"

    # No es necesario un nuevo backup si ya se hizo
    if [ ! -f "${sysctl_conf}.bak-$(date +%Y%m%d)"* ]; then
        backup_file "$sysctl_conf"
    fi
    
    set_config_param "$sysctl_conf" "fs.inotify.max_user_watches" "524288"
    
    sysctl -p
    log_info "Límite de inotify aumentado."
}

# 6. Instalar y configurar Preload
install_preload() {
    if dpkg -l | grep -q preload; then
        log_info "Preload ya está instalado. Omitiendo."
        return
    fi
    
    log_info "Instalando Preload para acelerar el lanzamiento de aplicaciones..."
    apt-get update && apt-get install -y preload
    log_info "Preload instalado."
}

# --- Ejecución Principal ---

main() {
    log_info "Inicio del script de optimización del sistema."
    
    OPTIONS=(
        1 "Optimizar gobernador de CPU (a 'performance')" on
        2 "Optimizar gestión de memoria y swappiness" on
        3 "Configurar ZRAM para compresión de RAM" on
        4 "Habilitar TCP BBR para mejorar la red" on
        5 "Aumentar límite de inotify (para IDEs y watchers)" on
        6 "Instalar Preload para acelerar apps" on
    )

    CHOICES=$(dialog --clear \
                    --backtitle "Asistente de Optimización del Sistema" \
                    --title "Selección de Optimizaciones" \
                    --checklist "Usa la barra espaciadora para seleccionar/deseleccionar las optimizaciones a aplicar." \
                    20 75 6 \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

    clear

    if [ -z "$CHOICES" ]; then
        log_warn "No se seleccionó ninguna optimización. Saliendo."
        exit 0
    fi

    log_info "Aplicando optimizaciones seleccionadas: $CHOICES"

    if [[ $CHOICES == *"1"* ]]; then optimize_cpu; fi
    if [[ $CHOICES == *"2"* ]]; then optimize_memory; fi
    if [[ $CHOICES == *"3"* ]]; then setup_zram; fi
    if [[ $CHOICES == *"4"* ]]; then enable_bbr; fi
    if [[ $CHOICES == *"5"* ]]; then increase_inotify; fi
    if [[ $CHOICES == *"6"* ]]; then install_preload; fi
    
    log_info "¡Optimización completada!"
    log_info "Se recomienda reiniciar el sistema para que todos los cambios surtan efecto."
    log_info "Se han creado copias de seguridad de los archivos modificados con la extensión .bak-FECHA."
}

# Iniciar la ejecución
main
