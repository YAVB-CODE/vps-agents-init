# vps-agents-init

Scripts e instrucciones para inicializar un VPS y desplegar agentes autónomos con skills, reglas y guardrails versionados.

## Requisitos

- Ubuntu 22.04 o 24.04 (Debian-compatible)
- Acceso root o sudo
- Conexión a internet

## Inicio rápido

```bash
# Clonar el repositorio en el VPS
git clone <repo-url> /opt/vps-agents-init
cd /opt/vps-agents-init

# Solo preparar el VPS (update, git, herramientas base)
sudo ./bin/setup-vps

# Instalar el agente Hermes completo (VPS + agente)
sudo ./bin/setup-agent hermes
```

## Estructura

| Ruta | Descripción |
|------|-------------|
| `bootstrap.md` | Punto de entrada que lee el agente al arrancar |
| `init/` | Scripts de infraestructura del VPS |
| `agents/` | Scripts de instalación por agente |
| `skills/` | Habilidades del agente (agnóstico al LLM) |
| `rules/` | Reglas de operación |
| `guardrails/` | Restricciones y políticas de seguridad |
| `tasks/` | Tareas recurrentes (recordatorios y acciones programadas) |
| `lib/` | Funciones compartidas entre scripts |
| `bin/` | Wrappers de alto nivel |

## Flujo

1. **`init/`** prepara el VPS de forma genérica: actualiza el sistema e instala git y herramientas base. No configura ningún agente.
2. **`agents/hermes/install.sh`** carga su propia `config.env`, instala el runtime y despliega Hermes como `root`.
3. **Hermes** lee `bootstrap.md` y autoinstala skills, rules y guardrails en su entorno.

## Agente Hermes

```bash
sudo ./agents/hermes/install.sh
```

Variables opcionales (ver `agents/hermes/config.env.example`):

| Variable | Default | Descripción |
|----------|---------|-------------|
| `AGENT_NAME` | `hermes` | Nombre del agente |
| `INSTALL_DIR` | `/opt/hermes` | Directorio de instalación |
| `REPO_ROOT` | auto-detectado | Raíz de este repositorio |
| `OBSIDIAN_VAULT_REPO` | — | Repositorio git del vault (memoria) |
| `OBSIDIAN_VAULT_DIR` | `obsidian-vault` | Subcarpeta dentro de `INSTALL_DIR` |

El agente corre como `root` (VPS autónomo con control total), por lo que no se crea ningún usuario dedicado.

Estructura en el VPS tras instalar Hermes:

```text
/opt/vps-agents-init/          ← bootstrap, skills, rules, guardrails
/opt/hermes/                   ← runtime del agente (owner: root)
/opt/hermes/obsidian-vault/    ← memoria persistente (Obsidian)
```

## Logs

Los scripts escriben en `/var/log/vps-agents-init/`.

## Agregar contenido

- **Skills**: agregar archivos `.md` en `skills/`
- **Rules**: agregar archivos `.md` en `rules/`
- **Guardrails**: agregar archivos `.md` en `guardrails/`
- **Tasks**: agregar archivos `.md` en `tasks/` (una tarea recurrente por archivo, con bloque `## Metadatos`)

El agente los descubrirá al leer `bootstrap.md`. No es necesario modificar scripts de instalación.
