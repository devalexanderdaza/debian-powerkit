# Setup - Configuración del Entorno de Desarrollo

Este directorio contiene scripts para configurar automáticamente un entorno de desarrollo completo en Debian 13.

## 📄 Contenido

### `setup.sh`

Script principal e interactivo para instalar y configurar herramientas de desarrollo.

## 🎯 Características

- **Menú interactivo** con selección de componentes
- **Verificación de instalaciones previas** (idempotencia)
- **Instalación automatizada** de múltiples herramientas
- **Configuración post-instalación** automática

## 🛠️ Componentes Disponibles

### 1. Sistema Base

Siempre se instala primero e incluye:
- `build-essential` - Compiladores y herramientas de construcción
- `git` - Control de versiones
- `curl`, `wget` - Herramientas de descarga
- `htop`, `ncdu` - Monitores del sistema
- `zsh` - Shell avanzada
- `dialog` - Para menús interactivos

### 2. Docker y Docker Compose

Instalación completa del motor de contenedores:
- Docker Engine (última versión estable)
- Docker CLI
- Containerd
- Docker Buildx Plugin
- Docker Compose Plugin

**Configuración adicional:**
- Añade el usuario actual al grupo `docker`
- Configura el repositorio oficial de Docker

**Verificación post-instalación:**
```bash
docker --version
docker compose version
```

### 3. Node.js (mediante NVM)

Gestor de versiones de Node.js:
- Instalación de NVM (Node Version Manager)
- Permite instalar múltiples versiones de Node.js
- Gestión sencilla de versiones

**Uso post-instalación:**
```bash
# Recargar el shell o ejecutar:
source ~/.nvm/nvm.sh

# Instalar la última versión LTS
nvm install --lts

# Instalar una versión específica
nvm install 18.19.0

# Listar versiones instaladas
nvm list

# Cambiar de versión
nvm use 18
```

### 4. Python 3

Entorno completo de desarrollo Python:
- Python 3 (última versión disponible en Debian)
- pip (gestor de paquetes)
- venv (entornos virtuales)

**Uso post-instalación:**
```bash
# Crear un entorno virtual
python3 -m venv mi_proyecto

# Activar el entorno
source mi_proyecto/bin/activate

# Instalar paquetes
pip install requests flask django
```

### 5. Visual Studio Code

Editor de código de Microsoft:
- Instalación desde el repositorio oficial
- Última versión estable
- Incluye soporte para extensiones

**Extensiones recomendadas:**
```bash
# Instalar extensiones comunes
code --install-extension ms-python.python
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension ms-azuretools.vscode-docker
```

## 🚀 Uso

### Modo Interactivo (Recomendado)

```bash
sudo ./setup.sh
```

El script mostrará un menú donde puedes:
1. Usar la **barra espaciadora** para seleccionar/deseleccionar componentes
2. Usar las **flechas** para navegar
3. Presionar **Enter** para confirmar la selección

**Ejemplo de menú:**
```
┌─────────────────────────────────────────────────────────┐
│ Selección de Componentes                                │
│                                                          │
│ [X] Instalar Docker y Docker Compose                    │
│ [X] Instalar Node.js (vía NVM)                          │
│ [ ] Instalar Python 3, pip y venv                       │
│ [X] Instalar Visual Studio Code                         │
│                                                          │
│        <OK>              <Cancel>                        │
└─────────────────────────────────────────────────────────┘
```

### Desde el Menú Principal

```bash
# Desde la raíz del proyecto
sudo ./run.sh
# Selecciona: 1. Configurar Entorno de Desarrollo
```

## 📋 Proceso de Instalación

1. **Actualización del sistema**
   ```bash
   apt-get update && apt-get upgrade -y
   ```

2. **Instalación de paquetes base**
   - Instalación de herramientas esenciales
   - Instalación de `dialog` para menús

3. **Presentación del menú interactivo**
   - El usuario selecciona los componentes

4. **Instalación de componentes seleccionados**
   - Para cada componente:
     - Verifica si ya está instalado
     - Si no está, procede con la instalación
     - Configura el componente
     - Reporta el resultado

5. **Finalización**
   - Resumen de lo instalado
   - Instrucciones adicionales si es necesario

## ⚙️ Configuración Post-Instalación

### Docker

Si instalaste Docker, necesitas reiniciar la sesión:
```bash
# Opción 1: Cerrar sesión y volver a entrar

# Opción 2: Ejecutar (temporal)
newgrp docker

# Verificar que funciona sin sudo
docker run hello-world
```

### NVM y Node.js

```bash
# Recargar el perfil del shell
source ~/.bashrc  # o ~/.zshrc si usas zsh

# Instalar Node.js LTS
nvm install --lts

# Configurar como versión por defecto
nvm alias default node
```

### Python

```bash
# Actualizar pip
python3 -m pip install --upgrade pip

# Instalar herramientas comunes
pip3 install virtualenv poetry black pylint
```

## 🔄 Idempotencia

El script es seguro para ejecutar múltiples veces:

- ✅ Verifica cada componente antes de instalarlo
- ✅ Omite componentes ya instalados
- ✅ Actualiza repositorios solo cuando es necesario
- ✅ No sobrescribe configuraciones existentes

**Ejemplo:**
```bash
# Primera ejecución
$ sudo ./setup.sh
[INFO] Instalando Docker...
[INFO] Docker instalado correctamente.

# Segunda ejecución
$ sudo ./setup.sh
[INFO] Docker ya está instalado. Omitiendo.
```

## 🛠️ Solución de Problemas

### Docker no funciona sin sudo

```bash
# Verificar que estás en el grupo docker
groups

# Si no aparece 'docker', añadirlo manualmente
sudo usermod -aG docker $USER

# Reiniciar sesión o ejecutar
newgrp docker
```

### NVM no encontrado después de instalar

```bash
# Recargar el shell
source ~/.bashrc

# O especificar la ruta completa
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### VS Code no abre desde terminal

```bash
# Verificar la instalación
which code

# Si no está en el PATH
sudo update-alternatives --config editor
```

## 📝 Personalización

Puedes modificar el script para añadir más componentes:

```bash
# Editar el script
nano setup.sh

# Añadir una nueva función de instalación
install_rust() {
    if command_exists rustc; then
        log_info "Rust ya está instalado. Omitiendo."
        return
    fi
    
    log_info "Instalando Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    log_info "Rust instalado correctamente."
}

# Añadir al menú
OPTIONS=(
    1 "Instalar Docker y Docker Compose" on
    2 "Instalar Node.js (vía NVM)" on
    3 "Instalar Python 3, pip y venv" on
    4 "Instalar Visual Studio Code" on
    5 "Instalar Rust y Cargo" off  # Nuevo componente
)

# Añadir al switch case
if [[ $CHOICES == *"5"* ]]; then
    install_rust
fi
```

## 🎓 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [NVM GitHub](https://github.com/nvm-sh/nvm)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)
- [VS Code Documentation](https://code.visualstudio.com/docs)

## 📊 Requisitos del Sistema

- **Espacio en disco:** ~5-10 GB (dependiendo de los componentes)
- **RAM:** Mínimo 4 GB (recomendado 8 GB)
- **Conexión a Internet:** Requerida para descargas
- **Permisos:** root/sudo

## ✅ Checklist Post-Instalación

- [ ] Verificar instalación de Docker: `docker --version`
- [ ] Ejecutar contenedor de prueba: `docker run hello-world`
- [ ] Verificar NVM: `nvm --version`
- [ ] Instalar Node.js LTS: `nvm install --lts`
- [ ] Verificar Python: `python3 --version`
- [ ] Verificar pip: `pip3 --version`
- [ ] Abrir VS Code: `code .`
- [ ] Instalar extensiones recomendadas de VS Code

---

💡 **Tip:** Ejecuta este script en un sistema recién instalado para tener un entorno de desarrollo completo en minutos.
