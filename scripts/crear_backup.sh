#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

mostrar_ayuda() {
    printf 'Uso: %s [--help]\nCrea un respaldo del directorio configurado.\n' "$(basename "$0")"
}

main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        mostrar_ayuda
        return 0
    fi
    if (( $# > 0 )); then
        mostrar_ayuda >&2
        return 2
    fi

    cargar_configuracion
    requerir_comando tar
    requerir_comando df

    if [[ ! -d "$ORIGEN" ]]; then
        registrar ERROR "El directorio de origen no existe: $ORIGEN"
        printf 'ERROR: el directorio de origen no existe: %s\n' "$ORIGEN" >&2
        return 4
    fi
    if [[ ! -r "$ORIGEN" ]]; then
        registrar ERROR "No hay permiso de lectura sobre: $ORIGEN"
        printf 'ERROR: no hay permiso de lectura sobre: %s\n' "$ORIGEN" >&2
        return 5
    fi

    mkdir -p "$DESTINO"
    if [[ ! -w "$DESTINO" ]]; then
        registrar ERROR "No hay permiso de escritura sobre: $DESTINO"
        printf 'ERROR: no hay permiso de escritura sobre: %s\n' "$DESTINO" >&2
        return 6
    fi

    local necesarios disponibles nombre archivo temporal
    necesarios="$(du -sk "$ORIGEN" | awk '{print $1}')"
    disponibles="$(df -Pk "$DESTINO" | awk 'NR==2 {print $4}')"
    if (( disponibles <= necesarios )); then
        registrar ERROR "Espacio insuficiente: necesarios=${necesarios}KB disponibles=${disponibles}KB"
        printf 'ERROR: no hay espacio suficiente para el respaldo.\n' >&2
        return 7
    fi

    nombre="backup_$(basename "$ORIGEN")_$(date '+%Y-%m-%d_%H%M%S').tar.gz"
    archivo="$DESTINO/$nombre"
    temporal="${archivo}.tmp"
    registrar INFO "Inicio del respaldo de $ORIGEN"

    if ! tar -czf "$temporal" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")"; then
        rm -f "$temporal"
        registrar ERROR "FallÃ³ la compresiÃ³n de $ORIGEN"
        return 8
    fi
    if [[ ! -s "$temporal" ]]; then
        rm -f "$temporal"
        registrar ERROR "El respaldo generado estÃ¡ vacÃ­o"
        return 9
    fi

    mv "$temporal" "$archivo"
    registrar INFO "Respaldo creado correctamente: $archivo"
    printf '%s\n' "$archivo"
}

main "$@"
