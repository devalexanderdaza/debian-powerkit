# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [No publicado]

### Añadido

- **Instalador de Un Comando** (`install.sh`)
  - Instalación rápida con `curl` o `wget`
  - Instalación automática de dependencias (git, curl/wget)
  - Crea enlace simbólico en `~/.local/bin` para acceso fácil
  - Añade automáticamente al PATH
  - Salida con colores e indicadores de progreso
  - Verificación del sistema operativo
  - Manejo de instalaciones existentes
  - Banner ASCII artístico
  - Ejemplos de uso después de la instalación

- **Desinstalador** (`uninstall.sh`)
  - Desinstalación segura con confirmación
  - Elimina directorio de instalación y enlaces simbólicos
  - Limpia configuración del PATH
  - Opción para revertir optimizaciones del sistema
  - Restauración desde backups
  - Eliminación de paquetes instalados (zram, preload)
  - Manejo inteligente de permisos (sudo cuando es necesario)

### Cambiado

- **README.md** actualizado con:
  - Sección de instalación rápida con comando de una línea
  - Instrucciones de desinstalación
  - Badge de release version
  - Mejora en la documentación de instalación

## [1.0.0] - 2025-11-28

### 🎉 Lanzamiento Inicial

#### Añadido

- **Script de Setup Interactivo** (`setup/setup.sh`)
  - Instalación de Docker y Docker Compose
  - Instalación de Node.js mediante NVM
  - Instalación de Python 3 con pip y venv
  - Instalación de Visual Studio Code
  - Menú interactivo con `dialog` para selección de componentes
  - Verificación de instalaciones previas (idempotencia)

- **Script de Optimización del Sistema** (`optimization/optimize.sh`)
  - Configuración del gobernador de CPU a 'performance'
  - Optimización de memoria y swappiness
  - Configuración de ZRAM para compresión de RAM
  - Habilitación de TCP BBR para mejorar rendimiento de red
  - Aumento de límites de inotify para IDEs
  - Instalación de Preload
  - Sistema de respaldos automáticos antes de modificar archivos
  - Menú interactivo para selección de optimizaciones

- **Herramienta de Limpieza Avanzada** (`tools/cleanup.sh`)
  - Limpieza de paquetes del sistema (apt autoremove, clean)
  - Limpieza profunda de proyectos de desarrollo
  - Selección de directorio personalizada (actual, home, o ruta específica)
  - Búsqueda de múltiples tipos de directorios (node_modules, build, dist, .venv, etc.)
  - Cálculo de espacio a liberar antes de confirmar
  - Progreso visual durante la eliminación

- **Script Principal con Menú** (`run.sh`)
  - Menú centralizado para acceder a todas las herramientas
  - Interfaz interactiva con `dialog`
  - Navegación sencilla entre módulos

- **Documentación Completa**
  - README principal con guía de inicio rápido
  - README específico para cada módulo (setup, optimization, tools)
  - Documentación detallada de cada optimización
  - Ejemplos de uso y casos prácticos
  - Guías de solución de problemas
  - Documentación en español

- **Archivos de Proyecto**
  - `.gitignore` configurado para el proyecto
  - `LICENSE` (MIT)
  - `CONTRIBUTING.md` con guías de contribución
  - Estructura de directorios organizada

#### Características

- ✅ Menús interactivos con `dialog`
- ✅ Scripts idempotentes (seguros para ejecutar múltiples veces)
- ✅ Respaldos automáticos antes de modificaciones
- ✅ Verificación de componentes ya instalados
- ✅ Mensajes de log informativos con colores
- ✅ Documentación completa en español

---

## Tipos de Cambios

- `Añadido` para nuevas funcionalidades
- `Cambiado` para cambios en funcionalidad existente
- `Obsoleto` para funcionalidades que serán removidas
- `Removido` para funcionalidades removidas
- `Corregido` para corrección de bugs
- `Seguridad` para vulnerabilidades

---

[1.0.0]: https://github.com/devalexanderdaza/debian-powerkit/releases/tag/v1.0.0
