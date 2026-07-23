#!/usr/bin/env bash
# Configura git del agente y asigna ownership del repositorio de bootstrap.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

require_root

CONFIG_FILE="${SCRIPT_DIR}/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  load_config "$CONFIG_FILE"
fi

resolve_agent_user
assert_agent_user

configure_agent_git
ensure_agent_owns_path "$REPO_ROOT"

log_info "Entorno del agente configurado."
