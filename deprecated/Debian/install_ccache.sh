#!/bin/bash

# Colores para la salida
GREEN="[0;32m"
YELLOW="[1;33m"
BLUE="[0;34m"
NC="[0m" # Sin color

PACKAGE_NAME="ccache"
CONFIG_FILE="/etc/profile.d/ccache.sh"

# --- Funciones ---

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${YELLOW}Ups... 😟 Este script necesita privilegios de administrador.${NC}"
        echo "Por favor, ejecútalo con 'sudo ./install_ccache.sh'"
        exit 1
    fi
}

check_status() {
    echo -e "${BLUE}🔎 Verificando la instalación de ccache...${NC}"
    
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "✅ ${GREEN}El paquete '$PACKAGE_NAME' está instalado.${NC}"
        if [ -f "$CONFIG_FILE" ]; then
            echo -e "✅ ${GREEN}El sistema está configurado para usar ccache automáticamente.${NC}"
            return 0 # Instalado y configurado
        else
            echo -e "⚪ ${YELLOW}ccache está instalado pero no configurado para uso automático.${NC}"
            return 2 # Instalado pero no configurado
        fi
    else
        echo -e "⚪ ${YELLOW}El paquete '$PACKAGE_NAME' NO está instalado.${NC}"
        return 1 # No instalado
    fi
}

apply_changes() {
    echo -e "${BLUE}🔧 Instalando y configurando ccache...${NC}"
    
    echo "Actualizando lista de paquetes (apt update)..."
    apt-get update
    
    echo "Instalando el paquete '$PACKAGE_NAME'..."
    apt-get install -y "$PACKAGE_NAME"
    
    echo "Creando archivo de configuración en $CONFIG_FILE para la integración con el sistema..."
    echo 'export PATH="/usr/lib/ccache:$PATH"' > "$CONFIG_FILE"
    
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "${GREEN}🚀 ¡Éxito! ccache instalado y configurado.${NC}"
        echo -e "${YELLOW}⚠️ ¡IMPORTANTE! Debes cerrar sesión y volver a iniciarla (o reiniciar la terminal) para que los cambios surtan efecto.${NC}"
    else
        echo -e "${YELLOW}😟 Hubo un error durante la instalación.${NC}"
    fi
}

rollback_changes() {
    echo -e "${BLUE}⏪ Desinstalando ccache y revirtiendo la configuración...${NC}"
    
    echo "Purgando el paquete '$PACKAGE_NAME' para una desinstalación completa..."
    apt-get purge -y "$PACKAGE_NAME"
    
    if [ -f "$CONFIG_FILE" ]; then
        echo "Eliminando archivo de configuración $CONFIG_FILE..."
        rm -f "$CONFIG_FILE"
    fi
    
    if dpkg-query -W -f='${Status}' "$PACKAGE_NAME" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "${YELLOW}😟 Hubo un error durante la desinstalación.${NC}"
    else
        echo -e "${GREEN}✅ ¡Rollback completado!${NC}"
        echo "   ccache ha sido completamente eliminado del sistema."
        echo -e "${YELLOW}⚠️ Por favor, cierra sesión y vuelve a iniciarla para limpiar la configuración de la terminal.${NC}"
    fi
}

# --- Menú Principal ---

check_root
echo -e "${GREEN}--- Script: Acelerador de Compilación (ccache) 🚀 ---${NC}"
echo "Este script instala ccache, una herramienta que acelera drásticamente la compilación"
echo "guardando en caché los resultados para no repetir el trabajo."
echo

check_status
current_status=$?
echo

echo -e "${YELLOW}¿Qué te gustaría hacer?${NC}"

# Menú dinámico
case $current_status in
    0) # Instalado y configurado
        options=("⏪ Desinstalar ccache (Rollback)" "🔄 Reinstalar ccache" "🚪 Salir")
        ;;
    1) # No instalado
        options=("⚡ Instalar y configurar ccache" "🚪 Salir")
        ;;
    2) # Instalado pero no configurado
        options=("🔧 Configurar ccache para uso automático" "⏪ Desinstalar ccache (Rollback)" "🚪 Salir")
        ;;
esac

select opt in "${options[@]}"; do
    case $opt in
        "⚡ Instalar y configurar ccache"|"🔧 Configurar ccache para uso automático"|"🔄 Reinstalar ccache")
            apply_changes
            break
            ;;
        "⏪ Desinstalar ccache (Rollback)")
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
