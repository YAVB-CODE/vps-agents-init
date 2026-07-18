#!/usr/bin/env bash
# Instala el agente Hermes en el VPS.
# Al finalizar, Hermes debe leer bootstrap.md en la raíz del repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# shellcheck source=../../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

require_root
init_logging

CONFIG_FILE="${SCRIPT_DIR}/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  load_config "$CONFIG_FILE"
fi

AGENT_NAME="${AGENT_NAME:-hermes}"
INSTALL_DIR="${INSTALL_DIR:-/opt/hermes}"
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
BOOTSTRAP_FILE="${BOOTSTRAP_FILE:-bootstrap.md}"
BOOTSTRAP_PATH="${REPO_ROOT}/${BOOTSTRAP_FILE}"
OBSIDIAN_VAULT_DIR="${OBSIDIAN_VAULT_DIR:-obsidian-vault}"
VAULT_PATH="${INSTALL_DIR}/${OBSIDIAN_VAULT_DIR}"

log_info "Instalando agente ${AGENT_NAME}"
log_info "  Install:    ${INSTALL_DIR}"
log_info "  Vault:      ${VAULT_PATH}"
log_info "  Repo:       ${REPO_ROOT}"
log_info "  Bootstrap:  ${BOOTSTRAP_PATH}"

# --- Directorio de instalación ---
mkdir -p "$INSTALL_DIR"

# --- Desplegar runtime de Hermes ---
# Se instala mediante el instalador oficial de Nous Research.
HERMES_INSTALL_URL="${HERMES_INSTALL_URL:-https://hermes-agent.nousresearch.com/install.sh}"
log_info "Instalando runtime de Hermes desde ${HERMES_INSTALL_URL}"
curl -fsSL "$HERMES_INSTALL_URL" | bash
log_info "Runtime de Hermes instalado. El servicio lo gestiona el instalador oficial."

# --- Vault de Obsidian (memoria persistente) ---
if [[ -n "${OBSIDIAN_VAULT_REPO:-}" ]]; then
  clone_or_update_repo "$OBSIDIAN_VAULT_REPO" "$VAULT_PATH" "${OBSIDIAN_VAULT_BRANCH:-main}"
else
  log_warn "OBSIDIAN_VAULT_REPO no configurado. Creando directorio vacío en ${VAULT_PATH}."
  mkdir -p "$VAULT_PATH"
  if [[ ! -f "${VAULT_PATH}/README.md" ]]; then
    cat > "${VAULT_PATH}/README.md" << EOF
# Obsidian Vault

Memoria persistente del agente ${AGENT_NAME}.

Configura \`OBSIDIAN_VAULT_REPO\` en \`config.env\` y reinstala para clonar el repositorio remoto.
EOF
  fi
fi

# --- Variables de entorno del agente ---
ENV_FILE="${INSTALL_DIR}/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  cat > "$ENV_FILE" << EOF
AGENT_NAME=${AGENT_NAME}
REPO_ROOT=${REPO_ROOT}
BOOTSTRAP_PATH=${BOOTSTRAP_PATH}
SKILLS_DIR=${REPO_ROOT}/skills
RULES_DIR=${REPO_ROOT}/rules
GUARDRAILS_DIR=${REPO_ROOT}/guardrails
VAULT_DIR=${VAULT_PATH}
EOF
  chmod 600 "$ENV_FILE"
  log_info "Archivo .env creado en ${ENV_FILE}"
else
  log_info "Archivo .env ya existe en ${ENV_FILE}"
fi

# --- Verificar bootstrap ---
if [[ ! -f "$BOOTSTRAP_PATH" ]]; then
  die "bootstrap.md no encontrado en ${BOOTSTRAP_PATH}"
fi

log_info "Instalación de Hermes completada."
log_info ""
log_info "Próximo paso para el agente:"
log_info "  Leer ${BOOTSTRAP_PATH}"
log_info "  e instalar skills, rules y guardrails desde:"
log_info "    ${REPO_ROOT}/skills/"
log_info "    ${REPO_ROOT}/rules/"
log_info "    ${REPO_ROOT}/guardrails/"
log_info "  Usar como memoria persistente:"
log_info "    ${VAULT_PATH}/"
log_info ""
log_info "El runtime y su servicio los gestiona el instalador oficial de Hermes."
log_info "Si vas a usar el comando 'hermes' en esta sesión, recarga el PATH:"
log_info "  source ~/.bashrc"
