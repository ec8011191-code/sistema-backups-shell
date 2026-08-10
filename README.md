# Sistema de copias de seguridad en Shell

Proyecto acadÃ©mico que automatiza copias de seguridad diarias, verifica su integridad, genera sumas SHA-256, conserva un historial configurable y produce reportes de ejecuciÃ³n.

## Integrantes

- Edson Correa LÃ³pez
- Claudio GalvÃ¡n
- Joshua Coquinche

## Componentes

- `crear_backup.sh`: valida rutas, permisos y espacio; luego crea el archivo comprimido.
- `verificar_backup.sh`: comprueba el archivo `tar.gz` y genera su SHA-256.
- `generar_reporte.sh`: resume el resultado y opcionalmente lo envÃ­a por correo.
- `ejecutar_sistema.sh`: coordina el flujo completo y elimina respaldos vencidos.

## Requisitos

- Ubuntu, Debian o CentOS
- Bash 4 o posterior
- `tar`, `coreutils`, `findutils` y `awk`
- Opcional: `mailutils` para el envÃ­o de correo

## InstalaciÃ³n

```bash
git clone https://github.com/ec8011191-code/sistema-backups-shell.git
cd sistema-backups-shell
cp config/backup.conf.example config/backup.conf
nano config/backup.conf
chmod +x scripts/*.sh
```

Ajuste las rutas de `config/backup.conf`. Este archivo estÃ¡ ignorado por Git para evitar publicar informaciÃ³n local.

## EjecuciÃ³n

```bash
./scripts/ejecutar_sistema.sh
```

TambiÃ©n puede ejecutar cada etapa:

```bash
ARCHIVO="$(./scripts/crear_backup.sh)"
./scripts/verificar_backup.sh "$ARCHIVO"
./scripts/generar_reporte.sh "$ARCHIVO" "EXITOSO" 0
```

## AutomatizaciÃ³n diaria

Ejecute `crontab -e` y agregue, usando rutas absolutas:

```cron
0 2 * * * /home/usuario/sistema-backups-shell/scripts/ejecutar_sistema.sh >> /home/usuario/sistema-backups-shell/logs/cron.log 2>&1
```

## CÃ³digos de salida

- `0`: ejecuciÃ³n correcta.
- `2`: configuraciÃ³n o argumentos invÃ¡lidos.
- `3`: dependencia ausente.
- `4-9`: error de origen, permisos, espacio, compresiÃ³n o integridad.
- `10-11`: fallo de una etapa coordinada.

## Pruebas

Los escenarios previstos estÃ¡n documentados en `tests/PLAN_PRUEBAS.md`. Antes de ejecutar:

```bash
bash -n scripts/*.sh
shellcheck scripts/*.sh
```

No suba respaldos, logs, reportes, contraseÃ±as ni el archivo `config/backup.conf` al repositorio.
