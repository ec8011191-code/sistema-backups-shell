#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/backup.conf"
DESTINO=""

pausar() {
    printf '\nPresione Enter para continuar...'
    read -r
}

configurar() {
    local nombre origen destino correo
    printf '\nCONFIGURACION DEL SISTEMA\n=========================\n'
    read -rp "Nombre del operador: " nombre
    [[ -n "$nombre" ]] || { printf 'ERROR: ingrese un nombre.\n'; return 1; }

    read -erp "Directorio que desea respaldar: " origen
    [[ -d "$origen" && -r "$origen" ]] || {
        printf 'ERROR: el origen no existe o no se puede leer.\n'; return 1;
    }

    read -erp "Directorio donde guardarÃ¡ el respaldo: " destino
    mkdir -p "$destino"
    [[ -w "$destino" ]] || {
        printf 'ERROR: no se puede escribir en el destino.\n'; return 1;
    }

    read -rp "Correo para el reporte (opcional): " correo
    correo="${correo:-correo@ejemplo.com}"

    cat > "$CONFIG_FILE" <<EOF
ORIGEN="$origen"
DESTINO="$destino"
LOG="$PROJECT_ROOT/logs/backup.log"
REPORTES="$PROJECT_ROOT/reportes"
RETENCION_DIAS=7
CORREO_DESTINO="$correo"
ENVIAR_CORREO="no"
OPERADOR="$nombre"
EOF
    printf 'Configuracion guardada correctamente.\n'
}

ejecutar_respaldo() {
    [[ -f "$CONFIG_FILE" ]] || {
        printf 'ERROR: primero configure el sistema.\n'; return 1;
    }
    "$SCRIPT_DIR/ejecutar_sistema.sh"
}

cargar_destino() {
    [[ -f "$CONFIG_FILE" ]] || {
        printf 'ERROR: primero configure el sistema.\n'; return 1;
    }
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
}

listar_respaldos() {
    cargar_destino || return 1
    printf '\nRESPALDOS GENERADOS\n===================\n'
    find "$DESTINO" -maxdepth 1 -type f -name 'backup_*.tar.gz' \
        -printf '%f - %k KB\n'
}

verificar_ultimo() {
    cargar_destino || return 1
    local archivo
    archivo="$(find "$DESTINO" -maxdepth 1 -type f -name 'backup_*.tar.gz' | sort | tail -n 1)"
    [[ -n "$archivo" ]] || { printf 'ERROR: no existen respaldos.\n'; return 1; }
    "$SCRIPT_DIR/verificar_backup.sh" "$archivo"
    printf 'Resultado: respaldo Ã­ntegro y vÃ¡lido.\n'
}

mostrar_reporte() {
    local reporte
    reporte="$(find "$PROJECT_ROOT/reportes" -maxdepth 1 -type f -name 'reporte_*.txt' | sort | tail -n 1)"
    [[ -n "$reporte" ]] || { printf 'ERROR: no existen reportes.\n'; return 1; }
    cat "$reporte"
}

mostrar_log() {
    local log="$PROJECT_ROOT/logs/backup.log"
    [[ -f "$log" ]] || { printf 'ERROR: todavÃ­a no existe el log.\n'; return 1; }
    tail -n 15 "$log"
}

main() {
    local opcion
    while true; do
        clear
        printf 'SISTEMA INTERACTIVO DE COPIAS DE SEGURIDAD\n'
        printf '==========================================\n'
        printf '1. Configurar sistema\n2. Ejecutar respaldo\n3. Listar respaldos\n'
        printf '4. Verificar Ultimo respaldo\n5. Mostrar Ultimo reporte\n'
        printf '6. Mostrar log\n7. Salir\n\n'
        read -rp "Seleccione una opcion [1-7]: " opcion
        case "$opcion" in
            1) configurar || true; pausar ;;
            2) ejecutar_respaldo || true; pausar ;;
            3) listar_respaldos || true; pausar ;;
            4) verificar_ultimo || true; pausar ;;
            5) mostrar_reporte || true; pausar ;;
            6) mostrar_log || true; pausar ;;
            7) printf 'Programa finalizado.\n'; break ;;
            *) printf 'ERROR: opcion invalida.\n'; pausar ;;
        esac
    done
}

main "$@"
