#!/bin/bash

# =================================================================================================
#
#    ██████╗ ██╗      ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ 
#   ██╔════╝ ██║      ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗
#   ██║  ███╗██║      █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝
#   ██║   ██║██║      ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ 
#   ╚██████╔╝███████╗ ███████╗██║  ██║██║ ╚████║╚██████╔╝██║     
#    ╚═════╝ ╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     
#
#   SCRIPT DE LIMPIEZA AVANZADO PARA SISTEMAS DE DESARROLLO
#
#   Autor: Tu Nombre/Alias
#   Versión: 2.0
#
#   Este script proporciona herramientas para mantener el sistema limpio,
#   incluyendo la limpieza de paquetes del sistema y la eliminación de
#   artefactos de compilación y cachés de proyectos de desarrollo.
#
#   Uso:
#   ./cleanup.sh                # Muestra el menú interactivo
#   ./cleanup.sh --system       # Ejecuta solo la limpieza del sistema
#   ./cleanup.sh --deep-clean   # Ejecuta solo la limpieza de proyectos
#
# =================================================================================================

# --- Configuración y Funciones Auxiliares ---

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

ask_yes_no() {
    while true; do
        read -p "$1 [y/n]: " choice
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Por favor, responde 'y' o 'n'.";;
        esac
    done
}

# --- Módulos de Limpieza ---

# 1. Limpieza del Sistema (APT)
system_cleanup() {
    log_info "Iniciando limpieza del sistema..."
    
    if [[ $EUID -ne 0 ]]; then
       log_warn "Se necesitan privilegios de root para la limpieza del sistema. Intentando con sudo..."
       SUDO="sudo"
    fi

    log_info "Eliminando paquetes huérfanos (dependencias no necesarias)..."
    $SUDO apt-get autoremove -y

    log_info "Limpiando el caché de paquetes descargados..."
    $SUDO apt-get clean

    log_info "Limpieza del sistema completada."
}

# 2. Limpieza Profunda de Proyectos
deep_clean_projects() {
    log_info "Iniciando búsqueda de directorios de caché de proyectos..."
    
    # Directorios a buscar y eliminar
    TARGET_DIRS=("node_modules" "build" "dist" ".venv" "venv" "target" "vendor" "__pycache__" ".pytest_cache" ".next" ".nuxt")
    
    # Preguntar al usuario por el directorio base
    echo -e "\n${CYAN}¿Dónde deseas buscar los directorios a limpiar?${NC}"
    echo "1. Directorio actual ($PWD)"
    echo "2. Directorio home del usuario ($HOME)"
    echo "3. Especificar una ruta personalizada"
    read -p "Selecciona una opción [1-3]: " dir_choice
    
    case $dir_choice in
        1)
            SEARCH_DIR="$PWD"
            ;;
        2)
            SEARCH_DIR="$HOME"
            ;;
        3)
            read -p "Introduce la ruta completa del directorio: " custom_dir
            if [ -d "$custom_dir" ]; then
                SEARCH_DIR="$custom_dir"
            else
                log_warn "El directorio '$custom_dir' no existe. Usando directorio actual."
                SEARCH_DIR="$PWD"
            fi
            ;;
        *)
            log_warn "Opción no válida. Usando directorio actual."
            SEARCH_DIR="$PWD"
            ;;
    esac
    
    # Construir el comando find
    FIND_CMD="find \"$SEARCH_DIR\" -type d \( "
    for i in "${!TARGET_DIRS[@]}"; do
        FIND_CMD+="-name '${TARGET_DIRS[$i]}'"
        if [ $i -lt $((${#TARGET_DIRS[@]} - 1)) ]; then
            FIND_CMD+=" -o "
        fi
    done
    FIND_CMD+=" \) -prune"

    log_info "Buscando en '$SEARCH_DIR' los siguientes directorios: ${TARGET_DIRS[*]}"
    log_warn "Esta operación puede tomar varios minutos dependiendo del tamaño del directorio..."
    
    # Ejecutar find y almacenar los resultados
    readarray -t DIRS_TO_DELETE < <(eval $FIND_CMD 2>/dev/null)

    if [ ${#DIRS_TO_DELETE[@]} -eq 0 ]; then
        log_info "No se encontraron directorios para eliminar. ¡Tu espacio está optimizado!"
        return
    fi

    echo -e "\n${GREEN}Se encontraron ${#DIRS_TO_DELETE[@]} directorios para eliminar:${NC}"
    TOTAL_SIZE=0
    for dir in "${DIRS_TO_DELETE[@]}"; do
        # Calcular tamaño del directorio
        SIZE_KB=$(du -sk "$dir" 2>/dev/null | awk '{print $1}')
        if [ -n "$SIZE_KB" ]; then
            TOTAL_SIZE=$((TOTAL_SIZE + SIZE_KB))
            SIZE=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
            echo -e "  - ${CYAN}$dir${NC} (${YELLOW}$SIZE${NC})"
        fi
    done
    
    # Mostrar tamaño total a liberar
    TOTAL_SIZE_HUMAN=$(echo $TOTAL_SIZE | awk '{printf "%.2f GB", $1/1024/1024}')
    echo -e "\n${GREEN}Espacio total a liberar: ${YELLOW}$TOTAL_SIZE_HUMAN${NC}"

    echo
    if ask_yes_no "¿Estás seguro de que deseas eliminar permanentemente estos directorios?"; then
        log_info "Eliminando directorios..."
        COUNT=0
        for dir in "${DIRS_TO_DELETE[@]}"; do
            COUNT=$((COUNT + 1))
            echo "[$COUNT/${#DIRS_TO_DELETE[@]}] Eliminando $dir..."
            rm -rf "$dir"
        done
        log_info "Limpieza profunda de proyectos completada. Se liberaron aproximadamente $TOTAL_SIZE_HUMAN."
    else
        log_info "Operación cancelada por el usuario."
    fi
}

# --- Menú Principal y Ejecución ---

show_menu() {
    echo "--- Menú de Limpieza ---"
    echo "1. Limpieza del Sistema (apt autoremove, clean)"
    echo "2. Limpieza Profunda de Proyectos (node_modules, build, etc.)"
    echo "3. Salir"
    read -p "Selecciona una opción: " menu_choice

    case $menu_choice in
        1) system_cleanup ;;
        2) deep_clean_projects ;;
        3) exit 0 ;;
        *) echo "Opción no válida." ;;
    esac
}

main() {
    if [ "$1" == "--system" ]; then
        system_cleanup
    elif [ "$1" == "--deep-clean" ]; then
        deep_clean_projects
    elif [ "$1" != "" ]; then
        echo "Argumento no válido. Uso: $0 [--system|--deep-clean]"
    else
        show_menu
    fi
}

main "$@"
