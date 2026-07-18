#!/usr/bin/env bash
# Detecta el sistema operativo y el gestor de paquetes.

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"
    OS_PRETTY="${PRETTY_NAME:-unknown}"
  else
    OS_ID="unknown"
    OS_VERSION="unknown"
    OS_PRETTY="unknown"
  fi
}

detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
  elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
  elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
  else
    PKG_MANAGER="unknown"
  fi
}

assert_supported_os() {
  detect_os
  detect_pkg_manager

  case "$OS_ID" in
    ubuntu|debian)
      log_info "SO detectado: ${OS_PRETTY}"
      ;;
    *)
      die "SO no soportado: ${OS_PRETTY}. Se requiere Ubuntu o Debian."
      ;;
  esac

  if [[ "$PKG_MANAGER" != "apt" ]]; then
    die "Gestor de paquetes no soportado. Se requiere apt."
  fi
}
