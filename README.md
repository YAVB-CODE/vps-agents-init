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

# Configurar usuario del agente (opcional)
cp init/config.env.example init/config.env
# editar init/config.env si necesitas otro usuario o claves SSH

# Solo preparar el VPS (usuario, update, git, herramientas base)
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
| `optional/` | Addons opcionales (p. ej. Obsidian Vault) |
| `skills/` | Habilidades del agente (agnóstico al LLM) |
| `rules/` | Reglas de operación |
| `guardrails/` | Restricciones y políticas de seguridad |
| `tasks/` | Tareas recurrentes (recordatorios y acciones programadas) |
| `lib/` | Funciones compartidas entre scripts |
| `bin/` | Wrappers de alto nivel |

## Flujo

1. **`init/`** prepara el VPS como root (apt, Docker daemon, sudo) y deja git, ownership del repo y Docker client listos para `AGENT_USER`.
2. **`agents/hermes/install.sh`** instala el runtime y despliega Hermes bajo el usuario dedicado (`AGENT_USER`, default `hermes`).
3. **Hermes** lee `bootstrap.md` y autoinstala skills, rules y guardrails en su entorno.
4. **Operación diaria** — git pull, docker, hermes — siempre como `AGENT_USER`, no como root.

## Configuración del VPS (`init/config.env`)

Copiar `init/config.env.example` a `init/config.env` antes de `setup-vps`:

| Variable | Default | Descripción |
|----------|---------|-------------|
| `AGENT_USER` | `hermes` | Usuario dedicado del agente |
| `AGENT_HOME` | `/home/hermes` | Home del usuario |
| `AGENT_SUDO_NOPASSWD` | `true` | Sudo sin contraseña para tareas de sistema |
| `AGENT_PASSWORD` | — | Contraseña de login (opcional; sin ella, solo SSH) |
| `AGENT_SSH_KEY` | — | Clave pública inline (opcional) |
| `AGENT_SSH_KEY_FILE` | — | Ruta a archivo de clave pública (opcional) |
| `AGENT_COPY_ROOT_SSH_KEYS` | `true` | Copiar `authorized_keys` de root si no hay clave configurada |
| `AGENT_GIT_NAME` | `AGENT_USER` | Nombre para `git config --global user.name` |
| `AGENT_GIT_EMAIL` | `AGENT_USER@localhost` | Email para `git config --global user.email` |
| `INSTALL_DOCKER` | `true` | Instalar Docker Engine y agregar al usuario del agente al grupo `docker` |

## Agente Hermes

```bash
sudo ./agents/hermes/install.sh
```

Variables opcionales del agente (ver `agents/hermes/config.env.example`):

| Variable | Default | Descripción |
|----------|---------|-------------|
| `AGENT_NAME` | `hermes` | Nombre del agente |
| `INSTALL_DIR` | `/opt/hermes` | Directorio de instalación |
| `REPO_ROOT` | auto-detectado | Raíz de este repositorio |

El runtime y los archivos del agente corren como `AGENT_USER` (default `hermes`), con sudo sin contraseña para operaciones de sistema cuando `AGENT_SUDO_NOPASSWD=true`.

Estructura en el VPS tras instalar Hermes:

```text
/home/hermes/                  ← usuario del agente (SSH, git config, runtime)
/opt/vps-agents-init/          ← bootstrap, skills, rules, guardrails (owner: hermes)
/opt/hermes/                   ← instalación del agente (owner: hermes)
```

## Addons opcionales

### Obsidian Vault

Memoria persistente con vault git en el home del agente. **No se instala con el flujo base.**

```bash
cp optional/obsidian-vault/config.env.example optional/obsidian-vault/config.env
sudo ./optional/obsidian-vault/install.sh
```

Vault por defecto: `/home/hermes/obsidian-vault`. Ver `optional/obsidian-vault/README.md`.

## Logs

Los scripts escriben en `/var/log/vps-agents-init/`.

## Agregar contenido

- **Skills**: agregar archivos `.md` en `skills/`
- **Rules**: agregar archivos `.md` en `rules/`
- **Guardrails**: agregar archivos `.md` en `guardrails/`
- **Tasks**: agregar archivos `.md` en `tasks/` (una tarea recurrente por archivo, con bloque `## Metadatos`)

El agente los descubrirá al leer `bootstrap.md`. No es necesario modificar scripts de instalación.
