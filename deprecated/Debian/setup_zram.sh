#!/bin/bash

# Colores para la salida
GREEN="[0;32m"
YELLOW="[1;33m"
BLUE="[0;34m"
NC="[0m" # Sin color

PACKAGE_NAME="zram-tools"

# --- Funciones ---

# Verifica si se ejecuta como root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}Ups... 😟 Este script necesita privilegios de administrador para funcionar.${NC}"
        echo "Por favor, ejecútalo con 'sudo ./setup_zram.sh'"
        exit 1
    fi
}

# Comprueba si ZRAM está instalado y activo
check_status() {
    echo -e "${BLUE}🔎 Verificando estado de ZRAM...${NC}"
    
    # dpkg-query es más silencioso que dpkg -s
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "✅ ${GREEN}El paquete '$PACKAGE_NAME' está instalado.${NC}"
        if swapon --show | grep -q '/dev/zram'; then
            echo -e "✅ ${GREEN}ZRAM está ACTIVO y funcionando como dispositivo de intercambio.${NC}"
            zramctl
            return 0 # Instalado y activo
        else
            echo -e "⚪ ${YELLOW}ZRAM está instalado pero NO parece estar activo como swap.${NC}"
            return 2 # Instalado pero no activo
        fi
    else
        echo -e "⚪ ${YELLOW}El paquete '$PACKAGE_NAME' NO está instalado.${NC}"
        return 1 # No instalado
    fi
}

# Instala y configura ZRAM
apply_changes() {
    echo -e "${BLUE}🔧 Instalando y configurando ZRAM...${NC}"
    
    echo "Actualizando lista de paquetes (apt update)..."
    apt-get update
    
    echo "Instalando el paquete '$PACKAGE_NAME'..."
    apt-get install -y "$PACKAGE_NAME"
    
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "${GREEN}🚀 ¡Éxito! ZRAM instalado y activado.${NC}"
        echo "Dispositivos ZRAM activos:"
        zramctl
    else
        echo -e "${YELLOW}😟 Hubo un error durante la instalación.${NC}"
    fi
}

# Desinstala ZRAM (Rollback)
rollback_changes() {
    echo -e "${BLUE}⏪ Desinstalando ZRAM (Rollback)...${NC}"
    
    echo "Purgando el paquete '$PACKAGE_NAME' para una desinstalación completa..."
    apt-get purge -y "$PACKAGE_NAME"
    
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "${YELLOW}😟 Hubo un error durante la desinstalación.${NC}"
    else
        echo -e "${GREEN}✅ ¡Rollback completado!${NC}"
        echo "   ZRAM ha sido completamente eliminado del sistema."
    fi
}

# --- Menú Principal ---

check_root
echo -e "${GREEN}--- Script de Instalación de ZRAM 🐏 ---${NC}"
echo "Este script instala ZRAM, un módulo que crea un disco de intercambio"
echo "comprimido en la RAM. Es mucho más rápido que usar el disco."
echo

check_status
current_status=$?
echo

echo -e "${YELLOW}¿Qué te gustaría hacer?${NC}"

# Menú dinámico basado en el estado
case $current_status in
    0) # Instalado y activo
        options=("⏪ Desinstalar ZRAM (Rollback)" "🔄 Reinstalar ZRAM" "🚪 Salir")
        ;;
    1) # No instalado
        options=("⚡ Instalar ZRAM" "🚪 Salir")
        ;;
    2) # Instalado pero no activo
        options=("⏪ Desinstalar ZRAM (Rollback)" "🔄 Reinstalar ZRAM" "🚪 Salir")
        ;;
esac

select opt in "${options[@]}"; do
    case $opt in
        "⚡ Instalar ZRAM")
            apply_changes
            break
            ;;
        "⏪ Desinstalar ZRAM (Rollback)")
            rollback_changes
            break
            ;;
        "🔄 Reinstalar ZRAM")
            echo "Reinstalando..."
            rollback_changes
            apply_changes
            break
            ;;
        "🚪 Salir")
            break
            ;;
        *) echo "Opción inválida";;
    esac
done

echo -e "${BLUE}👋 ¡Operación finalizada!${NC}"
