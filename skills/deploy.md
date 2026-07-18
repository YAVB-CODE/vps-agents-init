# Deploy

## Descripción

Despliega aplicaciones o servicios en el VPS siguiendo un flujo seguro y verificable.

## Cuándo usar

- Cuando se solicite desplegar código, un servicio o una actualización en el servidor.
- Cuando haya un cambio en la configuración de un servicio en producción.

## Procedimiento

1. Verificar en qué entorno se despliega (staging vs producción).
2. Revisar que no hay secretos hardcodeados en el código a desplegar.
3. Ejecutar el despliegue con el método definido para el proyecto (git pull, docker, script, etc.).
4. Verificar que el servicio responde después del despliegue.
5. Reportar el resultado: éxito, fallo, o rollback realizado.

## Criterio de éxito

- El servicio está activo y responde correctamente.
- No se expusieron secretos durante el proceso.
