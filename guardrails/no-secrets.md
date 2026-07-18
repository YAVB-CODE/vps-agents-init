# Sin secretos en código

## Descripción

Prohibición estricta de exponer, commitear o hardcodear credenciales y secretos.

## Restricciones

- **Nunca** escribir API keys, passwords, tokens o certificados en archivos versionados.
- **Nunca** imprimir secretos en logs o reportes.
- **Nunca** commitear archivos `.env` con valores reales.

## Qué hacer en su lugar

- Usar variables de entorno o archivos `.env` con permisos `600`.
- Referenciar secretos por nombre (`API_KEY`, `DB_PASSWORD`), nunca por valor.
- Si un secreto se expone accidentalmente, reportarlo de inmediato como incidente.

## Archivos sensibles

```
.env
*.pem
*.key
credentials.json
secrets.*
```

Estos archivos no deben aparecer en el repositorio ni en salida de comandos.
