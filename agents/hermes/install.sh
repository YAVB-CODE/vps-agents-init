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
load_agent_config "$REPO_ROOT" "${SCRIPT_DIR}/config.env"
assert_agent_user

AGENT_NAME="${AGENT_NAME:-hermes}"
INSTALL_DIR="${INSTALL_DIR:-/opt/hermes}"
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
BOOTSTRAP_FILE="${BOOTSTRAP_FILE:-bootstrap.md}"
BOOTSTRAP_PATH="${REPO_ROOT}/${BOOTSTRAP_FILE}"

log_info "Instalando agente ${AGENT_NAME}"
log_info "  Usuario:    ${AGENT_USER}"
log_info "  Install:    ${INSTALL_DIR}"
log_info "  Repo:       ${REPO_ROOT}"
log_info "  Bootstrap:  ${BOOTSTRAP_PATH}"

# --- Directorio de instalación ---
mkdir -p "$INSTALL_DIR"
chown "${AGENT_USER}:${AGENT_USER}" "$INSTALL_DIR"

# --- Desplegar runtime de Hermes ---
# Se instala mediante el instalador oficial de Nous Research.
HERMES_INSTALL_URL="${HERMES_INSTALL_URL:-https://hermes-agent.nousresearch.com/install.sh}"
log_info "Instalando runtime de Hermes como ${AGENT_USER} desde ${HERMES_INSTALL_URL}"
run_as_agent "curl -fsSL '${HERMES_INSTALL_URL}' | bash"
log_info "Runtime de Hermes instalado. El servicio lo gestiona el instalador oficial."

# --- Variables de entorno del agente ---
ENV_FILE="${INSTALL_DIR}/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  run_as_agent "cat > '${ENV_FILE}' << EOF
AGENT_NAME=${AGENT_NAME}
AGENT_USER=${AGENT_USER}
REPO_ROOT=${REPO_ROOT}
BOOTSTRAP_PATH=${BOOTSTRAP_PATH}
SKILLS_DIR=${REPO_ROOT}/skills
RULES_DIR=${REPO_ROOT}/rules
GUARDRAILS_DIR=${REPO_ROOT}/guardrails
EOF
chmod 600 '${ENV_FILE}'"
  log_info "Archivo .env creado en ${ENV_FILE}"
else
  log_info "Archivo .env ya existe en ${ENV_FILE}"
fi

ensure_agent_owns_path "$INSTALL_DIR"

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
log_info ""
log_info "Memoria Obsidian (opcional): ${REPO_ROOT}/optional/obsidian-vault/"
log_info ""
log_info "El runtime y su servicio los gestiona el instalador oficial de Hermes."
log_info "Opera como ${AGENT_USER}. Para usar el comando 'hermes':"
log_info "  sudo -u ${AGENT_USER} -H bash -lc 'source ~/.bashrc && hermes'"
log_info "Tras el init, trabaja siempre como ${AGENT_USER} (git pull, docker, etc.)."
