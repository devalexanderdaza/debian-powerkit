#!/bin/bash

echo "=== Configurando IDEs ==="

# Crear directorio de configuración de VSCode si no existe
VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
CURSOR_CONFIG_DIR="$HOME/.config/Cursor/User"
KIRO_CONFIG_DIR="$HOME/.config/Kiro/User"

mkdir -p "$VSCODE_CONFIG_DIR"
mkdir -p "$CURSOR_CONFIG_DIR" 
mkdir -p "$KIRO_CONFIG_DIR"

# Copiar configuración a todos los IDEs
cp vscode_settings.json "$VSCODE_CONFIG_DIR/settings.json"
cp vscode_settings.json "$CURSOR_CONFIG_DIR/settings.json"
cp vscode_settings.json "$KIRO_CONFIG_DIR/settings.json"

echo "=== Instalando extensiones esenciales ==="

# Lista de extensiones esenciales
EXTENSIONS=(
    "ms-python.python"
    "ms-python.black-formatter"
    "ms-python.flake8"
    "ms-vscode.vscode-typescript-next"
    "bradlc.vscode-tailwindcss"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "ms-vscode.vscode-json"
    "redhat.vscode-yaml"
    "ms-azuretools.vscode-docker"
    "eamodio.gitlens"
    "github.copilot"
    "github.copilot-chat"
    "ms-vscode-remote.remote-containers"
    "ms-vscode.remote-explorer"
    "formulahendry.auto-rename-tag"
    "christian-kohler.path-intellisense"
    "wayou.vscode-todo-highlight"
    "gruntfuggly.todo-tree"
    "ms-vscode.vscode-typescript-next"
)

# Instalar extensiones para cada IDE
for ide in "code" "cursor" "kiro"; do
    if command -v $ide &> /dev/null; then
        echo "Instalando extensiones para $ide..."
        for ext in "${EXTENSIONS[@]}"; do
            $ide --install-extension $ext --force
        done
    fi
done

# Configurar Git para mejores diffs
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

echo "=== Configuración de IDEs completada ==="
echo "Se han configurado VSCode, Cursor y Kiro con las mismas configuraciones"