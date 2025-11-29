#!/bin/bash

# =================================================================================================
#
#   ███████╗███████╗██╗  ██╗    ███████╗███████╗████████╗██╗   ██╗██████╗ 
#   ╚══███╔╝██╔════╝██║  ██║    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
#     ███╔╝ ███████╗███████║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
#    ███╔╝  ╚════██║██╔══██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
#   ███████╗███████║██║  ██║    ███████║███████╗   ██║   ╚██████╔╝██║     
#   ╚══════╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
#
#   SCRIPT DE CONFIGURACIÓN DE ZSH CON OH-MY-ZSH Y POWERLEVEL10K
#
#   Autor: Alexander Daza
#   Versión: 1.0
#
#   Este script instala y configura zsh con oh-my-zsh, el tema Powerlevel10k,
#   las fuentes Nerd Fonts necesarias, y los plugins más populares para
#   desarrollo en Debian 13.
#
# =================================================================================================

# --- Configuración y Funciones Auxiliares ---

# Colores para la salida
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
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

# Función para imprimir pasos
log_step() {
    echo -e "${CYAN}[→]${NC} $1"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" &> /dev/null
}

# --- Verificación Inicial ---

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   log_error "Este script debe ser ejecutado como root. Usa: sudo ./setup_zsh.sh"
fi

# Obtener el usuario real (que invocó sudo)
if [ -n "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    log_error "No se pudo detectar el usuario. Este script debe ejecutarse con sudo."
fi

log_info "Configurando zsh para el usuario: $TARGET_USER"

# --- Módulos de Instalación ---

# 1. Instalar zsh
install_zsh() {
    log_step "Instalando zsh..."
    
    if command_exists zsh; then
        log_info "zsh ya está instalado."
    else
        apt-get update
        apt-get install -y zsh
        log_info "zsh instalado correctamente."
    fi
}

# 2. Instalar oh-my-zsh
install_oh_my_zsh() {
    log_step "Instalando Oh My Zsh..."
    
    local ohmyzsh_dir="$TARGET_HOME/.oh-my-zsh"
    
    if [ -d "$ohmyzsh_dir" ]; then
        log_info "Oh My Zsh ya está instalado en $ohmyzsh_dir"
        return
    fi
    
    # Instalar oh-my-zsh sin cambiar el shell automáticamente
    su - "$TARGET_USER" -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    
    log_info "Oh My Zsh instalado correctamente."
}

# 3. Instalar Powerlevel10k
install_powerlevel10k() {
    log_step "Instalando tema Powerlevel10k..."
    
    local p10k_dir="$TARGET_HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    if [ -d "$p10k_dir" ]; then
        log_info "Powerlevel10k ya está instalado."
        return
    fi
    
    su - "$TARGET_USER" -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $TARGET_HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    # Configurar el tema en .zshrc
    local zshrc="$TARGET_HOME/.zshrc"
    if [ -f "$zshrc" ]; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$zshrc"
        log_info "Tema Powerlevel10k configurado en .zshrc"
    fi
    
    log_info "Powerlevel10k instalado correctamente."
}

# 4. Instalar Nerd Fonts (MesloLGS NF - recomendada por Powerlevel10k)
install_nerd_fonts() {
    log_step "Instalando Nerd Fonts (MesloLGS NF)..."
    
    local fonts_dir="$TARGET_HOME/.local/share/fonts"
    
    # Verificar si ya existen las fuentes
    if [ -d "$fonts_dir" ] && ls "$fonts_dir"/MesloLGS* &>/dev/null 2>&1; then
        log_info "Nerd Fonts (MesloLGS NF) ya están instaladas."
        return
    fi
    
    # Crear directorio de fuentes si no existe
    mkdir -p "$fonts_dir"
    chown "$TARGET_USER:$TARGET_USER" "$fonts_dir"
    
    # Descargar las fuentes MesloLGS NF
    local font_base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local fonts=(
        "MesloLGS%20NF%20Regular.ttf"
        "MesloLGS%20NF%20Bold.ttf"
        "MesloLGS%20NF%20Italic.ttf"
        "MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    for font in "${fonts[@]}"; do
        local font_name="${font//%20/ }"
        log_info "Descargando $font_name..."
        curl -fsSL "$font_base_url/$font" -o "$fonts_dir/$font_name"
    done
    
    # Cambiar propietario de las fuentes
    chown -R "$TARGET_USER:$TARGET_USER" "$fonts_dir"
    
    # Actualizar caché de fuentes
    if command_exists fc-cache; then
        fc-cache -f "$fonts_dir"
    fi
    
    log_info "Nerd Fonts instaladas correctamente."
    log_warn "Recuerda configurar tu emulador de terminal para usar 'MesloLGS NF' como fuente."
}

# 5. Instalar plugins populares para desarrollo
install_plugins() {
    log_step "Instalando plugins populares para desarrollo..."
    
    local custom_plugins_dir="$TARGET_HOME/.oh-my-zsh/custom/plugins"
    
    # Plugins a instalar
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
        ["you-should-use"]="https://github.com/MichaelAquilina/zsh-you-should-use"
        ["zsh-nvm"]="https://github.com/lukechilds/zsh-nvm"
    )
    
    for plugin in "${!plugins[@]}"; do
        local plugin_dir="$custom_plugins_dir/$plugin"
        if [ -d "$plugin_dir" ]; then
            log_info "Plugin $plugin ya está instalado."
        else
            log_info "Instalando plugin $plugin..."
            su - "$TARGET_USER" -c "git clone --depth=1 ${plugins[$plugin]} $plugin_dir"
        fi
    done
    
    # Configurar plugins en .zshrc
    local zshrc="$TARGET_HOME/.zshrc"
    if [ -f "$zshrc" ]; then
        # Lista de plugins a configurar (incluyendo los que vienen con oh-my-zsh)
        local plugin_list="git docker docker-compose node npm nvm python pip sudo copypath copyfile dirhistory history extract web-search zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search you-should-use zsh-nvm"
        
        # Reemplazar la línea de plugins
        if grep -q "^plugins=(" "$zshrc"; then
            sed -i "s/^plugins=(.*/plugins=($plugin_list)/" "$zshrc"
        else
            echo "plugins=($plugin_list)" >> "$zshrc"
        fi
        
        log_info "Plugins configurados en .zshrc"
    fi
    
    log_info "Plugins instalados correctamente."
}

# 6. Importar configuraciones de .bashrc a .zshrc
import_bashrc_config() {
    log_step "Importando configuraciones de .bashrc a .zshrc..."
    
    local bashrc="$TARGET_HOME/.bashrc"
    local zshrc="$TARGET_HOME/.zshrc"
    
    if [ ! -f "$bashrc" ]; then
        log_warn "No se encontró .bashrc para importar."
        return
    fi
    
    if [ ! -f "$zshrc" ]; then
        log_warn "No se encontró .zshrc. Creando uno nuevo..."
        touch "$zshrc"
        chown "$TARGET_USER:$TARGET_USER" "$zshrc"
    fi
    
    # Crear backup de .zshrc
    cp "$zshrc" "${zshrc}.bak-$(date +%Y%m%d-%H%M%S)"
    
    # Marcador para identificar las importaciones
    local marker="# === Imported from .bashrc ==="
    local end_marker="# === End of .bashrc imports ==="
    
    # Verificar si ya se importó
    if grep -q "$marker" "$zshrc"; then
        log_info "Las configuraciones de .bashrc ya fueron importadas previamente."
        return
    fi
    
    # Extraer configuraciones útiles de .bashrc
    local temp_import=$(mktemp)
    
    echo "" >> "$temp_import"
    echo "$marker" >> "$temp_import"
    echo "# Importado automáticamente por debian-powerkit" >> "$temp_import"
    echo "" >> "$temp_import"
    
    # Importar aliases
    grep -E "^alias " "$bashrc" >> "$temp_import" 2>/dev/null || true
    
    # Importar exports (excepto PATH que puede causar conflictos)
    grep -E "^export " "$bashrc" | grep -v "^export PATH=" >> "$temp_import" 2>/dev/null || true
    
    # Importar funciones (bloques function name() { ... })
    # Esto es más complejo, importamos solo las líneas que definen funciones simples
    grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" "$bashrc" >> "$temp_import" 2>/dev/null || true
    
    # Importar variables de entorno personalizadas
    grep -E "^[A-Z_][A-Z0-9_]*=" "$bashrc" | grep -v "^PATH=" >> "$temp_import" 2>/dev/null || true
    
    echo "" >> "$temp_import"
    echo "$end_marker" >> "$temp_import"
    echo "" >> "$temp_import"
    
    # Agregar al final de .zshrc
    cat "$temp_import" >> "$zshrc"
    rm -f "$temp_import"
    
    # Asegurar propietario correcto
    chown "$TARGET_USER:$TARGET_USER" "$zshrc"
    
    log_info "Configuraciones de .bashrc importadas a .zshrc"
}

# 7. Configuraciones adicionales para desarrollo
setup_dev_config() {
    log_step "Aplicando configuraciones adicionales para desarrollo..."
    
    local zshrc="$TARGET_HOME/.zshrc"
    
    # Verificar si ya se aplicó la configuración
    if grep -q "# === Debian PowerKit Dev Config ===" "$zshrc"; then
        log_info "Configuraciones de desarrollo ya aplicadas."
        return
    fi
    
    # Agregar configuraciones adicionales
    cat >> "$zshrc" << 'EOF'

# === Debian PowerKit Dev Config ===

# Historial mejorado
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Navegación mejorada
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Autocompletado mejorado
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Atajos de teclado para history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases útiles para desarrollo
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'

# === End of Debian PowerKit Dev Config ===
EOF
    
    chown "$TARGET_USER:$TARGET_USER" "$zshrc"
    log_info "Configuraciones de desarrollo aplicadas."
}

# 8. Cambiar shell por defecto a zsh
set_default_shell() {
    log_step "Configurando zsh como shell por defecto..."
    
    local current_shell=$(getent passwd "$TARGET_USER" | cut -d: -f7)
    local zsh_path=$(which zsh)
    
    if [ "$current_shell" = "$zsh_path" ]; then
        log_info "zsh ya es el shell por defecto para $TARGET_USER."
        return
    fi
    
    # Verificar que zsh está en /etc/shells
    if ! grep -q "^$zsh_path$" /etc/shells; then
        echo "$zsh_path" >> /etc/shells
    fi
    
    # Cambiar el shell
    chsh -s "$zsh_path" "$TARGET_USER"
    
    log_info "Shell por defecto cambiado a zsh para $TARGET_USER."
}

# --- Menú Interactivo y Ejecución Principal ---

main() {
    log_info "Inicio de la configuración de zsh con Oh My Zsh y Powerlevel10k."
    
    # Verificar si dialog está instalado
    if ! command_exists dialog; then
        log_warn "'dialog' no está instalado. Instalando..."
        apt-get update && apt-get install -y dialog
    fi
    
    # Mostrar menú de selección
    OPTIONS=(
        1 "Instalar zsh" on
        2 "Instalar Oh My Zsh" on
        3 "Instalar tema Powerlevel10k" on
        4 "Instalar Nerd Fonts (MesloLGS NF)" on
        5 "Instalar plugins de desarrollo" on
        6 "Importar configuraciones de .bashrc" on
        7 "Aplicar configuraciones de desarrollo" on
        8 "Establecer zsh como shell por defecto" on
    )

    CHOICES=$(dialog --clear \
                    --backtitle "Debian PowerKit - Configuración de Zsh" \
                    --title "Configuración de Zsh con Oh My Zsh y Powerlevel10k" \
                    --checklist "Usa la barra espaciadora para seleccionar/deseleccionar.\nTodos los componentes están preseleccionados por defecto." \
                    20 75 8 \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

    clear

    if [ -z "$CHOICES" ]; then
        log_warn "No se seleccionó ningún componente. Saliendo."
        exit 0
    fi

    log_info "Componentes seleccionados: $CHOICES"

    # Ejecutar en orden
    if [[ $CHOICES == *"1"* ]]; then install_zsh; fi
    if [[ $CHOICES == *"2"* ]]; then install_oh_my_zsh; fi
    if [[ $CHOICES == *"3"* ]]; then install_powerlevel10k; fi
    if [[ $CHOICES == *"4"* ]]; then install_nerd_fonts; fi
    if [[ $CHOICES == *"5"* ]]; then install_plugins; fi
    if [[ $CHOICES == *"6"* ]]; then import_bashrc_config; fi
    if [[ $CHOICES == *"7"* ]]; then setup_dev_config; fi
    if [[ $CHOICES == *"8"* ]]; then set_default_shell; fi

    echo ""
    log_info "╔═══════════════════════════════════════════════════════════╗"
    log_info "║  ✓ ¡Configuración de Zsh completada!                      ║"
    log_info "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    log_info "Para aplicar los cambios, ejecuta uno de los siguientes comandos:"
    echo ""
    echo -e "   ${CYAN}1. Inicia una nueva sesión de terminal${NC}"
    echo -e "   ${CYAN}2. Ejecuta: ${GREEN}su - $TARGET_USER${NC}"
    echo -e "   ${CYAN}3. Ejecuta: ${GREEN}zsh${NC} (para probar sin cambiar de sesión)"
    echo ""
    log_warn "IMPORTANTE: Configura tu emulador de terminal para usar la fuente 'MesloLGS NF'"
    log_warn "para que los iconos de Powerlevel10k se muestren correctamente."
    echo ""
    log_info "La primera vez que inicies zsh, Powerlevel10k te guiará por su configuración."
    echo ""
}

# Iniciar la ejecución
main
