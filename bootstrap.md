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
3. Instalar cada archivo en las ubicaciones que correspondan a **tu** entorno.
4. Conectar tu memoria persistente (vault de Obsidian) desde `VAULT_DIR` en tu `.env`.
5. Confirmar que todo quedó activo antes de reportar que estás listo.

## Estructura del repositorio

```
vps-agents-init/
├── bootstrap.md    ← estás aquí
├── init/           ← scripts de infraestructura del VPS (no es tu responsabilidad)
├── agents/         ← scripts de instalación por agente
├── skills/         ← habilidades disponibles
├── rules/          ← reglas de operación
└── guardrails/     ← restricciones obligatorias
```

## Agentes disponibles

| Agente | Script de instalación | Descripción |
|--------|----------------------|-------------|
| Hermes | `agents/hermes/install.sh` | Agente autónomo de operaciones |

## Memoria persistente

Tu vault de Obsidian vive dentro de tu carpeta de agente (variable `VAULT_DIR` en tu `.env`, por defecto `/opt/<agente>/obsidian-vault`).

Úsalo para:

- Apuntes, contexto y decisiones entre sesiones
- Notas que deben persistir más allá de una conversación
- Referencias y conocimiento acumulado del entorno

Lee y escribe en el vault como tu memoria de largo plazo. Los cambios deben committearse y pushearse al repositorio remoto cuando corresponda.

## Criterio de éxito

- Conoces el propósito del repo y tu rol dentro de él.
- Cada skill, rule y guardrail está instalado en tu entorno.
- Tu vault de Obsidian está accesible en `VAULT_DIR`.
- Puedes listarlos o verificar que están cargados.
- Estás listo para recibir tareas.

## Notas

- No modifiques el contenido de `skills/`, `rules/` o `guardrails/` en caliente; los cambios deben versionarse en este repositorio.
- Los scripts en `init/` son responsabilidad del operador humano o del proceso de aprovisionamiento, no del agente.
- Si encuentras un skill, rule o guardrail que no puedes instalar en tu entorno, repórtalo antes de continuar.
