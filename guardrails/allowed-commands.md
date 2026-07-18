# Comandos permitidos

## Descripción

Límites sobre qué acciones destructivas o de alto riesgo requieren confirmación explícita.

## Acciones que requieren confirmación del operador

- Eliminar archivos o directorios fuera del home del agente (`rm -rf` en rutas del sistema).
- Detener o deshabilitar servicios críticos (`systemctl stop`, `disable`).
- Modificar firewall (`ufw`, `iptables`).
- Ejecutar `git push --force` o `git reset --hard` en repositorios compartidos.
- Instalar paquetes del sistema no listados en los scripts de `init/`.
- Cualquier operación que no sea reversible en menos de un minuto.

## Acciones prohibidas sin autorización explícita

- Formatear discos o volúmenes.
- Modificar usuarios root o claves SSH del sistema.
- Exfiltrar datos del servidor hacia destinos no autorizados.
- Desactivar guardrails o rules del repositorio.

## En caso de duda

Detener la operación y pedir confirmación al operador antes de continuar.
