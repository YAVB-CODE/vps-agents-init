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
AGENT_USER="${AGENT_USER:-hermes}"
AGENT_HOME="${AGENT_HOME:-/home/${AGENT_USER}}"
INSTALL_DIR="${INSTALL_DIR:-/opt/hermes}"
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../.." && pwd)}"
BOOTSTRAP_FILE="${BOOTSTRAP_FILE:-bootstrap.md}"
BOOTSTRAP_PATH="${REPO_ROOT}/${BOOTSTRAP_FILE}"
OBSIDIAN_VAULT_DIR="${OBSIDIAN_VAULT_DIR:-obsidian-vault}"
VAULT_PATH="${INSTALL_DIR}/${OBSIDIAN_VAULT_DIR}"

log_info "Instalando agente ${AGENT_NAME}"
log_info "  Usuario:    ${AGENT_USER}"
log_info "  Home:       ${AGENT_HOME}"
log_info "  Install:    ${INSTALL_DIR}"
log_info "  Vault:      ${VAULT_PATH}"
log_info "  Repo:       ${REPO_ROOT}"
log_info "  Bootstrap:  ${BOOTSTRAP_PATH}"

# --- Usuario ---
ensure_user "$AGENT_USER" "$AGENT_HOME"

# --- Directorio de instalación ---
mkdir -p "$INSTALL_DIR"
chown "${AGENT_USER}:${AGENT_USER}" "$INSTALL_DIR"

# --- Desplegar código del agente ---
if [[ -n "${HERMES_REPO:-}" ]]; then
  clone_or_update_repo "$AGENT_USER" "$HERMES_REPO" "$INSTALL_DIR" "${HERMES_BRANCH:-main}"
else
  log_warn "HERMES_REPO no configurado. Creando estructura base en ${INSTALL_DIR}."
  mkdir -p "${INSTALL_DIR}/bin"
  if [[ ! -f "${INSTALL_DIR}/bin/hermes" ]]; then
    cat > "${INSTALL_DIR}/bin/hermes" << 'STUB'
#!/usr/bin/env bash
# Placeholder de Hermes — reemplazar cuando el repo esté disponible.
echo "Hermes placeholder. Configura HERMES_REPO en config.env e reinstala."
STUB
    chmod +x "${INSTALL_DIR}/bin/hermes"
    chown -R "${AGENT_USER}:${AGENT_USER}" "$INSTALL_DIR"
  fi
fi

# --- Vault de Obsidian (memoria persistente) ---
if [[ -n "${OBSIDIAN_VAULT_REPO:-}" ]]; then
  clone_or_update_repo "$AGENT_USER" "$OBSIDIAN_VAULT_REPO" "$VAULT_PATH" "${OBSIDIAN_VAULT_BRANCH:-main}"
else
  log_warn "OBSIDIAN_VAULT_REPO no configurado. Creando directorio vacío en ${VAULT_PATH}."
  mkdir -p "$VAULT_PATH"
  if [[ ! -f "${VAULT_PATH}/README.md" ]]; then
    cat > "${VAULT_PATH}/README.md" << EOF
# Obsidian Vault

Memoria persistente del agente ${AGENT_NAME}.

Configura \`OBSIDIAN_VAULT_REPO\` en \`config.env\` y reinstala para clonar el repositorio remoto.
EOF
    chown "${AGENT_USER}:${AGENT_USER}" "${VAULT_PATH}/README.md"
  fi
fi
chown -R "${AGENT_USER}:${AGENT_USER}" "$VAULT_PATH"

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
  chown "${AGENT_USER}:${AGENT_USER}" "$ENV_FILE"
  log_info "Archivo .env creado en ${ENV_FILE}"
else
  log_info "Archivo .env ya existe en ${ENV_FILE}"
fi

# --- Servicio systemd ---
SERVICE_FILE="/etc/systemd/system/hermes.service"
if [[ ! -f "$SERVICE_FILE" ]]; then
  cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Hermes Agent
After=network.target

[Service]
Type=simple
User=${AGENT_USER}
WorkingDirectory=${INSTALL_DIR}
EnvironmentFile=${ENV_FILE}
ExecStart=${INSTALL_DIR}/bin/hermes
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  log_info "Servicio systemd creado: hermes.service"
else
  log_info "Servicio systemd ya existe."
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
log_info "Para iniciar el servicio:"
log_info "  systemctl enable hermes && systemctl start hermes"
