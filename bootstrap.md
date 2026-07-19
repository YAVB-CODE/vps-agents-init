# Bootstrap — vps-agents-init

## Propósito de este repositorio

Este repositorio existe para inicializar servidores VPS y desplegar agentes autónomos con un entorno consistente. Centraliza la infraestructura del servidor, los scripts de instalación por agente, y el contenido versionado de skills, reglas y guardrails.

Todo agente desplegado desde este repo debe operar con el mismo conjunto de capacidades, convenciones y límites definidos aquí.

## Tu primera tarea

Al arrancar por primera vez, debes:

1. Leer este archivo por completo.
2. Explorar e instalar el contenido de:
   - `./skills/` — capacidades y procedimientos del agente
   - `./rules/` — convenciones y comportamiento esperado
   - `./guardrails/` — límites, políticas y restricciones de seguridad
   - `./tasks/` — tareas recurrentes que debes programar en tu herramienta de recordatorio/scheduling
3. Instalar cada archivo en las ubicaciones que correspondan a **tu** entorno.
4. Conectar tu memoria persistente (vault de Obsidian) desde `VAULT_DIR` en tu `.env`.
5. Programar cada tarea de `./tasks/` (ver sección "Tareas recurrentes").
6. Confirmar que todo quedó activo antes de reportar que estás listo.

## Estructura del repositorio

```
vps-agents-init/
├── bootstrap.md    ← estás aquí
├── init/           ← scripts de infraestructura del VPS (no es tu responsabilidad)
├── agents/         ← scripts de instalación por agente
├── skills/         ← habilidades disponibles
├── rules/          ← reglas de operación
├── guardrails/     ← restricciones obligatorias
└── tasks/          ← tareas recurrentes (recordatorios y acciones programadas)
```

## Memoria persistente

Tu vault de Obsidian vive dentro de tu carpeta de agente (variable `VAULT_DIR` en tu `.env`, por defecto `/opt/<agente>/obsidian-vault`).

Úsalo para:

- Apuntes, contexto y decisiones entre sesiones
- Notas que deben persistir más allá de una conversación
- Referencias y conocimiento acumulado del entorno

Lee y escribe en el vault como tu memoria de largo plazo. Los cambios deben committearse y pushearse al repositorio remoto cuando corresponda.

## Tareas recurrentes

La carpeta `tasks/` contiene una tarea por archivo `.md`. Son descripciones
**declarativas**: tú las traduces a tu propia herramienta de recordatorio o
scheduling. No son crontabs literales del sistema.

Cada archivo incluye un bloque `## Metadatos` con estos campos:

| Campo | Descripción |
|-------|-------------|
| `id` | Identificador único de la tarea |
| `tipo` | `accion` (ejecutas algo) o `recordatorio` (avisas/reportas) |
| `schedule` | Expresión cron estándar que define la frecuencia |
| `zona_horaria` | Zona horaria en la que se interpreta `schedule` |
| `notificar` | `siempre`, `solo-si-falla` o `nunca` |
| `activa` | `true`/`false`; si es `false`, no la programes |

Al arrancar:

1. Lee cada archivo de `tasks/`.
2. Programa las tareas con `activa: true` en tu herramienta usando `schedule` y `zona_horaria`.
3. Sigue el `## Procedimiento` de cada tarea al ejecutarla.
4. Respeta la política de `notificar`.

Los cambios a las tareas se versionan en este repositorio; no las edites en caliente.

## Servidores MCP

La carpeta `mcp/` define los servidores MCP que el agente puede conectar:

- `mcp/servers/*.conf` — una definición **declarativa** por servidor (nombre,
  `AUTH_TYPE`, nombres de variables, comando de registro). No contiene secretos.
- `mcp/install-mcp.sh` — menú interactivo que autentica cada servidor según su
  `AUTH_TYPE` (`token` u `oauth`) y guarda los secretos en `MCP_SECRETS_FILE`
  (por defecto `${INSTALL_DIR}/.mcp.env`, permisos `600`, fuera de git).
- Wrapper: `bin/setup-mcp`.

Puntos clave para un VPS **headless**:

- El login OAuth se hace en la **máquina local** del operador (o por device flow);
  al VPS solo llega el `token`/`refresh_token`, que se auto-renueva.
- Los secretos nunca se versionan (ver `guardrails/no-secrets.md`); solo se
  referencian por nombre.

Al arrancar, verifica qué servidores MCP están configurados en `MCP_SECRETS_FILE`
y repórtalo. Para conectar uno nuevo, ejecuta `bin/setup-mcp`.

## Criterio de éxito

- Conoces el propósito del repo y tu rol dentro de él.
- Cada skill, rule y guardrail está instalado en tu entorno.
- Tu vault de Obsidian está accesible en `VAULT_DIR`.
- Cada tarea activa de `tasks/` quedó programada en tu herramienta de recordatorio.
- Puedes listarlos o verificar que están cargados.
- Estás listo para recibir tareas.

## Notas

- No modifiques el contenido de `skills/`, `rules/` o `guardrails/` en caliente; los cambios deben versionarse en este repositorio.
- Los scripts en `init/` son responsabilidad del operador humano o del proceso de aprovisionamiento, no del agente.
- Si encuentras un skill, rule o guardrail que no puedes instalar en tu entorno, repórtalo antes de continuar.
