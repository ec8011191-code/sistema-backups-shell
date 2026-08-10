#!/usr/bin/env bash

# Funciones compartidas por el sistema de respaldos.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${BACKUP_CONFIG:-$PROJECT_ROOT/config/backup.conf}"

cargar_configuracion() {
    if [[ ! -r "$CONFIG_FILE" ]]; then
        printf 'ERROR: no se puede leer la configuraciÃ³n: %s\n' "$CONFIG_FILE" >&2
        return 2
    fi

    # shellcheck source=/dev/null
    source "$CONFIG_FILE"

    local variable
    for variable in ORIGEN DESTINO LOG REPORTES RETENCION_DIAS CORREO_DESTINO ENVIAR_CORREO; do
        if [[ -z "${!variable:-}" ]]; then
            printf 'ERROR: falta la variable %s en %s\n' "$variable" "$CONFIG_FILE" >&2
            return 2
        fi
    done

    if [[ ! "$RETENCION_DIAS" =~ ^[0-9]+$ ]]; then
        printf 'ERROR: RETENCION_DIAS debe ser un entero no negativo.\n' >&2
        return 2
    fi
}

registrar() {
    local nivel="$1"
    shift
    local mensaje="$*"
    local fecha
    fecha="$(date '+%Y-%m-%d %H:%M:%S')"
    mkdir -p "$(dirname "$LOG")"
    printf '%s | %-5s | %s\n' "$fecha" "$nivel" "$mensaje" >> "$LOG"
}

requerir_comando() {
    local comando="$1"
    if ! command -v "$comando" >/dev/null 2>&1; then
        registrar ERROR "Dependencia no instalada: $comando"
        printf 'ERROR: el comando %s no estÃ¡ instalado.\n' "$comando" >&2
        return 3
    fi
}
