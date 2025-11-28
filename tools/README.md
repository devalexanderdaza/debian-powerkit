# Tools - Herramientas de Mantenimiento

Este directorio contiene herramientas de utilidad para el mantenimiento y monitoreo del sistema.

## 📄 Contenido

### `cleanup.sh` (★ Principal)

Script avanzado de limpieza con menú interactivo y selección de directorios.

### `cleanup_dev.sh`

Script específico para limpieza de entornos de desarrollo.

### `monitor_system.sh`

Herramienta de monitoreo de recursos del sistema.

### `script_limpieza_basica.sh`

Script básico de limpieza del sistema (versión legacy).

## 🧹 cleanup.sh - Limpieza Avanzada

### Características

- **Menú interactivo** con múltiples opciones
- **Selección de directorio** donde ejecutar la limpieza
- **Cálculo de espacio a liberar** antes de confirmar
- **Confirmación de usuario** antes de eliminar
- **Progreso visual** durante la eliminación

### Opciones de Limpieza

#### 1. Limpieza del Sistema

Limpia paquetes y caché del sistema APT.

**Qué hace:**
```bash
apt-get autoremove -y    # Elimina paquetes huérfanos
apt-get clean            # Limpia caché de paquetes
```

**Espacio liberado típico:** 100 MB - 2 GB

**Uso:**
```bash
# Opción 1: Desde el menú
sudo ./cleanup.sh
# Selecciona: 1. Limpieza del Sistema

# Opción 2: Directamente
sudo ./cleanup.sh --system
```

**Cuándo usar:**
- ✅ Después de actualizar el sistema
- ✅ Regularmente (mensual)
- ✅ Cuando el espacio es limitado

**Seguro:** Sí, no elimina paquetes necesarios.

#### 2. Limpieza Profunda de Proyectos

Busca y elimina directorios de desarrollo que ocupan mucho espacio.

**Directorios objetivo:**
- `node_modules` - Dependencias de Node.js
- `build` - Artefactos de compilación
- `dist` - Distribuciones compiladas
- `.venv`, `venv` - Entornos virtuales de Python
- `target` - Compilaciones de Rust/Java
- `vendor` - Dependencias de PHP/Go
- `__pycache__` - Caché de Python
- `.pytest_cache` - Caché de pytest
- `.next` - Build de Next.js
- `.nuxt` - Build de Nuxt.js

**Selección de directorio de búsqueda:**

```
┌─────────────────────────────────────────────────┐
│ ¿Dónde deseas buscar los directorios a limpiar?│
│ 1. Directorio actual                            │
│ 2. Directorio home del usuario                  │
│ 3. Especificar una ruta personalizada           │
└─────────────────────────────────────────────────┘
```

**Uso:**
```bash
# Opción 1: Desde el menú (permite elegir directorio)
./cleanup.sh
# Selecciona: 2. Limpieza Profunda de Proyectos

# Opción 2: Directamente (usa directorio actual)
./cleanup.sh --deep-clean
```

**Ejemplo de ejecución:**

```bash
$ ./cleanup.sh --deep-clean

¿Dónde deseas buscar los directorios a limpiar?
1. Directorio actual (/home/user/projects)
2. Directorio home del usuario (/home/user)
3. Especificar una ruta personalizada
Selecciona una opción [1-3]: 2

[INFO] Buscando en '/home/user' los siguientes directorios: 
       node_modules build dist .venv venv target vendor __pycache__ .pytest_cache .next .nuxt
[WARN] Esta operación puede tomar varios minutos...

Se encontraron 23 directorios para eliminar:
  - /home/user/projects/web-app/node_modules (850 MB)
  - /home/user/projects/api-server/node_modules (620 MB)
  - /home/user/projects/web-app/build (45 MB)
  - /home/user/projects/api-server/dist (32 MB)
  - /home/user/ml-project/.venv (1.2 GB)
  - /home/user/rust-app/target (450 MB)
  - /home/user/projects/frontend/.next (120 MB)
  ...

Espacio total a liberar: 4.87 GB

¿Estás seguro de que deseas eliminar permanentemente estos directorios? [y/n]: y

[INFO] Eliminando directorios...
[1/23] Eliminando /home/user/projects/web-app/node_modules...
[2/23] Eliminando /home/user/projects/api-server/node_modules...
...
[INFO] Limpieza profunda de proyectos completada. Se liberaron aproximadamente 4.87 GB.
```

**Cuándo usar:**
- ✅ Antes de hacer backup del sistema
- ✅ Cuando el disco está lleno
- ✅ Al terminar un proyecto
- ✅ Limpieza periódica (mensual)

**⚠️ Advertencia:** 
- Asegúrate de estar en el directorio correcto
- Estos directorios se pueden regenerar (npm install, pip install, etc.)
- Los cambios son **permanentes** y no se pueden deshacer

**Cómo regenerar después de limpiar:**

```bash
# Node.js
cd proyecto && npm install

# Python
cd proyecto && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt

# Rust
cd proyecto && cargo build

# Go
cd proyecto && go mod download
```

### Uso Avanzado

#### Limpieza Selectiva por Tipo de Proyecto

```bash
# Solo proyectos de Node.js
find ~/projects -name "node_modules" -type d -prune -exec du -sh {} \;

# Solo entornos virtuales de Python
find ~/projects -name ".venv" -o -name "venv" -type d -prune

# Solo builds
find ~/projects -name "build" -o -name "dist" -type d -prune
```

#### Automatizar Limpieza Periódica

```bash
# Crear un cron job para limpieza mensual del sistema
echo "0 0 1 * * sudo /ruta/al/cleanup.sh --system" | crontab -

# O usar un script personalizado
cat > ~/bin/monthly-cleanup.sh << 'EOF'
#!/bin/bash
sudo apt-get autoremove -y
sudo apt-get clean
find ~/projects -name "node_modules" -type d -mtime +30 -exec rm -rf {} \;
EOF
chmod +x ~/bin/monthly-cleanup.sh
```

#### Analizar Antes de Limpiar

```bash
# Ver qué ocupan los node_modules
find . -name "node_modules" -type d -prune -exec du -sh {} \; | sort -h

# Ver directorios más grandes
du -h --max-depth=2 ~/projects | sort -h | tail -20

# Análisis con ncdu (interactivo)
ncdu ~/projects
```

## 🔍 monitor_system.sh - Monitor del Sistema

Herramienta para monitorear recursos en tiempo real.

**Características:**
- Uso de CPU y memoria
- Espacio en disco
- Procesos principales
- Temperatura (si está disponible)

**Uso:**
```bash
./monitor_system.sh
```

## 🗑️ cleanup_dev.sh - Limpieza de Desarrollo

Script especializado para entornos de desarrollo.

**Incluye limpieza de:**
- Cachés de compiladores
- Logs de desarrollo
- Archivos temporales de IDEs
- Históricos de shells

## 💡 Consejos y Mejores Prácticas

### Antes de Limpiar Proyectos

1. **Verifica que tengas los archivos fuente:**
   ```bash
   # Asegúrate de tener package.json, requirements.txt, etc.
   ls -la proyecto/
   ```

2. **Haz commit de cambios importantes:**
   ```bash
   git status
   git add .
   git commit -m "Save work before cleanup"
   ```

3. **Anota configuraciones especiales:**
   ```bash
   # Si usas versiones específicas, anótalas
   node --version
   python --version
   ```

### Después de Limpiar

1. **Reinstala dependencias:**
   ```bash
   npm install    # Node.js
   pip install -r requirements.txt    # Python
   cargo build    # Rust
   ```

2. **Verifica que todo funciona:**
   ```bash
   npm test       # Ejecuta tests
   npm run build  # Verifica el build
   ```

### Limpieza Segura

```bash
# Siempre haz una revisión primero
find ~/projects -name "node_modules" -type d -prune | wc -l

# Calcula espacio antes de eliminar
du -sh ~/projects/*/node_modules | awk '{sum+=$1} END {print sum}'

# Haz un dry-run (sin eliminar)
find ~/projects -name "node_modules" -type d -prune -print
```

## 📊 Estadísticas de Espacio Típico

| Directorio | Tamaño Típico | Regeneración |
|------------|---------------|--------------|
| node_modules | 200-800 MB | 2-5 min |
| .venv (Python) | 100-500 MB | 1-3 min |
| target (Rust) | 500 MB - 2 GB | 5-15 min |
| build/dist | 50-200 MB | 1-5 min |
| vendor (PHP) | 50-300 MB | 1-3 min |
| __pycache__ | 5-50 MB | Automático |

## 🎯 Casos de Uso Comunes

### Caso 1: Disco Lleno de Emergencia

```bash
# 1. Limpieza rápida del sistema
sudo ./cleanup.sh --system

# 2. Limpiar proyectos viejos
./cleanup.sh --deep-clean
# Selecciona: 2. Home del usuario
```

**Espacio liberado esperado:** 3-10 GB

### Caso 2: Mantenimiento Mensual

```bash
# Ejecutar ambas limpiezas
sudo ./cleanup.sh

# Opción 1: Limpieza del sistema
# Opción 2: Limpieza de proyectos (directorio home)
```

### Caso 3: Antes de Actualizar el Sistema

```bash
# Liberar espacio para la actualización
sudo ./cleanup.sh --system
sudo apt-get autoremove
sudo apt-get autoclean
```

### Caso 4: Preparar para Backup

```bash
# Limpiar antes de hacer backup para reducir tamaño
./cleanup.sh --deep-clean
# Ahora tu backup será mucho más pequeño
```

## 🛠️ Solución de Problemas

### "Permission denied" al eliminar

```bash
# Algunos directorios pueden tener permisos especiales
sudo ./cleanup.sh --deep-clean
```

### "Directory not empty"

```bash
# Forzar eliminación
rm -rf directorio/

# O cambiar permisos primero
chmod -R 755 directorio/
rm -rf directorio/
```

### El script tarda mucho

```bash
# Limitar la búsqueda a menos profundidad
find . -maxdepth 3 -name "node_modules" -type d -prune
```

## 📝 Personalización

### Añadir Más Directorios a Limpiar

Edita `cleanup.sh`:

```bash
nano cleanup.sh

# Busca la línea:
TARGET_DIRS=("node_modules" "build" "dist" ...)

# Añade más directorios:
TARGET_DIRS=("node_modules" "build" "dist" ".venv" "venv" "target" "vendor" "coverage" ".gradle")
```

### Crear Alias Útiles

```bash
# Añadir a ~/.bashrc o ~/.zshrc
alias cleanup-npm='find . -name "node_modules" -type d -prune -exec rm -rf {} +'
alias cleanup-py='find . -name ".venv" -o -name "venv" -type d -prune -exec rm -rf {} +'
alias cleanup-build='find . -name "build" -o -name "dist" -type d -prune -exec rm -rf {} +'
```

## 🎓 Recursos Adicionales

- [ncdu - Analizador de disco interactivo](https://dev.yorhel.nl/ncdu)
- [du - Disk Usage](https://man7.org/linux/man-pages/man1/du.1.html)
- [find - Buscar archivos](https://man7.org/linux/man-pages/man1/find.1.html)

## ⚠️ Advertencias Importantes

1. **Los cambios son permanentes** - No hay papelera de reciclaje
2. **Verifica el directorio** antes de confirmar la eliminación
3. **Haz backup** de datos importantes antes de limpiezas masivas
4. **Asegúrate** de poder regenerar las dependencias
5. **No elimines** directorios si no sabes para qué sirven

---

💡 **Tip:** Usa `ncdu ~/projects` para analizar interactivamente qué está ocupando más espacio antes de limpiar.
