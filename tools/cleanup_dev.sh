#!/bin/bash

echo "=== Limpieza del Sistema de Desarrollo ==="
echo "Fecha: $(date)"

# Función para mostrar espacio liberado
show_space_freed() {
    local before=$1
    local after=$(df / | awk 'NR==2{print $3}')
    local freed=$((before - after))
    if [ $freed -gt 0 ]; then
        echo "   ✅ Liberados: ${freed}KB"
    else
        echo "   ℹ️  Sin cambios significativos"
    fi
}

# Obtener espacio inicial
space_before=$(df / | awk 'NR==2{print $3}')

echo ""
echo "🧹 LIMPIANDO CACHÉ DE NODE.JS..."
if [ -d ~/.npm-cache ]; then
    du -sh ~/.npm-cache 2>/dev/null | awk '{print "   Cache npm: " $1}'
    rm -rf ~/.npm-cache/*
fi

if [ -d ~/.yarn-cache ]; then
    du -sh ~/.yarn-cache 2>/dev/null | awk '{print "   Cache yarn: " $1}'
    rm -rf ~/.yarn-cache/*
fi

# Limpiar node_modules pesados (más de 500MB)
echo ""
echo "📦 LIMPIANDO NODE_MODULES PESADOS..."
find $HOME -name "node_modules" -type d -exec du -sh {} \; 2>/dev/null | \
    awk '$1 ~ /[0-9]+[MG]/ {
        size = $1
        path = $2
        if (size ~ /G/ || (size ~ /M/ && $1+0 > 500)) {
            print "   🗑️  " path " (" size ")"
            system("rm -rf \"" path "\"")
        }
    }'

echo ""
echo "🐍 LIMPIANDO CACHÉ DE PYTHON..."
if [ -d ~/.pip-cache ]; then
    du -sh ~/.pip-cache 2>/dev/null | awk '{print "   Cache pip: " $1}'
    rm -rf ~/.pip-cache/*
fi

# Limpiar __pycache__
find $HOME -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find $HOME -name "*.pyc" -delete 2>/dev/null
echo "   ✅ __pycache__ y *.pyc eliminados"

echo ""
echo "🐳 LIMPIANDO DOCKER..."
if command -v docker &> /dev/null && docker info &> /dev/null; then
    # Mostrar espacio usado antes
    docker_space_before=$(docker system df --format "{{.Size}}" | tail -1 2>/dev/null || echo "0B")
    echo "   Espacio Docker antes: $docker_space_before"
    
    # Limpiar contenedores parados
    stopped_containers=$(docker ps -aq --filter "status=exited" | wc -l)
    if [ $stopped_containers -gt 0 ]; then
        docker rm $(docker ps -aq --filter "status=exited") 2>/dev/null
        echo "   ✅ $stopped_containers contenedores parados eliminados"
    fi
    
    # Limpiar imágenes no utilizadas
    docker image prune -f > /dev/null 2>&1
    echo "   ✅ Imágenes no utilizadas eliminadas"
    
    # Limpiar volúmenes no utilizados
    docker volume prune -f > /dev/null 2>&1
    echo "   ✅ Volúmenes no utilizados eliminados"
    
    # Mostrar espacio final
    docker_space_after=$(docker system df --format "{{.Size}}" | tail -1 2>/dev/null || echo "0B")
    echo "   Espacio Docker después: $docker_space_after"
else
    echo "   ⚠️  Docker no disponible"
fi

echo ""
echo "🗂️  LIMPIANDO ARCHIVOS TEMPORALES..."
# Limpiar archivos temporales del usuario
find $HOME -name "*.tmp" -o -name "*.temp" -o -name "*~" -delete 2>/dev/null
echo "   ✅ Archivos temporales eliminados"

# Limpiar logs antiguos de aplicaciones
find $HOME/.config -name "*.log" -mtime +7 -delete 2>/dev/null
find $HOME/.local/share -name "*.log" -mtime +7 -delete 2>/dev/null
echo "   ✅ Logs antiguos eliminados"

echo ""
echo "🔧 LIMPIANDO CACHÉ DEL SISTEMA..."
# Limpiar caché de apt (requiere sudo)
echo "   ⚠️  Para limpiar caché del sistema, ejecuta:"
echo "   sudo apt autoremove && sudo apt autoclean"

echo ""
echo "📊 RESUMEN:"
space_after=$(df / | awk 'NR==2{print $3}')
space_freed=$((space_before - space_after))

if [ $space_freed -gt 0 ]; then
    space_freed_mb=$((space_freed / 1024))
    echo "   🎉 Total liberado: ${space_freed_mb}MB"
else
    echo "   ℹ️  Espacio ya optimizado"
fi

# Mostrar estado actual del disco
df -h / | awk 'NR==2{printf "   💾 Espacio libre: %s / %s (%s usado)\n", $4, $2, $5}'

echo ""
echo "=== Limpieza completada ==="