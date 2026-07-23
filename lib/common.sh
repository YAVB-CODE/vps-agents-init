#!/usr/bin/env bash
# Funciones compartidas para todos los scripts de vps-agents-init.

set -euo pipefail

LOG_DIR="/var/log/vps-agents-init"
LOG_FILE="${LOG_DIR}/init.log"

log() {
  local level="$1"
  shift
  local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
  echo "$msg"
  if [[ -d "$LOG_DIR" ]]; then
    echo "$msg" >> "$LOG_FILE"
  fi
}

log_info()  { log "INFO"  "$@"; }
log_warn()  { log "WARN"  "$@"; }
log_error() { log "ERROR" "$@"; }

die() {
  log_error "$@"
  exit 1
}

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Este script debe ejecutarse como root o con sudo."
  fi
}

init_logging() {
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"
  log_info "Logging iniciado en ${LOG_FILE}"
}

repo_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
  echo "$dir"
}

command_exists() {
  command -v "$1" &>/dev/null
}

install_if_missing() {
  local cmd="$1"
  shift
  if command_exists "$cmd"; then
    log_info "${cmd} ya está instalado."
    return 0
  fi
  log_info "Instalando dependencias para ${cmd}..."
  apt-get install -y "$@"
}

run_step() {
  local name="$1"
  local script="$2"
  log_info "=== ${name} ==="
  if [[ ! -f "$script" ]]; then
    die "Script no encontrado: ${script}"
  fi
  bash "$script"
  log_info "=== ${name} completado ==="
}

resolve_agent_user() {
  AGENT_USER="${AGENT_USER:-hermes}"
  AGENT_HOME="${AGENT_HOME:-/home/${AGENT_USER}}"
}

assert_agent_user() {
  resolve_agent_user
  if ! id "$AGENT_USER" &>/dev/null; then
    die "Usuario del agente no encontrado: ${AGENT_USER}. Ejecuta bin/setup-vps primero."
  fi
}

run_as_agent() {
  resolve_agent_user
  assert_agent_user
  sudo -u "$AGENT_USER" -H bash -c "$1"
}

ensure_dir_owned_by_agent() {
  local dir="$1"
  mkdir -p "$dir"
  chown "${AGENT_USER}:${AGENT_USER}" "$dir"
}

ensure_agent_owns_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    log_warn "Ruta no encontrada para asignar ownership: ${path}"
    return 0
  fi
  chown -R "${AGENT_USER}:${AGENT_USER}" "$path"
  log_info "Propiedad de ${path} asignada a ${AGENT_USER}."
}

configure_agent_git() {
  resolve_agent_user
  assert_agent_user

  if ! command_exists git; then
    log_warn "Git no instalado; omitiendo configuración de git para ${AGENT_USER}."
    return 0
  fi

  local git_name="${AGENT_GIT_NAME:-${AGENT_USER}}"
  local git_email="${AGENT_GIT_EMAIL:-${AGENT_USER}@localhost}"

  run_as_agent "git config --global user.name '${git_name}'"
  run_as_agent "git config --global user.email '${git_email}'"
  run_as_agent "git config --global init.defaultBranch main"
  log_info "Git configurado para ${AGENT_USER}: ${git_name} <${git_email}>."
}

load_agent_config() {
  local repo_root="$1"
  local agent_config="${2:-}"

  local init_config="${repo_root}/init/config.env"
  if [[ -f "$init_config" ]]; then
    load_config "$init_config"
  fi
  if [[ -n "$agent_config" && -f "$agent_config" ]]; then
    load_config "$agent_config"
  fi
  resolve_agent_user
}

update_env_var() {
  local env_file="$1"
  local key="$2"
  local value="$3"

  if [[ ! -f "$env_file" ]]; then
    die "Archivo .env no encontrado: ${env_file}. Instala el agente primero."
  fi

  if grep -q "^${key}=" "$env_file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$env_file"
  else
    echo "${key}=${value}" >> "$env_file"
  fi

  chown "${AGENT_USER}:${AGENT_USER}" "$env_file"
  chmod 600 "$env_file"
}

load_config() {
  local config_file="$1"
  if [[ -f "$config_file" ]]; then
    # Exporta todas las variables definidas en el archivo de configuración
    # para que estén disponibles en subprocesos y en la generación del .env.
    set -a
    # shellcheck source=/dev/null
    source "$config_file"
    set +a
    log_info "Configuración cargada desde ${config_file}"
  fi
}

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"
  local branch="${3:-main}"

  if [[ -z "$repo_url" ]]; then
    log_warn "Repositorio no configurado, omitiendo clone en ${target_dir}."
    return 0
  fi

  resolve_agent_user
  assert_agent_user

  ensure_dir_owned_by_agent "$(dirname "$target_dir")"

  if [[ -d "${target_dir}/.git" ]]; then
    log_info "Repositorio ya clonado en ${target_dir}, actualizando como ${AGENT_USER}..."
    run_as_agent "git -C '${target_dir}' pull origin '${branch}'"
  else
    log_info "Clonando ${repo_url} en ${target_dir} como ${AGENT_USER}..."
    run_as_agent "git clone --branch '${branch}' '${repo_url}' '${target_dir}'"
  fi
}
