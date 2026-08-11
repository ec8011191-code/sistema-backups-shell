#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

mostrar_ayuda() {
    printf 'Uso: %s ARCHIVO.tar.gz ESTADO [DURACION_SEGUNDOS]\n' "$(basename "$0")"
}

main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        mostrar_ayuda
        return 0
    fi
    if (( $# < 2 || $# > 3 )); then
        mostrar_ayuda >&2
        return 2
    fi

    cargar_configuracion
    local archivo="$1" estado="$2" duracion="${3:-0}"
    local reporte tamano checksum="NO DISPONIBLE"
    mkdir -p "$REPORTES"
    reporte="$REPORTES/reporte_$(date '+%Y-%m-%d_%H%M%S').txt"
    tamano="NO DISPONIBLE"

    if [[ -f "$archivo" ]]; then
        tamano="$(du -h "$archivo" | awk '{print $1}')"
    fi
    if [[ -r "${archivo}.sha256" ]]; then
        checksum="$(awk '{print $1}' "${archivo}.sha256")"
    fi

    {
        printf 'REPORTE DEL SISTEMA DE RESPALDOS\n'
        printf '================================\n'
        printf 'Fecha: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        printf 'Origen: %s\n' "$ORIGEN"
        printf 'Archivo: %s\n' "$archivo"
        printf 'TamaÃ±o: %s\n' "$tamano"
        printf 'SHA-256: %s\n' "$checksum"
        printf 'DuraciÃ³n: %s segundos\n' "$duracion"
        printf 'Estado final: %s\n' "$estado"
        printf '\nÃšltimos eventos:\n'
        tail -n 10 "$LOG" 2>/dev/null || true
    } > "$reporte"

    registrar INFO "Reporte generado: $reporte"
    if [[ "$ENVIAR_CORREO" == "si" ]]; then
        requerir_comando mail
        if mail -s "Reporte de respaldo: $estado" "$CORREO_DESTINO" < "$reporte"; then
            registrar INFO "Reporte enviado a $CORREO_DESTINO"
        else
            registrar ERROR "No se pudo enviar el reporte a $CORREO_DESTINO"
            return 7
        fi
    fi
    printf '%s\n' "$reporte"
}

main "$@"
