#!/usr/bin/env bash
# Orquestador: prepara el VPS completo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

require_root
init_logging
load_agent_config "$REPO_ROOT"

log_info "Iniciando preparación del VPS desde ${REPO_ROOT}"
log_info "Usuario del agente: ${AGENT_USER} (${AGENT_HOME})"

run_step "Prerequisitos"         "${SCRIPT_DIR}/00-prereqs.sh"
run_step "Usuario del agente"    "${SCRIPT_DIR}/01-create-agent-user.sh"
run_step "Actualizar sistema"    "${SCRIPT_DIR}/02-update-system.sh"
run_step "Instalar base"         "${SCRIPT_DIR}/03-install-base.sh"
run_step "Configurar sistema"    "${SCRIPT_DIR}/04-configure-system.sh"
run_step "Instalar Docker"       "${SCRIPT_DIR}/05-install-docker.sh"
run_step "Entorno del agente"    "${SCRIPT_DIR}/06-configure-agent-env.sh"

log_info "VPS preparado. Siguiente paso: instalar un agente con bin/setup-agent <nombre>"
