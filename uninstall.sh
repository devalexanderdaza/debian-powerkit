#!/bin/bash

# =================================================================================================
#
#   ██╗   ██╗███╗   ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     
#   ██║   ██║████╗  ██║██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     
#   ██║   ██║██╔██╗ ██║██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     
#   ██║   ██║██║╚██╗██║██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     
#   ╚██████╔╝██║ ╚████║██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
#    ╚═════╝ ╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
#
#   DESINSTALADOR DE DEBIAN POWERKIT
#
#   Autor: Alexander Daza
#   Versión: 1.0.0
#
#   Este script elimina Debian PowerKit de tu sistema de forma segura.
#
# =================================================================================================

set -e

# --- Configuración ---
INSTALL_DIR="$HOME/debian-powerkit"
BIN_DIR="$HOME/.local/bin"
SYMLINK="$BIN_DIR/debian-powerkit"

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Funciones ---
log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

log_step() {
    echo -e "${CYAN}[→]${NC} $1"
}

print_banner() {
    echo -e "${RED}"
    cat << "EOF"
    ____            _           __        ___           
   / / /___  ____ _(_)___  _____/ /_____ _/ / /   
  / / / __ \/ __ `/ / __ \/ ___/ __/ __ `/ / /    
 / /_/ / / / /_/ / / / / (__  ) /_/ /_/ / / /     
 \____/_/ /_/\__,_/_/_/ /_/____/\__/\__,_/_/_/      
                                                     
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}Desinstalador de Debian PowerKit${NC}"
    echo ""
}

confirm_uninstall() {
    echo -e "${YELLOW}⚠️  ADVERTENCIA: Estás a punto de desinstalar Debian PowerKit${NC}"
    echo ""
    echo "Esto eliminará:"
    echo "  - Directorio de instalación: $INSTALL_DIR"
    echo "  - Enlace simbólico: $SYMLINK"
    echo ""
    echo -e "${CYAN}Nota: Las configuraciones del sistema aplicadas (optimizaciones, etc.)${NC}"
    echo -e "${CYAN}      NO serán revertidas automáticamente.${NC}"
    echo ""
    
    read -p "¿Estás seguro de que deseas continuar? [y/N]: " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Desinstalación cancelada"
        exit 0
    fi
}

remove_directory() {
    if [ -d "$INSTALL_DIR" ]; then
        log_step "Eliminando directorio de instalación..."
        rm -rf "$INSTALL_DIR"
        log_info "Directorio eliminado: $INSTALL_DIR"
    else
        log_warn "El directorio $INSTALL_DIR no existe"
    fi
}

remove_symlink() {
    if [ -L "$SYMLINK" ]; then
        log_step "Eliminando enlace simbólico..."
        rm "$SYMLINK"
        log_info "Enlace eliminado: $SYMLINK"
    else
        log_warn "El enlace simbólico no existe"
    fi
}

cleanup_path() {
    log_step "Verificando configuración del PATH..."
    
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"
    local path_line="export PATH=\"\$PATH:$BIN_DIR\""
    
    # Limpiar de .bashrc
    if [ -f "$bashrc" ] && grep -q "$BIN_DIR" "$bashrc"; then
        log_step "Limpiando ~/.bashrc..."
        sed -i "\|$BIN_DIR|d" "$bashrc"
        log_info "~/.bashrc actualizado"
    fi
    
    # Limpiar de .zshrc
    if [ -f "$zshrc" ] && grep -q "$BIN_DIR" "$zshrc"; then
        log_step "Limpiando ~/.zshrc..."
        sed -i "\|$BIN_DIR|d" "$zshrc"
        log_info "~/.zshrc actualizado"
    fi
}

ask_revert_optimizations() {
    echo ""
    echo -e "${YELLOW}¿Deseas revertir las optimizaciones del sistema?${NC}"
    echo ""
    echo "Esto incluye:"
    echo "  - Gobernador de CPU"
    echo "  - Configuración de memoria (swappiness)"
    echo "  - ZRAM"
    echo "  - TCP BBR"
    echo "  - Límites de inotify"
    echo "  - Preload"
    echo ""
    
    read -p "¿Revertir optimizaciones? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        revert_optimizations
    else
        log_info "Las optimizaciones del sistema se mantendrán"
        echo -e "${CYAN}Puedes revertirlas manualmente usando los backups en /etc/*.bak-*${NC}"
    fi
}

revert_optimizations() {
    log_step "Revirtiendo optimizaciones del sistema..."
    
    if [[ $EUID -ne 0 ]]; then
        log_warn "Se requieren permisos de root para revertir optimizaciones"
        log_step "Intentando con sudo..."
        SUDO="sudo"
    else
        SUDO=""
    fi
    
    # Buscar el backup más reciente de sysctl.conf
    local latest_backup=$(ls -t /etc/sysctl.conf.bak-* 2>/dev/null | head -1)
    
    if [ -n "$latest_backup" ]; then
        read -p "¿Restaurar $latest_backup? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $SUDO cp "$latest_backup" /etc/sysctl.conf
            $SUDO sysctl -p > /dev/null 2>&1
            log_info "Configuración de sysctl restaurada"
        fi
    else
        log_warn "No se encontraron backups de /etc/sysctl.conf"
    fi
    
    # Desinstalar ZRAM si está instalado
    if dpkg -l | grep -q zram-tools; then
        read -p "¿Desinstalar zram-tools? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $SUDO apt-get remove --purge -y zram-tools > /dev/null 2>&1
            log_info "zram-tools desinstalado"
        fi
    fi
    
    # Desinstalar Preload si está instalado
    if dpkg -l | grep -q preload; then
        read -p "¿Desinstalar preload? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            $SUDO apt-get remove --purge -y preload > /dev/null 2>&1
            log_info "preload desinstalado"
        fi
    fi
    
    # Deshabilitar servicio de CPU
    if systemctl is-enabled cpupower.service > /dev/null 2>&1; then
        $SUDO systemctl disable --now cpupower.service > /dev/null 2>&1
        $SUDO rm -f /etc/systemd/system/cpupower.service
        log_info "Servicio cpupower deshabilitado"
    fi
    
    log_info "Optimizaciones revertidas"
}

print_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║  ✓ Debian PowerKit desinstalado correctamente            ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Gracias por usar Debian PowerKit${NC}"
    echo ""
    echo -e "${YELLOW}Si deseas reinstalarlo en el futuro:${NC}"
    echo -e "${BLUE}curl -fsSL https://raw.githubusercontent.com/devalexanderdaza/debian-powerkit/main/install.sh | bash${NC}"
    echo ""
}

# --- Ejecución Principal ---

main() {
    print_banner
    confirm_uninstall
    
    echo ""
    log_step "Iniciando desinstalación..."
    echo ""
    
    remove_symlink
    remove_directory
    cleanup_path
    ask_revert_optimizations
    
    print_success
}

# Ejecutar desinstalador
main
