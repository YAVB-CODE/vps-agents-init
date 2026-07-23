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
4. Programar cada tarea de `./tasks/` con `activa: true` (ver sección "Tareas recurrentes").
5. Confirmar que todo quedó activo antes de reportar que estás listo.

## Estructura del repositorio

```
vps-agents-init/
├── bootstrap.md    ← estás aquí
├── init/           ← scripts de infraestructura del VPS (no es tu responsabilidad)
├── agents/         ← scripts de instalación por agente
├── optional/       ← addons opcionales (no forman parte del flujo base)
├── skills/         ← habilidades disponibles
├── rules/          ← reglas de operación
├── guardrails/     ← restricciones obligatorias
└── tasks/          ← tareas recurrentes del core
```

## Addons opcionales

Funcionalidad extra que **no se instala automáticamente**. Cada addon tiene su propio README e instalador.

| Addon | Ruta | Descripción |
|-------|------|-------------|
| Obsidian Vault | `optional/obsidian-vault/` | Memoria persistente con vault git en el home del agente |

Si el operador instaló un addon, sigue las instrucciones de su README antes de usarlo.

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

Los addons pueden incluir sus propias tareas en `optional/<addon>/tasks/`. Solo prográmalas si el addon está instalado.

Los cambios a las tareas se versionan en este repositorio; no las edites en caliente.


## Criterio de éxito

- Conoces el propósito del repo y tu rol dentro de él.
- Cada skill, rule y guardrail está instalado en tu entorno.
- Cada tarea activa de `tasks/` quedó programada en tu herramienta de recordatorio.
- Puedes listarlos o verificar que están cargados.
- Estás listo para recibir tareas.

## Notas

- No modifiques el contenido de `skills/`, `rules/` o `guardrails/` en caliente; los cambios deben versionarse en este repositorio.
- Los scripts en `init/` son responsabilidad del operador humano o del proceso de aprovisionamiento, no del agente.
- Si encuentras un skill, rule o guardrail que no puedes instalar en tu entorno, repórtalo antes de continuar.
