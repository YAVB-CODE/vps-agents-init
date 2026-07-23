# Resumen diario del Vault (7 AM)

## Metadatos

- id: daily-vault-summary
- tipo: recordatorio
- schedule: "0 7 * * *"        # cron: todos los días a las 07:00
- zona_horaria: America/Bogota
- notificar: siempre           # opciones: siempre | solo-si-falla | nunca
- activa: false

## Descripción

Cada mañana a las 7 AM, enviar un resumen de la actividad del vault de Obsidian
correspondiente al día anterior, para arrancar el día con contexto.

Requiere el addon instalado: `optional/obsidian-vault/install.sh`.

## Procedimiento

1. Determinar la ventana: desde las 00:00 hasta las 23:59 del día anterior.
2. Detectar notas creadas o modificadas en ese rango dentro de `VAULT_DIR`
   (por fecha de modificación de archivo o por metadatos de la nota).
3. Generar un resumen breve que incluya:
   - Notas nuevas y notas editadas.
   - Temas o proyectos principales tocados.
   - Tareas pendientes o TODOs detectados.
4. Enviar el resumen por el canal de recordatorio configurado del agente.

## Notificación

- Enviar siempre a las 07:00 en la zona horaria indicada.
- Si el día anterior no hubo actividad, enviar un mensaje corto indicándolo.

## Criterio de éxito

- El resumen llega a las 07:00 y refleja fielmente la actividad del día anterior.
- Es conciso y accionable (no un volcado completo de las notas).
