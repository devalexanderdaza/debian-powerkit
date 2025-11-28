#!/bin/bash
# script_gestion_energia.sh
# Muestra información y permite cambiar los perfiles de energía usando powerprofilesctl.

echo "### Gestión de Perfiles de Energía ###"
echo ""

# Comprobar si powerprofilesctl está disponible
if ! command -v powerprofilesctl &> /dev/null; then
    echo "El comando 'powerprofilesctl' no se encontró."
    echo "Asegúrate de que el paquete 'power-profiles-daemon' esté instalado."
    echo "Puedes intentar instalarlo con: sudo apt update && sudo apt install power-profiles-daemon"
    exit 1
fi

echo "--- Estado del Servicio power-profiles-daemon ---"
systemctl status power-profiles-daemon.service --no-pager # --no-pager para evitar la paginación en scripts
echo ""
echo "--- Perfiles de Energía Disponibles ---"
powerprofilesctl list
echo ""
CURRENT_PROFILE=$(powerprofilesctl get)
echo "--- Perfil de Energía Activo Actualmente ---"
echo "$CURRENT_PROFILE"
echo ""

# Menú para cambiar el perfil
PS3="Selecciona una opción para cambiar el perfil (o 'q' para salir): "
options=("Establecer 'power-saver'" "Establecer 'balanced'" "Establecer 'performance'" "Salir")

select opt in "${options[@]}"; do
    case $opt in
        "Establecer 'power-saver'")
            echo "Estableciendo perfil a 'power-saver'..."
            # Intentar sin sudo primero, luego con sudo si falla (algunos sistemas lo requieren)
            if powerprofilesctl set power-saver; then
                echo "Perfil cambiado a 'power-saver'."
            elif sudo powerprofilesctl set power-saver; then
                echo "Perfil cambiado a 'power-saver' (con sudo)."
            else
                echo "Error al cambiar el perfil. Intenta ejecutar el script con sudo o revisa los permisos."
            fi
            break
            ;;
        "Establecer 'balanced'")
            echo "Estableciendo perfil a 'balanced'..."
            if powerprofilesctl set balanced; then
                echo "Perfil cambiado a 'balanced'."
            elif sudo powerprofilesctl set balanced; then
                echo "Perfil cambiado a 'balanced' (con sudo)."
            else
                echo "Error al cambiar el perfil."
            fi
            break
            ;;
        "Establecer 'performance'")
            echo "Estableciendo perfil a 'performance'..."
            if powerprofilesctl set performance; then
                echo "Perfil cambiado a 'performance'."
            elif sudo powerprofilesctl set performance; then
                echo "Perfil cambiado a 'performance' (con sudo)."
            else
                echo "Error al cambiar el perfil."
            fi
            break
            ;;
        "Salir")
            echo "Saliendo sin cambios."
            break
            ;;
        *) echo "Opción inválida $REPLY";;
    esac
done

echo ""
echo "--- Nuevo Perfil de Energía Activo ---"
powerprofilesctl get
echo ""
echo "Script finalizado."
