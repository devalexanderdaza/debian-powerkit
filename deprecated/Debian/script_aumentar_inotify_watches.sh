#!/bin/bash
# script_aumentar_inotify_watches.sh
# Aumenta el límite de fs.inotify.max_user_watches para evitar errores
# en herramientas de desarrollo que monitorizan muchos archivos.

# Un valor común y generalmente seguro. Proyectos muy grandes podrían necesitar más.
WATCHES_VALUE=524288

echo "### Aumentando fs.inotify.max_user_watches a $WATCHES_VALUE ###"
echo "Valor actual:"
cat /proc/sys/fs/inotify/max_user_watches

# Aplicar el cambio inmediatamente (no persiste tras reiniciar)
sudo sysctl -w fs.inotify.max_user_watches=$WATCHES_VALUE
echo "Valor actual (aplicado temporalmente): $(cat /proc/sys/fs/inotify/max_user_watches)"

# Para hacerlo permanente después de reiniciar:
SYSCTL_CONF_FILE="/etc/sysctl.conf"
SETTING_KEY="fs.inotify.max_user_watches"

if grep -q "^\s*${SETTING_KEY}\s*=" "$SYSCTL_CONF_FILE"; then
    # Si la clave ya existe, la actualiza
    sudo sed -i "s|^\s*${SETTING_KEY}\s*=.*|${SETTING_KEY}=${WATCHES_VALUE}|" "$SYSCTL_CONF_FILE"
    echo "Entrada existente de ${SETTING_KEY} actualizada en ${SYSCTL_CONF_FILE}."
else
    # Si la clave no existe, la añade al final
    echo "${SETTING_KEY}=${WATCHES_VALUE}" | sudo tee -a "$SYSCTL_CONF_FILE" > /dev/null
    echo "${SETTING_KEY}=${WATCHES_VALUE} añadido a ${SYSCTL_CONF_FILE}."
fi

# Opcionalmente, puedes forzar la recarga de sysctl.conf, aunque el sysctl -w ya lo aplicó para la sesión actual.
# sudo sysctl -p
echo "El cambio se aplicará permanentemente tras el próximo reinicio."
echo "Para aplicar todos los cambios de ${SYSCTL_CONF_FILE} sin reiniciar: sudo sysctl -p"
