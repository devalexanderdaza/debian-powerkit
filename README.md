# 🚀 Debian PowerKit

[![Debian](https://img.shields.io/badge/Debian-13%20(Trixie)-A81D33?logo=debian)](https://www.debian.org/)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/devalexanderdaza/debian-powerkit)](https://github.com/devalexanderdaza/debian-powerkit/releases)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

> **Tu kit de herramientas definitivo para Debian 13** - Automatiza la configuración, optimización y mantenimiento de tu sistema con un solo comando.

## 📋 Descripción

**Debian PowerKit** es una colección completa de scripts Bash para automatizar la configuración, optimización y mantenimiento de sistemas Debian 13 (Trixie) orientados al desarrollo de software. Este conjunto de herramientas te permite configurar un entorno de desarrollo completo, aplicar optimizaciones de rendimiento probadas y mantener el sistema limpio con un mínimo esfuerzo.

## ✨ Características Principales

- 🎯 **Menú interactivo unificado** con interfaz `dialog`
- 🔧 **Configuración automatizada** de entornos de desarrollo
- ⚡ **Optimizaciones de rendimiento** para CPU, memoria y red
- 🧹 **Herramientas de limpieza avanzadas** para liberar espacio
- 💾 **Sistema de respaldos automáticos** antes de modificar configuraciones
- 🔄 **Idempotencia garantizada** - seguro ejecutar múltiples veces
- 📝 **Documentación completa** para cada módulo

## 🚀 Inicio Rápido

### Prerrequisitos

- Debian 13 (Trixie) o superior
- Acceso root o sudo
- Conexión a Internet

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/devalexanderdaza/debian-powerkit.git
cd debian-powerkit

# Hacer ejecutable el script principal
chmod +x run.sh

# Ejecutar el menú principal
sudo ./run.sh
```

## 📚 Estructura del Proyecto

```
.
├── run.sh                    # Script principal con menú interactivo
├── setup/                    # Scripts de configuración del entorno
│   └── setup.sh             # Instalador del entorno de desarrollo
├── optimization/            # Scripts de optimización del sistema
│   └── optimize.sh          # Optimizador de rendimiento
├── tools/                   # Herramientas de mantenimiento
│   ├── cleanup.sh           # Limpieza avanzada del sistema
│   ├── cleanup_dev.sh       # Limpieza específica para desarrollo
│   └── monitor_system.sh    # Monitor de recursos del sistema
├── config/                  # Archivos de configuración
│   └── vscode_settings.json # Configuración recomendada para VS Code
├── docs/                    # Documentación adicional
└── deprecated/              # Scripts antiguos (solo referencia)
```

## 🎮 Uso

### Menú Principal

El script principal `run.sh` proporciona acceso a todas las funcionalidades:

```bash
sudo ./run.sh
```

Opciones disponibles:
1. **Configurar Entorno de Desarrollo** - Instala herramientas de desarrollo
2. **Optimizar el Sistema** - Aplica mejoras de rendimiento
3. **Ejecutar Limpieza Avanzada** - Libera espacio en disco
4. **Salir** - Cierra el asistente

### Uso Individual de Scripts

También puedes ejecutar cada script de forma independiente:

#### 1. Configuración del Entorno de Desarrollo

```bash
sudo ./setup/setup.sh
```

**Componentes disponibles:**
- Docker y Docker Compose
- Node.js (mediante NVM)
- Python 3 con pip y venv
- Visual Studio Code

**Ejemplo de uso:**
```bash
# El script mostrará un menú interactivo donde puedes seleccionar
# qué componentes instalar usando la barra espaciadora
sudo ./setup/setup.sh
```

#### 2. Optimización del Sistema

```bash
sudo ./optimization/optimize.sh
```

**Optimizaciones disponibles:**
- Configuración del gobernador de CPU a 'performance'
- Ajuste de swappiness y gestión de memoria
- ZRAM para compresión de RAM
- TCP BBR para mejora de red
- Aumento de límites de inotify (para IDEs)
- Instalación de Preload

**Ejemplo de uso:**
```bash
# Selecciona las optimizaciones que deseas aplicar
sudo ./optimization/optimize.sh

# Las configuraciones se respaldan automáticamente
# Los backups se guardan con formato: archivo.bak-YYYYMMDD-HHMMSS
```

#### 3. Limpieza Avanzada

```bash
sudo ./tools/cleanup.sh
```

**Opciones de limpieza:**
- Limpieza del sistema (apt autoremove, clean)
- Limpieza profunda de proyectos (node_modules, build, dist, etc.)

**Ejemplo de uso:**
```bash
# Limpieza interactiva
./tools/cleanup.sh

# Limpieza solo del sistema
sudo ./tools/cleanup.sh --system

# Limpieza profunda de proyectos
./tools/cleanup.sh --deep-clean
```

**Nota:** La limpieza profunda te permite elegir:
1. Directorio actual
2. Directorio home del usuario
3. Ruta personalizada

Directorios que se buscan y eliminan:
- `node_modules` (Node.js)
- `build`, `dist` (artefactos de compilación)
- `.venv`, `venv` (entornos virtuales de Python)
- `target` (Rust, Java)
- `vendor` (PHP, Go)
- `__pycache__`, `.pytest_cache` (Python)
- `.next`, `.nuxt` (frameworks de JavaScript)

## 🔧 Configuración Avanzada

### Respaldos y Rollback

El script de optimización crea automáticamente copias de seguridad antes de modificar archivos del sistema:

```bash
# Los backups se crean en:
/etc/sysctl.conf.bak-20251128-143022

# Para revertir cambios:
sudo cp /etc/sysctl.conf.bak-20251128-143022 /etc/sysctl.conf
sudo sysctl -p
```

### Idempotencia

Los scripts están diseñados para ser seguros al ejecutarse múltiples veces:

- Verifican si los paquetes ya están instalados
- Actualizan parámetros existentes en lugar de duplicarlos
- Omiten pasos ya completados

### Personalización

Puedes editar los scripts para ajustarlos a tus necesidades:

```bash
# Editar valores de optimización de memoria
nano optimization/optimize.sh

# Agregar más directorios a la limpieza profunda
nano tools/cleanup.sh
```

## 📊 Ejemplos de Resultados

### Antes y Después - Optimización de Memoria

```bash
# Antes
$ free -h
              total        used        free      shared  buff/cache   available
Mem:           15Gi       8.0Gi       2.0Gi       500Mi       5.0Gi       6.5Gi
Swap:         8.0Gi       2.0Gi       6.0Gi

# Después (con ZRAM y swappiness optimizado)
$ free -h
              total        used        free      shared  buff/cache   available
Mem:           15Gi       6.0Gi       4.0Gi       300Mi       5.0Gi       8.5Gi
Swap:         7.5Gi       200Mi       7.3Gi
```

### Limpieza Profunda - Espacio Liberado

```bash
$ ./tools/cleanup.sh --deep-clean

[INFO] Buscando en '/home/user/projects'...
Se encontraron 15 directorios para eliminar:
  - ./project1/node_modules (450 MB)
  - ./project2/node_modules (680 MB)
  - ./project3/build (120 MB)
  ...

Espacio total a liberar: 3.2 GB
```

## 🛡️ Seguridad

- Todos los scripts requieren privilegios de root/sudo
- Se crean respaldos antes de modificar archivos del sistema
- Confirmación del usuario antes de operaciones destructivas
- No se modifican configuraciones de seguridad del sistema

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👤 Autor

**Alexander Daza**
- GitHub: [@devalexanderdaza](https://github.com/devalexanderdaza)

## 🙏 Agradecimientos

- Comunidad de Debian
- Desarrolladores de las herramientas incluidas
- Todos los que han contribuido con feedback y mejoras

## 📞 Soporte

Si encuentras algún problema o tienes preguntas:

1. Revisa la documentación en la carpeta `docs/`
2. Consulta el README específico de cada módulo
3. Abre un issue en GitHub

---

⭐ Si este proyecto te ha sido útil, considera darle una estrella en GitHub!
