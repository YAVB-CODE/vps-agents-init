#!/usr/bin/env bash
# Crea el usuario base para agentes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

require_root

AGENT_USER="${AGENT_USER:-hermes}"
AGENT_HOME="${AGENT_HOME:-/home/${AGENT_USER}}"

ensure_user "$AGENT_USER" "$AGENT_HOME"

if ! grep -q "^${AGENT_USER}:" /etc/sudoers.d/agents 2>/dev/null; then
  echo "${AGENT_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/agents
  chmod 440 /etc/sudoers.d/agents
  log_info "Permisos sudo configurados para ${AGENT_USER}."
else
  log_info "Permisos sudo ya configurados para ${AGENT_USER}."
fi

mkdir -p "${AGENT_HOME}/.config"
chown -R "${AGENT_USER}:${AGENT_USER}" "$AGENT_HOME"

log_info "Usuario ${AGENT_USER} listo."
