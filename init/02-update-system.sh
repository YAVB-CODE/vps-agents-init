#!/usr/bin/env bash
# Actualiza el sistema operativo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

require_root
init_logging

log_info "Actualizando lista de paquetes..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y

log_info "Actualizando paquetes instalados..."
apt-get upgrade -y

log_info "Sistema actualizado."
