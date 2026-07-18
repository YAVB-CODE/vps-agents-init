# Monitor Logs

## Descripción

Revisa logs del sistema o de servicios para diagnosticar problemas o confirmar comportamiento.

## Cuándo usar

- Cuando un servicio falla o se comporta de forma inesperada.
- Cuando se necesite confirmar que un despliegue o proceso terminó correctamente.
- Cuando el operador pida un reporte de estado basado en logs.

## Procedimiento

1. Identificar el servicio o proceso relevante.
2. Localizar los logs (journalctl, archivos en /var/log/, logs de la aplicación).
3. Filtrar por ventana de tiempo y nivel de severidad relevante.
4. Resumir hallazgos: errores, warnings, patrones repetidos.
5. Proponer acción correctiva si aplica.

## Comandos útiles

```bash
journalctl -u <servicio> --since "1 hour ago"
journalctl -u <servicio> -f
tail -n 100 /var/log/<archivo>
```

## Criterio de éxito

- Se identificó la causa o se descartaron hipótesis con evidencia de logs.
- El reporte es conciso y accionable.
