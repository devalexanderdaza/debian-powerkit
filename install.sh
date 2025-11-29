#!/bin/bash

# =================================================================================================
#
#   ██████╗ ███████╗██████╗ ██╗ █████╗ ███╗   ██╗    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ 
#   ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗████╗  ██║    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗
#   ██║  ██║█████╗  ██████╔╝██║███████║██╔██╗ ██║    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝
#   ██║  ██║██╔══╝  ██╔══██╗██║██╔══██║██║╚██╗██║    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗
#   ██████╔╝███████╗██████╔╝██║██║  ██║██║ ╚████║    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║
#   ╚═════╝ ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝
#
#   ██╗  ██╗██╗████████╗
#   ██║ ██╔╝██║╚══██╔══╝
#   █████╔╝ ██║   ██║   
#   ██╔═██╗ ██║   ██║   
#   ██║  ██╗██║   ██║   
#   ╚═╝  ╚═╝╚═╝   ╚═╝   
#
#   INSTALADOR AUTOMÁTICO DE DEBIAN POWERKIT
#
#   Autor: Alexander Daza
#   Versión: 1.0.0
#   Repositorio: https://github.com/devalexanderdaza/debian-powerkit
#
#   Este script descarga e instala automáticamente Debian PowerKit en tu sistema.
#
#   Uso:
#   curl -fsSL https://raw.githubusercontent.com/devalexanderdaza/debian-powerkit/main/install.sh | bash
#   O:
#   wget -qO- https://raw.githubusercontent.com/devalexanderdaza/debian-powerkit/main/install.sh | bash
#
# =================================================================================================

set -e  # Salir si hay algún error

# --- Configuración ---
REPO_URL="https://github.com/devalexanderdaza/debian-powerkit"
INSTALL_DIR="$HOME/debian-powerkit"
BRANCH="main"

# --- Colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Funciones ---
log_info() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
    exit 1
}

log_step() {
    echo -e "${CYAN}[→]${NC} $1"
}

print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
    ____       __    _                ____                        __ __ _ __ 
   / __ \___  / /_  (_)___ _____     / __ \____ _      _____  _____/ //_/(_) /_
  / / / / _ \/ __ \/ / __ `/ __ \   / /_/ / __ \ | /| / / _ \/ ___/ ,<  / / __/
 / /_/ /  __/ /_/ / / /_/ / / / /  / ____/ /_/ / |/ |/ /  __/ /  / /| |/ / /_  
/_____/\___/_.___/_/\__,_/_/ /_/  /_/    \____/|__/|__/\___/_/  /_/ |_/_/\__/  
                                                                                
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Tu kit de herramientas definitivo para Debian 13${NC}"
    echo -e "${CYAN}Versión: 1.0.0${NC}"
    echo ""
}

check_os() {
    log_step "Verificando sistema operativo..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "debian" ]]; then
            log_warn "Este script está diseñado para Debian, pero intentaré continuar..."
            log_warn "Sistema detectado: $ID $VERSION_ID"
        else
            log_info "Sistema: Debian $VERSION_ID ($VERSION_CODENAME)"
        fi
    else
        log_warn "No se pudo detectar el sistema operativo"
    fi
}

check_dependencies() {
    log_step "Verificando dependencias necesarias..."
    
    local missing_deps=()
    
    # Verificar git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    # Verificar curl o wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_warn "Faltan dependencias: ${missing_deps[*]}"
        log_step "Instalando dependencias..."
        
        if [[ $EUID -eq 0 ]]; then
            apt-get update -qq
            apt-get install -y -qq ${missing_deps[@]}
        else
            log_step "Se requieren permisos de sudo para instalar dependencias"
            sudo apt-get update -qq
            sudo apt-get install -y -qq ${missing_deps[@]}
        fi
        
        log_info "Dependencias instaladas correctamente"
    else
        log_info "Todas las dependencias están instaladas"
    fi
}

clone_repository() {
    log_step "Descargando Debian PowerKit..."
    
    if [ -d "$INSTALL_DIR" ]; then
        log_warn "El directorio $INSTALL_DIR ya existe"
        read -p "¿Deseas eliminarlo y reinstalar? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            log_info "Directorio anterior eliminado"
        else
            log_error "Instalación cancelada por el usuario"
        fi
    fi
    
    git clone -q --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    log_info "Repositorio clonado en: $INSTALL_DIR"
}

set_permissions() {
    log_step "Configurando permisos..."
    
    chmod +x "$INSTALL_DIR/run.sh"
    chmod +x "$INSTALL_DIR/setup/setup.sh"
    chmod +x "$INSTALL_DIR/setup/setup_zsh.sh"
    chmod +x "$INSTALL_DIR/optimization/optimize.sh"
    chmod +x "$INSTALL_DIR/tools/cleanup.sh"
    
    log_info "Permisos configurados correctamente"
}

create_symlink() {
    log_step "Creando acceso directo..."
    
    local bin_dir="$HOME/.local/bin"
    
    # Crear directorio bin si no existe
    if [ ! -d "$bin_dir" ]; then
        mkdir -p "$bin_dir"
    fi
    
    # Crear symlink
    if [ -L "$bin_dir/debian-powerkit" ]; then
        rm "$bin_dir/debian-powerkit"
    fi
    
    ln -s "$INSTALL_DIR/run.sh" "$bin_dir/debian-powerkit"
    
    # Verificar si está en el PATH
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        log_warn "$bin_dir no está en tu PATH"
        log_step "Añadiendo al PATH..."
        
        # Detectar shell
        if [ -n "$BASH_VERSION" ]; then
            echo "export PATH=\"\$PATH:$bin_dir\"" >> "$HOME/.bashrc"
            log_info "Añadido a ~/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            echo "export PATH=\"\$PATH:$bin_dir\"" >> "$HOME/.zshrc"
            log_info "Añadido a ~/.zshrc"
        fi
        
        log_warn "Necesitas recargar tu shell: source ~/.bashrc (o ~/.zshrc)"
    fi
    
    log_info "Acceso directo creado: debian-powerkit"
}

print_success() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║  ✓ ¡Instalación completada exitosamente!                 ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📁 Instalado en:${NC} $INSTALL_DIR"
    echo ""
    echo -e "${YELLOW}🚀 Para ejecutar Debian PowerKit:${NC}"
    echo ""
    echo -e "   ${GREEN}Opción 1:${NC} Usando el comando directo"
    echo -e "   ${BLUE}\$ sudo debian-powerkit${NC}"
    echo ""
    echo -e "   ${GREEN}Opción 2:${NC} Desde el directorio de instalación"
    echo -e "   ${BLUE}\$ cd $INSTALL_DIR${NC}"
    echo -e "   ${BLUE}\$ sudo ./run.sh${NC}"
    echo ""
    echo -e "${YELLOW}📚 Documentación:${NC}"
    echo -e "   ${BLUE}https://github.com/devalexanderdaza/debian-powerkit${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC} Ejecuta 'source ~/.bashrc' para usar el comando 'debian-powerkit' inmediatamente"
    echo ""
}

print_usage_examples() {
    echo -e "${CYAN}📖 Ejemplos de uso:${NC}"
    echo ""
    echo -e "   ${GREEN}# Configurar entorno de desarrollo${NC}"
    echo -e "   ${BLUE}\$ sudo debian-powerkit${NC}"
    echo -e "   Selecciona: 1. Configurar Entorno de Desarrollo"
    echo ""
    echo -e "   ${GREEN}# Optimizar el sistema${NC}"
    echo -e "   ${BLUE}\$ sudo debian-powerkit${NC}"
    echo -e "   Selecciona: 2. Optimizar el Sistema"
    echo ""
    echo -e "   ${GREEN}# Limpiar el sistema${NC}"
    echo -e "   ${BLUE}\$ sudo debian-powerkit${NC}"
    echo -e "   Selecciona: 3. Ejecutar Limpieza Avanzada"
    echo ""
}

# --- Ejecución Principal ---

main() {
    print_banner
    
    echo -e "${CYAN}Iniciando instalación de Debian PowerKit...${NC}"
    echo ""
    
    check_os
    check_dependencies
    clone_repository
    set_permissions
    create_symlink
    
    print_success
    print_usage_examples
    
    echo -e "${GREEN}¡Gracias por usar Debian PowerKit! ⭐${NC}"
    echo ""
}

# Ejecutar instalador
main
