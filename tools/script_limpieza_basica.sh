#!/bin/bash
# script_limpieza_basica.sh

echo "### Actualizando lista de paquetes e instalando actualizaciones ###"
sudo apt update && sudo apt upgrade -y

echo "### Eliminando paquetes innecesarios y dependencias huérfanas ###"
sudo apt autoremove -y

echo "### Limpiando caché de paquetes descargados ###"
sudo apt autoclean -y

echo "### Limpiando caché de miniaturas (puede liberar espacio si usas muchos archivos multimedia) ###"
rm -rf ~/.cache/thumbnails/*

echo "### Forzando TRIM en SSDs (si es aplicable y no se hace automáticamente) ###"
# Ubuntu 24.04 debería gestionar fstrim semanalmente de forma automática si tienes un SSD.
# Puedes verificar con: systemctl status fstrim.timer
# Si quieres forzarlo ahora:
sudo fstrim -av

echo "### Limpieza completada ###"
