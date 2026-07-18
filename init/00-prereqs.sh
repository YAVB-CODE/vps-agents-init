#!/usr/bin/env bash
# Verifica prerequisitos: root, SO soportado, conectividad.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
# shellcheck source=../lib/detect-os.sh
source "${SCRIPT_DIR}/../lib/detect-os.sh"

require_root
assert_supported_os

log_info "Verificando conectividad..."
if ! ping -c 1 -W 5 8.8.8.8 &>/dev/null; then
  die "Sin conectividad a internet."
fi
log_info "Conectividad OK."

log_info "Prerequisitos verificados."
