#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # Sin color

# Nombre del servicio de Systemd
SERVICE_NAME="cpu_optimization"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# --- Funciones ---

# Verifica si se ejecuta como root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}Este script necesita privilegios de administrador para funcionar.${NC}"
        echo "Por favor, ejecútalo con 'sudo ./optimize_cpu.sh'"
        exit 1
    fi
}

# Comprueba el estado actual del gobernador y la configuración
check_status() {
    echo -e "${BLUE}Verificando estado actual de la CPU...${NC}"
    local current_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    local current_energy_perf=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "N/A")
    local intel_pstate=$(cat /sys/devices/system/cpu/intel_pstate/status 2>/dev/null || echo "N/A")
    
    echo -e "Estado actual:"
    echo "- Gobernador CPU: $current_governor"
    echo "- Preferencia energía/rendimiento: $current_energy_perf"
    echo "- Intel P-State: $intel_pstate"
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "✓ ${GREEN}Optimización de CPU está ACTIVA y configurada para iniciar con el sistema.${NC}"
        return 0 # Activo
    else
        echo -e "○ ${YELLOW}Optimización de CPU está INACTIVA.${NC}"
        return 1 # Inactivo
    fi
}

# Aplica la optimización de CPU
apply_changes() {
    echo -e "${BLUE}Aplicando optimización de CPU...${NC}"
    
    # 1. Crear el script de optimización
    local SCRIPT_PATH="/usr/local/bin/optimize_cpu_settings"
    echo "Creando script en $SCRIPT_PATH..."
    cat << EOF > "$SCRIPT_PATH"
#!/bin/bash

# Configurar Intel P-State si está disponible
if [ -d "/sys/devices/system/cpu/intel_pstate" ]; then
    echo "active" > /sys/devices/system/cpu/intel_pstate/status 2>/dev/null
fi

# Configurar el gobernador para balance entre rendimiento y eficiencia
echo "schedutil" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Optimizar la preferencia energía/rendimiento para desarrollo
echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference 2>/dev/null

# Configurar la frecuencia mínima al 20% de la máxima para mejor respuesta
min_freq=\$(( \$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) / 5 ))
echo "\$min_freq" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq

# Optimizar el planificador de CPU para cargas de trabajo de desarrollo
echo "1" > /proc/sys/kernel/sched_autogroup_enabled
echo "0" > /proc/sys/kernel/sched_child_runs_first

# Configurar el modo turbo para un mejor rendimiento sostenido
echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null
EOF
    chmod +x "$SCRIPT_PATH"

    # 2. Crear el servicio de systemd
    echo "Creando servicio de systemd en $SERVICE_FILE..."
    cat << EOF > "$SERVICE_FILE"
[Unit]
Description=Optimizar CPU para desarrollo
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    # 3. Recargar systemd y habilitar el servicio
    echo "Recargando y habilitando el servicio..."
    systemctl daemon-reload
    systemctl enable --now "$SERVICE_NAME"

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${GREEN}¡Optimización de CPU activada exitosamente!${NC}"
        check_status
    else
        echo -e "${YELLOW}Hubo un error al activar el servicio.${NC}"
    fi
}

# Revierte los cambios
rollback_changes() {
    echo -e "${BLUE}Revirtiendo a la configuración por defecto...${NC}"
    
    if ! systemctl is-active --quiet "$SERVICE_NAME"; then
        echo -e "${YELLOW}El servicio no está activo. No hay nada que revertir.${NC}"
        return
    fi

    # 1. Detener y deshabilitar el servicio
    systemctl disable --now "$SERVICE_NAME"

    # 2. Eliminar archivos
    rm -f "$SERVICE_FILE"
    rm -f "/usr/local/bin/optimize_cpu_settings"

    # 3. Recargar systemd
    systemctl daemon-reload

    # 4. Restaurar configuración por defecto
    echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "balance_performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference 2>/dev/null
    
    echo -e "${GREEN}¡Configuración restaurada a valores por defecto!${NC}"
    check_status
}

# --- Menú Principal ---

check_root
echo -e "${GREEN}=== Optimización de CPU para Desarrollo ===${NC}"
echo "Optimizado para Intel Core i7-10610U"
echo "Este script configura tu CPU para un balance óptimo entre rendimiento y eficiencia energética."
echo

check_status
current_status=$?
echo

echo -e "${YELLOW}¿Qué deseas hacer?${NC}"
if [ $current_status -eq 1 ]; then
    options=("Activar optimización de CPU" "Salir")
    select opt in "${options[@]}"; do
        case $opt in
            "Activar optimización de CPU")
                apply_changes
                break
                ;;
            "Salir")
                break
                ;;
            *) echo "Opción inválida";;
        esac
    done
else
    options=("Desactivar optimización (Rollback)" "Reinstalar optimización" "Salir")
    select opt in "${options[@]}"; do
        case $opt in
            "Desactivar optimización (Rollback)")
                rollback_changes
                break
                ;;
            "Reinstalar optimización")
                echo "Reinstalando..."
                rollback_changes
                apply_changes
                break
                ;;
            "Salir")
                break
                ;;
            *) echo "Opción inválida";;
        esac
    done
fi

echo -e "${BLUE}¡Operación finalizada!${NC}"