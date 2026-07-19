#!/usr/bin/env bash
# Configura ajustes básicos del sistema: zona horaria.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

require_root

TIMEZONE="${TIMEZONE:-America/Lima}"

log_info "Configurando zona horaria a ${TIMEZONE}..."
if ! timedatectl set-timezone "$TIMEZONE"; then
  die "No se pudo establecer la zona horaria a ${TIMEZONE}. Verifica que sea válida (timedatectl list-timezones)."
fi

CURRENT_TZ="$(timedatectl show --property=Timezone --value)"
log_info "Zona horaria actual: ${CURRENT_TZ}"

log_info "Configuración del sistema lista."
