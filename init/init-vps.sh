#!/usr/bin/env bash
# Orquestador: prepara el VPS completo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

require_root
init_logging

log_info "Iniciando preparación del VPS desde ${REPO_ROOT}"

run_step "Prerequisitos"       "${SCRIPT_DIR}/00-prereqs.sh"
run_step "Actualizar sistema"  "${SCRIPT_DIR}/01-update-system.sh"
run_step "Instalar base"       "${SCRIPT_DIR}/02-install-base.sh"
run_step "Configurar sistema"  "${SCRIPT_DIR}/03-configure-system.sh"

log_info "VPS preparado. Siguiente paso: instalar un agente con bin/setup-agent <nombre>"
