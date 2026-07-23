#!/usr/bin/env bash
# Addon opcional: instala un vault de Obsidian en el home del agente.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

require_root
init_logging
load_agent_config "$REPO_ROOT" "${SCRIPT_DIR}/config.env"
assert_agent_user

AGENT_ENV_FILE="${AGENT_ENV_FILE:-/opt/hermes/.env}"
VAULT_DIR="${VAULT_DIR:-${AGENT_HOME}/obsidian-vault}"
LEGACY_VAULT_DIR="/opt/hermes/obsidian-vault"

log_info "Instalando addon Obsidian Vault"
log_info "  Usuario:   ${AGENT_USER}"
log_info "  Vault:     ${VAULT_DIR}"
log_info "  Agent env: ${AGENT_ENV_FILE}"

if [[ -d "$LEGACY_VAULT_DIR" && "$VAULT_DIR" != "$LEGACY_VAULT_DIR" && ! -d "$VAULT_DIR" ]]; then
  log_warn "Vault legacy detectado en ${LEGACY_VAULT_DIR}."
  log_warn "Migra manualmente si lo necesitas: mv ${LEGACY_VAULT_DIR} ${VAULT_DIR}"
fi

if [[ -n "${OBSIDIAN_VAULT_REPO:-}" ]]; then
  clone_or_update_repo "$OBSIDIAN_VAULT_REPO" "$VAULT_DIR" "${OBSIDIAN_VAULT_BRANCH:-main}"
else
  log_warn "OBSIDIAN_VAULT_REPO no configurado. Creando directorio vacío en ${VAULT_DIR}."
  ensure_dir_owned_by_agent "$VAULT_DIR"
  if [[ ! -f "${VAULT_DIR}/README.md" ]]; then
    run_as_agent "cat > '${VAULT_DIR}/README.md' << EOF
# Obsidian Vault

Memoria persistente opcional del agente.

Configura OBSIDIAN_VAULT_REPO en optional/obsidian-vault/config.env y reinstala el addon para clonar el repositorio remoto.
EOF"
  fi
fi

ensure_agent_owns_path "$VAULT_DIR"
update_env_var "$AGENT_ENV_FILE" "VAULT_DIR" "$VAULT_DIR"

log_info "Addon Obsidian Vault instalado."
log_info "  VAULT_DIR=${VAULT_DIR} registrado en ${AGENT_ENV_FILE}"
log_info "  Tareas opcionales en ${SCRIPT_DIR}/tasks/ (activar las que necesites)"
