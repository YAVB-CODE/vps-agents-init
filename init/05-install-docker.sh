#!/usr/bin/env bash
# Instala Docker Engine desde el repositorio oficial y agrega al usuario del agente al grupo docker.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/detect-os.sh
source "${SCRIPT_DIR}/../lib/detect-os.sh"

require_root

CONFIG_FILE="${SCRIPT_DIR}/config.env"
if [[ -f "$CONFIG_FILE" ]]; then
  load_config "$CONFIG_FILE"
fi

resolve_agent_user
assert_agent_user

INSTALL_DOCKER="${INSTALL_DOCKER:-true}"
if [[ "$INSTALL_DOCKER" != "true" ]]; then
  log_info "INSTALL_DOCKER=false, omitiendo instalación de Docker."
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive

DOCKER_PACKAGES=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
  docker-compose-plugin
)

docker_repo_configured() {
  [[ -f /etc/apt/sources.list.d/docker.list ]]
}

configure_docker_apt_repo() {
  detect_os

  local distro="$OS_ID"
  case "$distro" in
    ubuntu|debian) ;;
    *)
      die "Docker no soportado para ${OS_PRETTY}."
      ;;
  esac

  if docker_repo_configured; then
    log_info "Repositorio de Docker ya configurado."
    return 0
  fi

  log_info "Configurando repositorio oficial de Docker para ${distro}..."
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://download.docker.com/linux/${distro}/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # shellcheck source=/dev/null
  source /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${distro} ${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list
}

install_docker_packages() {
  if command_exists docker; then
    log_info "Docker CLI ya instalado: $(docker --version)."
    return 0
  fi

  log_info "Instalando paquetes de Docker..."
  apt-get update -y
  apt-get install -y "${DOCKER_PACKAGES[@]}"
  log_info "Docker instalado: $(docker --version)."
}

ensure_docker_service() {
  log_info "Habilitando servicio docker..."
  systemctl enable docker
  systemctl start docker

  if systemctl is-active --quiet docker; then
    log_info "Servicio docker activo."
  else
    die "El servicio docker no pudo iniciarse."
  fi
}

add_agent_to_docker_group() {
  if id -nG "$AGENT_USER" | grep -qw docker; then
    log_info "${AGENT_USER} ya está en el grupo docker."
    return 0
  fi

  usermod -aG docker "$AGENT_USER"
  log_info "${AGENT_USER} agregado al grupo docker."
}

verify_docker_as_agent() {
  log_info "Verificando acceso a Docker como ${AGENT_USER}..."
  if run_as_agent "sg docker -c 'docker ps >/dev/null'"; then
    log_info "Docker accesible para ${AGENT_USER}."
  else
    log_warn "Docker no accesible aún para ${AGENT_USER}. Inicia una nueva sesión SSH."
  fi
}

configure_docker_apt_repo
install_docker_packages
ensure_docker_service
add_agent_to_docker_group
verify_docker_as_agent

log_info "Docker listo."
