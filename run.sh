#!/bin/bash

# =================================================================================================
#
#   ███╗   ███╗ ██████╗ ███╗   ██╗  ██╗  ██╗
#   ████╗ ████║ ██╔══██╗████╗  ██║  ╚██╗██╔╝
#   ██╔████╔██║ ██████╔╝██╔██╗ ██║   ╚███╔╝ 
#   ██║╚██╔╝██║ ██╔══██╗██║╚██╗██║   ██╔██╗ 
#   ██║ ╚═╝ ██║ ██║  ██║██║ ╚████║  ██╔╝ ██╗
#   ╚═╝     ╚═╝ ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═╝
#
#   SCRIPT MAESTRO PARA LA GESTIÓN DEL SISTEMA
#
#   Autor: Tu Nombre/Alias
#   Versión: 1.0
#
#   Este script sirve como un punto de entrada unificado para ejecutar todas las
#   herramientas de configuración, optimización y limpieza del sistema.
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

# --- Verificación Inicial ---

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   log_error "Este script debe ser ejecutado como root. Usa: sudo ./run.sh"
fi

# Verificar si 'dialog' está instalado
if ! command -v dialog &> /dev/null; then
    log_warn "'dialog' no está instalado. Es necesario para la interfaz interactiva."
    log_info "Instalando 'dialog'..."
    apt-get update > /dev/null && apt-get install -y dialog
    clear
fi

# --- Menú Principal ---

main() {
    # Obtener la ruta absoluta del directorio del script
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    while true; do
        CHOICE=$(dialog --clear \
                        --backtitle "Asistente de Gestión del Sistema" \
                        --title "Menú Principal" \
                        --menu "Selecciona una opción:" \
                        17 60 5 \
                        1 "Configurar Entorno de Desarrollo" \
                        2 "Configurar Zsh + Oh My Zsh + Powerlevel10k" \
                        3 "Optimizar el Sistema" \
                        4 "Ejecutar Limpieza Avanzada" \
                        5 "Salir" \
                        2>&1 >/dev/tty)

        clear
        case $CHOICE in
            1)
                log_info "Iniciando el script de configuración del entorno..."
                bash "$SCRIPT_DIR/setup/setup.sh"
                log_info "Script de configuración finalizado. Volviendo al menú principal."
                read -p "Presiona Enter para continuar..."
                ;;
            2)
                log_info "Iniciando configuración de Zsh con Oh My Zsh y Powerlevel10k..."
                bash "$SCRIPT_DIR/setup/setup_zsh.sh"
                log_info "Configuración de Zsh finalizada. Volviendo al menú principal."
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                log_info "Iniciando el script de optimización del sistema..."
                bash "$SCRIPT_DIR/optimization/optimize.sh"
                log_info "Script de optimización finalizado. Volviendo al menú principal."
                read -p "Presiona Enter para continuar..."
                ;;
            4)
                log_info "Iniciando el script de limpieza avanzada..."
                bash "$SCRIPT_DIR/tools/cleanup.sh"
                log_info "Script de limpieza finalizado. Volviendo al menú principal."
                read -p "Presiona Enter para continuar..."
                ;;


            5)
                log_info "Saliendo del asistente. ¡Hasta luego!"
                break
                ;;
            *)
                log_warn "Opción no válida o cancelada. Saliendo."
                break
                ;;
        esac
    done
}

# Iniciar la ejecución
main
