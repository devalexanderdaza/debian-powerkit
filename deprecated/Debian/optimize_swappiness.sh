#!/bin/bash

# Colores para la salida
GREEN="[0;32m"
YELLOW="[1;33m"
BLUE="[0;34m"
NC="[0m" # Sin color

# Archivo de configuración
CONFIG_FILE="/etc/sysctl.d/99-swappiness.conf"
OPTIMAL_VALUE=10
DEFAULT_VALUE=60

# --- Funciones ---

# Verifica si se ejecuta como root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}Ups... 😟 Este script necesita privilegios de administrador para funcionar.${NC}"
        echo "Por favor, ejecútalo con 'sudo ./optimize_swappiness.sh'"
        exit 1
    fi
}

# Comprueba el estado actual de swappiness
check_status() {
    echo -e "${BLUE}🔎 Verificando valor actual de 'vm.swappiness'...${NC}"
    local current_value=$(cat /proc/sys/vm/swappiness)
    
    echo "   Valor actual: $current_value"

    if [ -f "$CONFIG_FILE" ] && [ "$current_value" -eq "$OPTIMAL_VALUE" ]; then
        echo -e "✅ ${GREEN}Swappiness ya está optimizado a $OPTIMAL_VALUE y es permanente.${NC}"
        return 0 # Optimizado
    elif [ "$current_value" -eq "$OPTIMAL_VALUE" ]; then
        echo -e "⚪ ${YELLOW}Swappiness está optimizado a $OPTIMAL_VALUE, pero el cambio no es permanente.${NC}"
        return 2 # Optimizado temporalmente
    else
        echo -e "⚪ ${YELLOW}Swappiness NO está optimizado (valor recomendado: $OPTIMAL_VALUE).${NC}"
        return 1 # No optimizado
    fi
}

# Aplica la optimización y la hace permanente
apply_changes() {
    echo -e "${BLUE}🔧 Optimizando swappiness a $OPTIMAL_VALUE...${NC}"
    
    # 1. Crear el archivo de configuración para persistencia
    echo "Creando archivo de configuración en $CONFIG_FILE..."
    echo "vm.swappiness = $OPTIMAL_VALUE" > "$CONFIG_FILE"
    
    # 2. Aplicar el cambio inmediatamente
    echo "Aplicando el cambio en el sistema actual..."
    sysctl -p "$CONFIG_FILE"
    
    local current_value=$(cat /proc/sys/vm/swappiness)
    if [ "$current_value" -eq "$OPTIMAL_VALUE" ]; then
        echo -e "${GREEN}🚀 ¡Éxito! Swappiness optimizado a $current_value.${NC}"
        echo "   Este cambio ahora es permanente y se aplicará en cada reinicio."
    else
        echo -e "${YELLOW}😟 Hubo un error al aplicar la configuración.${NC}"
    fi
}

# Revierte los cambios (Rollback)
rollback_changes() {
    echo -e "${BLUE}⏪ Revirtiendo swappiness a su valor por defecto ($DEFAULT_VALUE)...${NC}"
    
    # 1. Eliminar el archivo de configuración
    if [ -f "$CONFIG_FILE" ]; then
        echo "Eliminando archivo de configuración $CONFIG_FILE..."
        rm -f "$CONFIG_FILE"
    else
        echo "No se encontró el archivo de configuración, omitiendo."
    fi

    # 2. Aplicar el valor por defecto inmediatamente
    echo "Aplicando el valor por defecto ($DEFAULT_VALUE) en el sistema actual..."
    sysctl vm.swappiness=$DEFAULT_VALUE
    
    local current_value=$(cat /proc/sys/vm/swappiness)
    if [ "$current_value" -eq "$DEFAULT_VALUE" ]; then
        echo -e "${GREEN}✅ ¡Rollback completado!${NC}"
        echo "   Swappiness restaurado a ${GREEN}$current_value${NC}."
        echo "   El sistema usará su valor por defecto en el próximo reinicio."
    else
        echo -e "${YELLOW}😟 Hubo un error al revertir la configuración.${NC}"
    fi
}

# --- Menú Principal ---

check_root
echo -e "${GREEN}--- Script de Optimización de Swappiness 🧠 ---${NC}"
echo "Este script ajusta 'swappiness' para que tu sistema prefiera usar la RAM"
echo "en lugar del disco, mejorando la agilidad general."
echo

check_status
current_status=$?
echo

echo -e "${YELLOW}¿Qué te gustaría hacer?${NC}"

# Menú dinámico basado en el estado
case $current_status in
    0) # Ya optimizado
        options=("⏪ Revertir a valor por defecto" "🔄 Re-aplicar optimización" "🚪 Salir")
        ;;
    1) # No optimizado
        options=("⚡ Optimizar Swappiness (valor 10)" "🚪 Salir")
        ;;
    2) # Optimizado temporalmente
        options=("⚡ Hacer el cambio permanente" "⏪ Revertir a valor por defecto" "🚪 Salir")
        ;;
esac

select opt in "${options[@]}"; do
    case $opt in
        "⚡ Optimizar Swappiness (valor 10)"|"⚡ Hacer el cambio permanente"|"🔄 Re-aplicar optimización")
            apply_changes
            break
            ;;
        "⏪ Revertir a valor por defecto")
            rollback_changes
            break
            ;;
        "🚪 Salir")
            break
            ;;
        *) echo "Opción inválida";;
    esac
done

echo -e "${BLUE}👋 ¡Operación finalizada!${NC}"
