#!/usr/bin/env bash
# Crea el usuario dedicado del agente, su home, SSH y sudo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

require_root

CONFIG_FILE="${SCRIPT_DIR}/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  load_config "$CONFIG_FILE"
fi

resolve_agent_user

log_info "Configurando usuario del agente: ${AGENT_USER} (${AGENT_HOME})"

if id "$AGENT_USER" &>/dev/null; then
  log_info "Usuario ${AGENT_USER} ya existe."
else
  log_info "Creando usuario ${AGENT_USER}..."
  useradd -m -s /bin/bash -d "$AGENT_HOME" "$AGENT_USER"
fi

if [[ -n "${AGENT_PASSWORD:-}" ]]; then
  printf '%s:%s\n' "$AGENT_USER" "$AGENT_PASSWORD" | chpasswd
  log_info "Contraseña configurada para ${AGENT_USER}."
else
  log_info "AGENT_PASSWORD no definido; login por SSH (o contraseña previa si ya existía)."
fi

if [[ ! -d "$AGENT_HOME" ]]; then
  mkdir -p "$AGENT_HOME"
fi
chown "${AGENT_USER}:${AGENT_USER}" "$AGENT_HOME"
chmod 755 "$AGENT_HOME"

SSH_DIR="${AGENT_HOME}/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "${AGENT_USER}:${AGENT_USER}" "$SSH_DIR"

AUTH_KEYS="${SSH_DIR}/authorized_keys"
if [[ -n "${AGENT_SSH_KEY_FILE:-}" && -f "$AGENT_SSH_KEY_FILE" ]]; then
  install -o "$AGENT_USER" -g "$AGENT_USER" -m 600 "$AGENT_SSH_KEY_FILE" "$AUTH_KEYS"
  log_info "Clave SSH instalada desde ${AGENT_SSH_KEY_FILE}."
elif [[ -n "${AGENT_SSH_KEY:-}" ]]; then
  printf '%s\n' "$AGENT_SSH_KEY" > "$AUTH_KEYS"
  chown "${AGENT_USER}:${AGENT_USER}" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  log_info "Clave SSH instalada desde AGENT_SSH_KEY."
elif [[ "${AGENT_COPY_ROOT_SSH_KEYS:-true}" == "true" && -f /root/.ssh/authorized_keys ]]; then
  if [[ ! -s "$AUTH_KEYS" ]]; then
    install -o "$AGENT_USER" -g "$AGENT_USER" -m 600 /root/.ssh/authorized_keys "$AUTH_KEYS"
    log_info "Claves SSH copiadas desde /root/.ssh/authorized_keys."
  else
    log_info "authorized_keys del agente ya existe; no se copia desde root."
  fi
else
  touch "$AUTH_KEYS"
  chown "${AGENT_USER}:${AGENT_USER}" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  log_warn "Sin clave SSH configurada para ${AGENT_USER}."
fi

if [[ "${AGENT_SUDO_NOPASSWD:-true}" == "true" ]]; then
  SUDOERS_FILE="/etc/sudoers.d/${AGENT_USER}"
  printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$AGENT_USER" > "$SUDOERS_FILE"
  chmod 440 "$SUDOERS_FILE"
  if ! visudo -cf "$SUDOERS_FILE" &>/dev/null; then
    die "Regla sudoers inválida en ${SUDOERS_FILE}."
  fi
  log_info "Sudo sin contraseña configurado en ${SUDOERS_FILE}."
else
  usermod -aG sudo "$AGENT_USER" 2>/dev/null || true
  log_info "Usuario ${AGENT_USER} agregado al grupo sudo."
fi

log_info "Usuario del agente listo."
