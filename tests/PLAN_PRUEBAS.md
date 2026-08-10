# Plan de pruebas

| ID | Escenario | Resultado esperado |
|---|---|---|
| P01 | EjecuciÃ³n normal | Respaldo, checksum, log y reporte creados |
| P02 | Origen inexistente | Mensaje controlado y cÃ³digo distinto de cero |
| P03 | Origen sin lectura | El sistema rechaza la ejecuciÃ³n |
| P04 | Destino sin escritura | El sistema no crea archivos parciales |
| P05 | Respaldo daÃ±ado | La verificaciÃ³n detecta el daÃ±o |
| P06 | Ruta con espacios | El respaldo termina correctamente |
| P07 | ConfiguraciÃ³n ausente | Se muestra la ruta esperada del archivo |
| P08 | Dependencia ausente | Se identifica el comando faltante |
| P09 | Correo deshabilitado | El reporte se guarda localmente |
| P10 | RetenciÃ³n vencida | Se eliminan solo archivos `backup_*.tar.gz` antiguos |
