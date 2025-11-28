#!/bin/bash

# =================================================================================================
#
#   ████████╗███████╗████████╗██╗   ██╗██████╗     ███████╗███████╗███████╗
#   ╚══██╔══╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ██╔════╝██╔════╝██╔════╝
#      ██║   █████╗     ██║   ██║   ██║██████╔╝    ███████╗███████╗███████╗
#      ██║   ██╔══╝     ██║   ██║   ██║██╔═══╝     ╚════██║╚════██║╚════██║
#      ██║   ███████╗   ██║   ╚██████╔╝██║         ███████║███████║███████║
#      ╚═╝   ╚══════╝   ╚═╝    ╚═════╝ ╚═╝         ╚══════╝╚══════╝╚══════╝
#
#   SCRIPT DE CONFIGURACIÓN INTEGRAL PARA ENTORNOS DE DESARROLLO EN DEBIAN
#
#   Autor: Tu Nombre/Alias
#   Versión: 2.0
#
#   Este script unifica la instalación y configuración de un entorno de 
#   desarrollo completo, incluyendo herramientas esenciales, lenguajes de 
#   programación, contenedores y editores de código.
#
# =================================================================================================

# --- Configuración y Funciones Auxiliares ---

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Función para imprimir mensajes informativos
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Función para imprimir advertencias
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Función para imprimir errores y salir
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# Función para solicitar confirmación del usuario
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

# --- Verificación Inicial ---

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   log_error "Este script debe ser ejecutado como root. Usa: sudo ./setup.sh"
fi

# --- Módulos de Instalación ---

# 1. Actualización del Sistema y Paquetes Esenciales
install_base_system() {
    log_info "Actualizando el sistema e instalando paquetes base..."
    apt-get update && apt-get upgrade -y
    apt-get install -y \
        build-essential \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common \
        git \
        wget \
        unzip \
        htop \
        ncdu \
        zsh \
        dialog # Necesario para la interfaz
    log_info "Sistema base actualizado."
}

# 2. Configuración de Docker
install_docker() {
    if command_exists docker; then
        log_info "Docker ya está instalado. Omitiendo."
        return
    fi

    log_info "Instalando Docker..."
    # Añadir GPG key de Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Añadir el repositorio
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Añadir usuario actual al grupo de docker
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
        log_info "Usuario '$SUDO_USER' añadido al grupo de Docker. Necesitarás reiniciar la sesión para que los cambios surtan efecto."
    else
        log_warn "No se pudo detectar el usuario no-root. Añade tu usuario al grupo 'docker' manualmente."
    fi
    log_info "Docker instalado correctamente."
}

# 3. Configuración de Node.js (vía NVM)
install_nodejs() {
    if command_exists nvm; then
        log_info "NVM ya está instalado. Omitiendo."
        return
    fi

    log_info "Instalando NVM (Node Version Manager)..."
    # La instalación de NVM debe hacerse por usuario, no como root.
    # Se instalará para el usuario que invocó sudo.
    if [ -n "$SUDO_USER" ]; then
        su - $SUDO_USER -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
        log_info "NVM instalado para el usuario '$SUDO_USER'."
        log_info "Ejecuta 'source ~/.nvm/nvm.sh' y luego 'nvm install --lts' para instalar la última versión LTS de Node.js."
    else
        log_warn "No se pudo instalar NVM porque no se detectó un usuario no-root."
    fi
}

# 4. Configuración de Python
install_python() {
    # La mayoría de sistemas Debian ya vienen con Python 3.
    # Esta función se asegura de que pip y venv estén disponibles.
    if command_exists pip3 && [[ -x "/usr/bin/python3" ]]; then
        log_info "Python 3 y pip3 ya están instalados. Verificando venv..."
    fi

    log_info "Instalando Python 3, pip y venv..."
    apt-get install -y python3 python3-pip python3-venv
    log_info "Python 3, pip y venv están listos."
}

# 5. Instalación de Editores de Código
install_ides() {
    if ! command_exists code; then
        log_info "Instalando VS Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        apt-get update
        apt-get install -y code
        log_info "VS Code instalado."
    else
        log_info "VS Code ya está instalado."
    fi
}


# --- Menú Interactivo y Ejecución Principal ---

main() {
    log_info "Inicio de la configuración del entorno de desarrollo."
    
    # 1. Instalar sistema base y dialog
    install_base_system

    # 2. Mostrar menú de selección
    OPTIONS=(
        1 "Instalar Docker y Docker Compose" on
        2 "Instalar Node.js (vía NVM)" on
        3 "Instalar Python 3, pip y venv" on
        4 "Instalar Visual Studio Code" on
    )

    CHOICES=$(dialog --clear \
                    --backtitle "Asistente de Configuración de Entorno de Desarrollo" \
                    --title "Selección de Componentes" \
                    --checklist "Usa la barra espaciadora para seleccionar/deseleccionar. Los componentes preseleccionados ya están instalados o son recomendados." \
                    18 70 5 \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

    clear # Limpiar la pantalla después de que dialog termine

    # 3. Procesar las elecciones
    if [ -n "$CHOICES" ]; then
        log_info "Componentes seleccionados: $CHOICES"
        
        if [[ $CHOICES == *"1"* ]]; then
            install_docker
        else
            log_info "Omitiendo Docker."
        fi
        
        if [[ $CHOICES == *"2"* ]]; then
            install_nodejs
        else
            log_info "Omitiendo Node.js."
        fi
        
        if [[ $CHOICES == *"3"* ]]; then
            install_python
        else
            log_info "Omitiendo Python."
        fi
        
        if [[ $CHOICES == *"4"* ]]; then
            install_ides
        else
            log_info "Omitiendo VS Code."
        fi
    else
        log_warn "No se seleccionó ningún componente para instalar."
    fi

    log_info "¡Configuración completada!"
    log_info "Algunos cambios, como la pertenencia al grupo de Docker, pueden requerir un reinicio de sesión."
}

# Iniciar la ejecución
main

