#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

main() {
    cargar_configuracion
    local inicio fin duracion archivo reporte
    inicio="$(date +%s)"
    registrar INFO "Inicio del sistema de respaldos"

    if ! archivo="$($SCRIPT_DIR/crear_backup.sh)"; then
        registrar ERROR "El sistema terminÃ³ durante la creaciÃ³n del respaldo"
        return 10
    fi
    if ! "$SCRIPT_DIR/verificar_backup.sh" "$archivo" >/dev/null; then
        registrar ERROR "El sistema terminÃ³ durante la verificaciÃ³n"
        return 11
    fi

    find "$DESTINO" -maxdepth 1 -type f \
        \( -name 'backup_*.tar.gz' -o -name 'backup_*.tar.gz.sha256' \) \
        -mtime "+$RETENCION_DIAS" -print -delete >> "$LOG"

    fin="$(date +%s)"
    duracion="$((fin - inicio))"
    reporte="$($SCRIPT_DIR/generar_reporte.sh "$archivo" "EXITOSO" "$duracion")"
    registrar INFO "Sistema finalizado correctamente. Reporte: $reporte"
    printf 'Respaldo: %s\nReporte: %s\n' "$archivo" "$reporte"
}

main "$@"
