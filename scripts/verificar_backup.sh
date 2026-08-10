#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

mostrar_ayuda() {
    printf 'Uso: %s ARCHIVO.tar.gz\nVerifica la integridad y genera un SHA-256.\n' "$(basename "$0")"
}

main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        mostrar_ayuda
        return 0
    fi
    if (( $# != 1 )); then
        mostrar_ayuda >&2
        return 2
    fi

    cargar_configuracion
    requerir_comando tar
    requerir_comando sha256sum

    local archivo="$1"
    if [[ ! -f "$archivo" ]]; then
        registrar ERROR "El respaldo no existe: $archivo"
        printf 'ERROR: el archivo no existe: %s\n' "$archivo" >&2
        return 4
    fi
    if [[ ! -s "$archivo" ]]; then
        registrar ERROR "El respaldo estÃ¡ vacÃ­o: $archivo"
        return 5
    fi
    if ! tar -tzf "$archivo" >/dev/null 2>&1; then
        registrar ERROR "El respaldo estÃ¡ daÃ±ado: $archivo"
        printf 'ERROR: el respaldo estÃ¡ daÃ±ado.\n' >&2
        return 6
    fi

    (cd "$(dirname "$archivo")" && sha256sum "$(basename "$archivo")" > "$(basename "$archivo").sha256")
    registrar INFO "Integridad verificada: $archivo"
    printf '%s.sha256\n' "$archivo"
}

main "$@"
