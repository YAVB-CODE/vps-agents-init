# Obsidian Vault (addon opcional)

Memoria persistente basada en un vault de Obsidian versionado con git. **No forma parte del flujo base** del VPS ni de la instalación de Hermes.

## Cuándo usarlo

- Quieres que el agente mantenga notas y contexto entre sesiones
- Tienes (o quieres) un repositorio git dedicado para el vault

Si no lo necesitas, ignora este addon. El VPS y el agente funcionan sin él.

## Requisitos

- VPS inicializado (`bin/setup-vps`)
- Agente Hermes instalado (`bin/setup-agent hermes` o `agents/hermes/install.sh`)
- Git configurado para `AGENT_USER` (lo hace el init)

## Instalación

```bash
cd /opt/vps-agents-init
cp optional/obsidian-vault/config.env.example optional/obsidian-vault/config.env
# editar optional/obsidian-vault/config.env

sudo ./optional/obsidian-vault/install.sh
```

## Configuración (`optional/obsidian-vault/config.env`)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `VAULT_DIR` | `$AGENT_HOME/obsidian-vault` | Ruta del vault en el home del agente |
| `OBSIDIAN_VAULT_REPO` | — | Repositorio git del vault (opcional) |
| `OBSIDIAN_VAULT_BRANCH` | `main` | Rama a clonar |
| `AGENT_ENV_FILE` | `/opt/hermes/.env` | `.env` del agente donde se escribe `VAULT_DIR` |

El vault queda en:

```text
/home/hermes/obsidian-vault/    ← owner: hermes
```

## Tareas recurrentes

En `optional/obsidian-vault/tasks/` hay tareas declarativas con `activa: false` por defecto:

- `sync-obsidian-vault.md` — sync git del vault
- `daily-vault-summary.md` — resumen diario de actividad

Tras instalar el addon, activa las que necesites (`activa: true`) y prográmalas en tu herramienta de scheduling.

## Migración desde instalaciones antiguas

Si el vault estaba en `/opt/hermes/obsidian-vault`:

```bash
sudo mv /opt/hermes/obsidian-vault /home/hermes/obsidian-vault
sudo chown -R hermes:hermes /home/hermes/obsidian-vault
sudo ./optional/obsidian-vault/install.sh
```

## Desinstalar

El addon no desinstala archivos automáticamente. Para quitarlo:

1. Elimina `VAULT_DIR=` de `/opt/hermes/.env`
2. Borra el directorio del vault si ya no lo necesitas
3. Desactiva las tareas del addon en tu scheduler
