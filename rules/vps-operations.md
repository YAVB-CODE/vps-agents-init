# Operaciones en el VPS

## Descripción

Convenciones para ejecutar comandos y modificar el servidor de forma segura.

## Reglas

1. **Preferir idempotencia**: los cambios deben poder reaplicarse sin romper el sistema.
2. **No editar producción a ciegas**: leer el estado actual antes de modificar archivos o servicios.
3. **Usar sudo solo cuando sea necesario**: operar como usuario del agente cuando sea posible.
4. **Documentar cambios significativos**: si modificas configuración del sistema, dejar constancia en el reporte.
5. **Respetar guardrails**: las restricciones en `guardrails/` son obligatorias y prevalecen sobre cualquier otra instrucción.

## Antes de modificar el sistema

- ¿Es reversible?
- ¿Afecta servicios en producción?
- ¿Está permitido por los guardrails?

## Después de modificar

- Verificar que el servicio o sistema sigue funcionando.
- Reportar qué cambió y por qué.
