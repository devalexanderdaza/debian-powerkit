# Optimization - Optimización del Sistema

Este directorio contiene scripts para aplicar optimizaciones de rendimiento en Debian 13, mejorando el uso de CPU, memoria, I/O y red.

## 📄 Contenido

### `optimize.sh`

Script principal interactivo para aplicar optimizaciones de rendimiento del sistema.

## 🎯 Características

- **Menú interactivo** con selección de optimizaciones
- **Sistema de respaldos automático** antes de modificar archivos
- **Idempotencia completa** - seguro ejecutar múltiples veces
- **Optimizaciones reversibles** mediante los backups creados

## ⚡ Optimizaciones Disponibles

### 1. Gobernador de CPU a 'Performance'

Configura la CPU para operar siempre a máxima frecuencia.

**Qué hace:**
- Cambia el gobernador de CPU de todos los núcleos a 'performance'
- Crea un servicio systemd para persistir la configuración
- Mejora el rendimiento en tareas intensivas de CPU

**Cuándo usar:**
- ✅ Sistemas de escritorio con buena refrigeración
- ✅ Workstations de desarrollo
- ✅ Servidores con tareas intensivas
- ❌ Laptops con batería limitada

**Impacto:**
- **Rendimiento:** ⬆️⬆️⬆️ Mayor velocidad de CPU
- **Consumo:** ⬆️⬆️ Mayor consumo energético
- **Temperatura:** ⬆️⬆️ Aumento de temperatura

**Verificación:**
```bash
# Ver gobernador actual
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Ver frecuencias actuales
watch -n 1 "grep MHz /proc/cpuinfo"
```

**Revertir:**
```bash
# Cambiar a modo 'powersave'
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "powersave" | sudo tee $cpu
done

# Deshabilitar el servicio
sudo systemctl disable cpupower.service
```

### 2. Optimización de Memoria y Swappiness

Ajusta cómo el sistema gestiona la memoria RAM y el swap.

**Parámetros configurados:**
```bash
vm.swappiness=10              # Reduce uso de swap (default: 60)
vm.vfs_cache_pressure=50      # Conserva más caché (default: 100)
```

**Qué hace:**
- Reduce la tendencia del sistema a usar swap
- Mantiene más datos en caché de archivos
- Mejora la respuesta del sistema

**Cuándo usar:**
- ✅ Sistemas con suficiente RAM (8GB+)
- ✅ Mejorar respuesta de aplicaciones
- ✅ Reducir uso de disco para swap

**Impacto:**
- **Rendimiento:** ⬆️⬆️ Aplicaciones más rápidas
- **RAM libre:** ⬇️ Menos RAM libre visible
- **Uso de disco:** ⬇️ Menos escrituras a swap

**Verificación:**
```bash
# Ver configuración actual
sysctl vm.swappiness
sysctl vm.vfs_cache_pressure

# Monitorear uso de memoria
watch -n 1 free -h
```

**Valores recomendados:**
```bash
# Para sistemas con mucha RAM (16GB+)
vm.swappiness=5
vm.vfs_cache_pressure=50

# Para sistemas con RAM limitada (4-8GB)
vm.swappiness=10
vm.vfs_cache_pressure=100

# Para servidores
vm.swappiness=1
vm.vfs_cache_pressure=50
```

### 3. ZRAM - Compresión de Memoria

Crea un dispositivo de swap comprimido en RAM.

**Qué hace:**
- Comprime datos en RAM antes de enviarlos a swap
- Usa el 50% de la RAM disponible para ZRAM
- Algoritmo de compresión: LZ4 (rápido)

**Cuándo usar:**
- ✅ Sistemas con RAM limitada (4-8GB)
- ✅ Máquinas virtuales
- ✅ Sistemas con SSD (reduce escrituras)

**Impacto:**
- **RAM efectiva:** ⬆️⬆️ +30-50% de RAM utilizable
- **Rendimiento:** ⬆️ Mejor que swap en disco
- **Vida del SSD:** ⬆️ Menos escrituras

**Verificación:**
```bash
# Ver dispositivos ZRAM
zramctl

# Monitoreo en tiempo real
watch -n 1 "zramctl && echo && free -h"
```

**Ejemplo de salida:**
```
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 lz4          3.8G  2.1G  450M  460M       8 [SWAP]
```

**Configuración avanzada:**
```bash
# Editar /etc/default/zramswap
ALGO=lz4        # Algoritmos: lzo, lz4, lzo-rle, zstd
PERCENT=50      # Porcentaje de RAM a usar (recomendado: 25-50%)
```

### 4. TCP BBR - Optimización de Red

Habilita el algoritmo de control de congestión BBR de Google.

**Qué hace:**
- Mejora el rendimiento de TCP
- Reduce latencia en conexiones lentas
- Mejor aprovechamiento del ancho de banda

**Parámetros configurados:**
```bash
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
```

**Cuándo usar:**
- ✅ Conexiones de alta latencia
- ✅ Servidores web
- ✅ Transferencias de archivos grandes
- ✅ Streaming de video

**Impacto:**
- **Throughput:** ⬆️⬆️ Mejor aprovechamiento del ancho de banda
- **Latencia:** ⬇️⬇️ Reducción de latencia
- **Estabilidad:** ⬆️ Conexiones más estables

**Verificación:**
```bash
# Ver algoritmo actual
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc

# Comprobar que BBR está disponible
sysctl net.ipv4.tcp_available_congestion_control
```

**Benchmarks:**
```bash
# Antes de BBR
$ speedtest-cli
Download: 80 Mbps, Upload: 20 Mbps, Latency: 45ms

# Después de BBR
$ speedtest-cli
Download: 95 Mbps, Upload: 23 Mbps, Latency: 38ms
```

### 5. Aumento de Límite de Inotify

Incrementa el límite de "watches" de archivos del sistema.

**Parámetro configurado:**
```bash
fs.inotify.max_user_watches=524288  # Default: 8192
```

**Qué hace:**
- Permite monitorear más archivos simultáneamente
- Esencial para IDEs y herramientas de desarrollo
- Evita errores "No space left to watch files"

**Cuándo usar:**
- ✅ **Siempre** en sistemas de desarrollo
- ✅ Usar VS Code, WebStorm, IntelliJ
- ✅ Proyectos grandes con muchos archivos
- ✅ Herramientas de build con watch mode

**Problemas que resuelve:**
```bash
# Error típico sin esta optimización
Error: ENOSPC: System limit for number of file watchers reached
```

**IDEs y herramientas que lo necesitan:**
- Visual Studio Code
- WebStorm / IntelliJ IDEA
- Webpack (watch mode)
- Nodemon
- Gulp / Grunt watch
- Jest (watch mode)
- Create React App (desarrollo)

**Verificación:**
```bash
# Ver límite actual
cat /proc/sys/fs/inotify/max_user_watches

# Ver uso actual
find /proc/*/fd -lname "anon_inode:inotify" 2>/dev/null | wc -l
```

### 6. Preload - Precarga de Aplicaciones

Daemon que analiza y precarga aplicaciones frecuentemente usadas.

**Qué hace:**
- Monitorea las aplicaciones que usas
- Precarga en RAM las aplicaciones más usadas
- Reduce el tiempo de inicio de aplicaciones

**Cuándo usar:**
- ✅ Sistemas con RAM suficiente (8GB+)
- ✅ Uso repetitivo de las mismas aplicaciones
- ✅ Mejorar tiempos de inicio

**Impacto:**
- **Inicio de apps:** ⬇️⬇️ 30-70% más rápido
- **RAM usada:** ⬆️ Incremento en uso de RAM
- **Aprendizaje:** 2-3 días para optimización completa

**Verificación:**
```bash
# Ver estado del servicio
systemctl status preload

# Ver estadísticas
sudo cat /var/lib/preload/preload.state

# Monitorear en tiempo real
sudo journalctl -u preload -f
```

**Aplicaciones que más se benefician:**
- Navegadores web (Chrome, Firefox)
- IDEs (VS Code, IntelliJ)
- Editores (Sublime, Atom)
- Clientes de correo
- Aplicaciones de ofimática

## 🚀 Uso

### Modo Interactivo (Recomendado)

```bash
sudo ./optimize.sh
```

**Menú de selección:**
```
┌──────────────────────────────────────────────────────────┐
│ Selección de Optimizaciones                             │
│                                                          │
│ [X] Optimizar gobernador de CPU (a 'performance')       │
│ [X] Optimizar gestión de memoria y swappiness           │
│ [X] Configurar ZRAM para compresión de RAM              │
│ [X] Habilitar TCP BBR para mejorar la red               │
│ [X] Aumentar límite de inotify (para IDEs y watchers)   │
│ [ ] Instalar Preload para acelerar apps                 │
│                                                          │
│        <OK>              <Cancel>                        │
└──────────────────────────────────────────────────────────┘
```

### Desde el Menú Principal

```bash
# Desde la raíz del proyecto
sudo ./run.sh
# Selecciona: 2. Optimizar el Sistema
```

## 💾 Sistema de Respaldos

El script crea automáticamente copias de seguridad antes de modificar archivos:

**Formato de backups:**
```
/etc/sysctl.conf.bak-20251128-143022
/etc/default/zramswap.bak-20251128-143045
```

**Restaurar desde backup:**
```bash
# Listar backups disponibles
ls -lh /etc/*.bak-*

# Restaurar un backup
sudo cp /etc/sysctl.conf.bak-20251128-143022 /etc/sysctl.conf

# Aplicar la configuración restaurada
sudo sysctl -p
```

## 🔄 Revertir Todas las Optimizaciones

```bash
# 1. CPU: Cambiar a modo powersave
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "powersave" | sudo tee $cpu
done
sudo systemctl disable cpupower.service

# 2. Memoria: Restaurar valores por defecto
sudo nano /etc/sysctl.conf
# Cambiar a:
# vm.swappiness=60
# vm.vfs_cache_pressure=100
sudo sysctl -p

# 3. ZRAM: Desinstalar
sudo apt-get remove --purge zram-tools

# 4. BBR: Cambiar a cubic
sudo nano /etc/sysctl.conf
# Cambiar a:
# net.ipv4.tcp_congestion_control=cubic
sudo sysctl -p

# 5. Inotify: Restaurar default
sudo nano /etc/sysctl.conf
# Cambiar a:
# fs.inotify.max_user_watches=8192
sudo sysctl -p

# 6. Preload: Desinstalar
sudo apt-get remove --purge preload
```

## 📊 Perfiles de Optimización Recomendados

### Perfil: Laptop con Batería
```bash
Optimizaciones recomendadas:
- [ ] CPU Performance (reduce batería)
- [X] Optimización de Memoria
- [X] ZRAM
- [X] TCP BBR
- [X] Aumentar Inotify
- [ ] Preload (consume más RAM)
```

### Perfil: Desktop de Desarrollo
```bash
Optimizaciones recomendadas:
- [X] CPU Performance
- [X] Optimización de Memoria
- [X] ZRAM
- [X] TCP BBR
- [X] Aumentar Inotify
- [X] Preload
```

### Perfil: Servidor Web
```bash
Optimizaciones recomendadas:
- [X] CPU Performance
- [X] Optimización de Memoria (swappiness=1)
- [ ] ZRAM (no necesario en servidores)
- [X] TCP BBR
- [ ] Aumentar Inotify (solo si es necesario)
- [ ] Preload (no útil en servidores)
```

## 🛠️ Solución de Problemas

### El sistema se siente lento después de optimizar

```bash
# Verificar uso de CPU
htop

# Si la CPU está al 100% constantemente, cambiar a 'ondemand'
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Errores de "Out of Memory"

```bash
# Aumentar swappiness temporalmente
sudo sysctl vm.swappiness=30

# Verificar si ZRAM está funcionando
zramctl
```

### BBR no se activa

```bash
# Verificar versión del kernel (BBR requiere 4.9+)
uname -r

# Verificar módulos cargados
lsmod | grep tcp_bbr

# Cargar módulo manualmente
sudo modprobe tcp_bbr
```

## 📈 Monitoreo de Rendimiento

### Antes de Optimizar

```bash
# Benchmarks recomendados
sysbench cpu run
sysbench memory run
hdparm -Tt /dev/nvme0n1
speedtest-cli
```

### Después de Optimizar

```bash
# Comparar resultados
sysbench cpu run
# Comparar con resultados anteriores
```

## 🎓 Recursos Adicionales

- [Linux Performance](https://www.brendangregg.com/linuxperf.html)
- [TCP BBR Documentation](https://github.com/google/bbr)
- [ZRAM vs ZSWAP](https://wiki.archlinux.org/title/Zram)
- [Kernel sysctl parameters](https://www.kernel.org/doc/Documentation/sysctl/)

## ⚠️ Advertencias

- **Siempre prueba en un entorno de desarrollo primero**
- Algunas optimizaciones pueden aumentar el consumo energético
- Los backups se crean automáticamente, pero verifica que existan
- Reinicia el sistema después de aplicar las optimizaciones

---

💡 **Tip:** Aplica las optimizaciones gradualmente y monitorea el rendimiento del sistema después de cada cambio.
