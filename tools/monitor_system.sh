#!/bin/bash

echo "=== Monitor del Sistema para Desarrollo ==="
echo "Fecha: $(date)"
echo "======================================"

# Información del sistema
echo "🖥️  SISTEMA:"
echo "   OS: $(lsb_release -d | cut -f2)"
echo "   Kernel: $(uname -r)"
echo "   Uptime: $(uptime -p)"

# CPU
echo ""
echo "⚡ CPU:"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
cpu_temp=$(sensors 2>/dev/null | grep "Core 0" | awk '{print $3}' | head -1 || echo "N/A")
echo "   Uso: ${cpu_usage}%"
echo "   Temperatura: ${cpu_temp}"
echo "   Procesos activos: $(ps aux | wc -l)"

# Memoria
echo ""
echo "🧠 MEMORIA:"
memory_info=$(free -h | grep Mem)
memory_used=$(echo $memory_info | awk '{print $3}')
memory_total=$(echo $memory_info | awk '{print $2}')
memory_available=$(echo $memory_info | awk '{print $7}')
memory_percent=$(free | grep Mem | awk '{printf("%.1f"), $3/$2 * 100.0}')

echo "   Usada: ${memory_used} / ${memory_total} (${memory_percent}%)"
echo "   Disponible: ${memory_available}"

# Swap
swap_info=$(free -h | grep Swap)
swap_used=$(echo $swap_info | awk '{print $3}')
swap_total=$(echo $swap_info | awk '{print $2}')
echo "   Swap: ${swap_used} / ${swap_total}"

# Procesos que más consumen memoria
echo ""
echo "🔥 TOP PROCESOS (Memoria):"
ps aux --sort=-%mem | head -6 | awk 'NR==1{print "   PID    %MEM  COMMAND"} NR>1{printf "   %-6s %-5s %s\n", $2, $4, $11}'

# Almacenamiento
echo ""
echo "💾 ALMACENAMIENTO:"
df -h / | awk 'NR==2{printf "   Raíz: %s / %s (%s usado)\n", $3, $2, $5}'

# Procesos de desarrollo activos
echo ""
echo "👨‍💻 PROCESOS DE DESARROLLO:"
echo "   Node.js: $(pgrep -f node | wc -l) procesos"
echo "   Python: $(pgrep -f python | wc -l) procesos"
echo "   Docker: $(pgrep -f docker | wc -l) procesos"
echo "   IDEs: $(pgrep -f "code|cursor|kiro" | wc -l) procesos"

# Estado de Docker
if command -v docker &> /dev/null; then
    echo ""
    echo "🐳 DOCKER:"
    if docker info &> /dev/null; then
        echo "   Estado: ✅ Activo"
        echo "   Contenedores: $(docker ps -q | wc -l) ejecutándose"
        echo "   Imágenes: $(docker images -q | wc -l) almacenadas"
        
        # Uso de espacio de Docker
        docker_space=$(docker system df --format "table {{.Type}}\t{{.Size}}" 2>/dev/null | tail -n +2 | awk '{sum+=$2} END {print sum}' || echo "0")
        echo "   Espacio usado: $(docker system df --format "{{.Size}}" | tail -1 2>/dev/null || echo "N/A")"
    else
        echo "   Estado: ❌ Inactivo"
    fi
else
    echo ""
    echo "🐳 DOCKER: ❌ No instalado"
fi

# Red
echo ""
echo "🌐 RED:"
ping -c 1 8.8.8.8 &> /dev/null && echo "   Conectividad: ✅" || echo "   Conectividad: ❌"

# Alertas
echo ""
echo "⚠️  ALERTAS:"
if (( $(echo "$memory_percent > 80" | bc -l) )); then
    echo "   🚨 Memoria alta: ${memory_percent}%"
fi

if (( $(df / | awk 'NR==2{print $5}' | cut -d'%' -f1) > 80 )); then
    echo "   🚨 Disco casi lleno"
fi

if (( $(pgrep -f "code|cursor|kiro" | wc -l) > 2 )); then
    echo "   ⚠️  Múltiples IDEs abiertos (puede afectar rendimiento)"
fi

echo ""
echo "======================================"