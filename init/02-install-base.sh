#!/usr/bin/env bash
# Instala herramientas base: git, curl, jq, etc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

require_root

export DEBIAN_FRONTEND=noninteractive

BASE_PACKAGES=(
  git
  curl
  wget
  jq
  unzip
  ca-certificates
  gnupg
  lsb-release
  software-properties-common
  build-essential
)

log_info "Instalando paquetes base..."
for pkg in "${BASE_PACKAGES[@]}"; do
  if dpkg -l "$pkg" &>/dev/null 2>&1; then
    log_info "${pkg} ya instalado."
  else
    apt-get install -y "$pkg"
    log_info "${pkg} instalado."
  fi
done

log_info "Paquetes base listos."
