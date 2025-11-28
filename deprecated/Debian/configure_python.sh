#!/bin/bash

# Colores para la salida
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Verificar si se ejecuta como root
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${YELLOW}Este script NO debe ejecutarse como root${NC}"
    exit 1
fi

echo -e "${GREEN}=== Configuración de Python ===${NC}"

# Instalar pyenv
echo -e "${BLUE}Instalando pyenv...${NC}"
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

# Configurar variables de entorno para pyenv
echo -e "${BLUE}Configurando variables de entorno...${NC}"
cat << EOF >> ~/.bashrc

# Python environment
export PYTHONUNBUFFERED=1
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=random
export PYTHONWARNINGS=default

# Pyenv configuration
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init -)"
eval "\$(pyenv virtualenv-init -)"

# Python development
export PYTHONDEBUG=1
export PYTHONASYNCIODEBUG=1
export PYTHONDEVMODE=1

# Poetry configuration
export POETRY_CACHE_DIR="\$HOME/.poetry-cache"
export POETRY_VIRTUALENVS_IN_PROJECT=true
export POETRY_VIRTUALENVS_CREATE=true
EOF

# Configurar pip
echo -e "${BLUE}Configurando pip...${NC}"
mkdir -p ~/.pip-cache
mkdir -p ~/.config/pip

cat << EOF > ~/.config/pip/pip.conf
[global]
cache-dir = ~/.pip-cache
disable-pip-version-check = true
timeout = 60
retries = 3
index-url = https://pypi.org/simple
trusted-host = pypi.org
              pypi.python.org
              files.pythonhosted.org

[install]
no-warn-script-location = false
no-binary = :none:
prefer-binary = true

[freeze]
timeout = 60

[wheel]
no-deps = false
EOF

# Instalar uv (reemplazo rápido de pip)
echo -e "${BLUE}Instalando uv...${NC}"
curl -LsSf https://astral.sh/uv/install.sh | sh

# Configurar poetry
echo -e "${BLUE}Configurando poetry...${NC}"
mkdir -p ~/.poetry-cache
curl -sSL https://install.python-poetry.org | POETRY_HOME=~/.poetry python3 -

cat << EOF > ~/.config/pypoetry/config.toml
cache-dir = "~/.poetry-cache"
virtualenvs.create = true
virtualenvs.in-project = true
virtualenvs.path = "{project-dir}/.venv"

[repositories]
default = "pypi"

[installer]
parallel = true
no-binary = []
EOF

# Instalar herramientas de desarrollo
echo -e "${BLUE}Instalando herramientas de desarrollo...${NC}"
source ~/.bashrc
pip3 install --user --upgrade pip setuptools wheel
pip3 install --user virtualenv virtualenvwrapper pipenv
pip3 install --user black pylint mypy pytest pytest-cov

echo -e "${GREEN}=== Configuración de Python completada ===${NC}"
echo "Se han realizado las siguientes configuraciones:"
echo "  - Instalado y configurado pyenv"
echo "  - Configurado pip con caché y optimizaciones"
echo "  - Instalado uv para instalación rápida de paquetes"
echo "  - Configurado poetry para gestión de dependencias"
echo "  - Instaladas herramientas de desarrollo esenciales"
echo "  - Configuradas variables de entorno"
echo
echo -e "${YELLOW}Para completar la instalación:${NC}"
echo "1. Reinicia tu terminal o ejecuta: source ~/.bashrc"
echo "2. Instala la última versión de Python:"
echo "   pyenv install 3.14.0"
echo "   pyenv global 3.14.0"