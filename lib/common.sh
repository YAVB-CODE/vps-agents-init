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

  mkdir -p "$(dirname "$target_dir")"

  if [[ -d "${target_dir}/.git" ]]; then
    log_info "Repositorio ya clonado en ${target_dir}, actualizando..."
    git -C "$target_dir" pull origin "$branch"
  else
    log_info "Clonando ${repo_url} en ${target_dir}..."
    git clone --branch "$branch" "$repo_url" "$target_dir"
  fi
}
