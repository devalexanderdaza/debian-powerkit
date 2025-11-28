#!/bin/bash

# Colores para la salida
GREEN="[0;32m"
YELLOW="[1;33m"
RED="[0;31m"
BLUE="[0;34m"
NC="[0m" # Sin color

FSTAB_FILE="/etc/fstab"
BACKUP_FILE="/etc/fstab.bak-$(date +%F-%T)"

# --- Funciones ---

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}¡ERROR! 😟 Este script debe ejecutarse como root.${NC}"
        echo "Por favor, ejecútalo con 'sudo ./optimize_fstab.sh'"
        exit 1
    fi
}

check_status() {
    echo -e "${BLUE}🔎 Verificando opciones de montaje para el sistema de archivos raíz (/).${NC}"
    # Extrae la línea de fstab para el directorio raíz
    local root_mount_line=$(grep -E "^[[:alnum:]#-/]+[[:space:]]+/[[:space:]]+" "$FSTAB_FILE")
    
    if echo "$root_mount_line" | grep -q "noatime"; then
        echo -e "✅ ${GREEN}La opción 'noatime' ya está presente. ¡Optimización activa!${NC}"
        echo "   Línea actual: $root_mount_line"
        return 0 # Optimizado
    elif echo "$root_mount_line" | grep -q "relatime"; then
        echo -e "⚪ ${YELLOW}La opción por defecto 'relatime' está presente.${NC}"
        echo "   Línea actual: $root_mount_line"
        return 2 # Default
    else
        echo -e "⚪ ${YELLOW}No se encontraron opciones explícitas de tiempo de acceso (atime).${NC}"
        return 1 # No optimizado
    fi
}

apply_changes() {
    echo -e "${BLUE}🔧 Añadiendo la opción 'noatime' a $FSTAB_FILE...${NC}"
    
    # 1. Crear una copia de seguridad ANTES de tocar nada
    echo "Creando copia de seguridad en: $BACKUP_FILE"
    cp "$FSTAB_FILE" "$BACKUP_FILE"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error fatal: No se pudo crear la copia de seguridad. Abortando.${NC}"
        exit 1
    fi

    # 2. Modificar fstab usando sed
    local root_mount_line=$(grep -E "^[[:alnum:]#-/]+[[:space:]]+/[[:space:]]+" "$FSTAB_FILE")
    if echo "$root_mount_line" | grep -q "relatime"; then
        echo "Reemplazando 'relatime' con 'noatime'..."
        sed -i -E 's#([[:space:]]/[[:space:]]+.*)relatime(.*)#\1noatime\2#' "$FSTAB_FILE"
    else
        echo "Añadiendo 'noatime' a las opciones existentes..."
        sed -i -E 's#([[:space:]]/[[:space:]]+ext4[[:space:]]+[[:alnum:]=]+)#\1,noatime#' "$FSTAB_FILE"
    fi

    # 3. Verificar el cambio
    echo -e "${GREEN}✅ Modificación completada.${NC}"
    echo "Nueva línea en fstab:"
    echo -e "${GREEN}$(grep -E "^[[:alnum:]#-/]+[[:space:]]+/[[:space:]]+" "$FSTAB_FILE")${NC}"
    echo
    echo -e "${YELLOW}⚠️ ¡IMPORTANTE! Debes reiniciar tu ordenador para que este cambio surta efecto.${NC}"
}

rollback_changes() {
    echo -e "${BLUE}⏪ Buscando y restaurando la copia de seguridad más reciente...${NC}"
    local latest_backup=$(ls -t /etc/fstab.bak-* 2>/dev/null | head -n 1)

    if [ -z "$latest_backup" ]; then
        echo -e "${RED}No se encontró ninguna copia de seguridad creada por este script. No se puede revertir.${NC}"
        return
    fi

    echo "La copia de seguridad más reciente es: $latest_backup"
    echo -e "${RED}¿Estás seguro de que quieres restaurarla? Esto sobreescribirá $FSTAB_FILE.${NC}"
    select yn in "Sí, restaurar" "No, cancelar"; do
        case $yn in
            "Sí, restaurar" ) break;;
            "No, cancelar" ) echo "Rollback cancelado."; return;;
        esac
    done

    cp "$latest_backup" "$FSTAB_FILE"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error fatal: No se pudo restaurar la copia de seguridad. Abortando.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ ¡Rollback completado!${NC}"
    echo "$FSTAB_FILE ha sido restaurado desde $latest_backup."
    echo -e "${YELLOW}⚠️ Por favor, reinicia tu ordenador para aplicar la configuración restaurada.${NC}"
}

# --- Menú Principal ---

check_root
echo -e "${GREEN}--- Script: Optimizador del Sistema de Archivos (fstab) 🗄️ ---${NC}"
echo -e "${YELLOW}Este script añade la opción 'noatime' para reducir el número de escrituras en disco.${NC}"
echo -e "${RED}⚠️  ADVERTENCIA: La modificación de /etc/fstab es una operación delicada. ⚠️${NC}"
echo "Se creará una copia de seguridad fechada en /etc/ antes de cualquier cambio."
echo

check_status
current_status=$?
echo

echo -e "${YELLOW}¿Qué te gustaría hacer?${NC}"

options=("⚡ Aplicar optimización 'noatime'" "⏪ Restaurar desde una copia de seguridad (Rollback)" "🚪 Salir")

select opt in "${options[@]}"; do
    case $opt in
        "⚡ Aplicar optimización 'noatime'")
            if [ $current_status -eq 0 ]; then
                echo "La optimización ya está aplicada. No se necesita ninguna acción."
            else
                apply_changes
            fi
            break
            ;;
        "⏪ Restaurar desde una copia de seguridad (Rollback)")
            rollback_changes
            break
            ;;
        "🚪 Salir")
            break
            ;;
        *) echo "Opción inválida";;
    esac
done

echo -e "${BLUE}👋 ¡Operación finalizada!${NC}"
