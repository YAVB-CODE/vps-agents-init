#!/usr/bin/env bash
# Menú interactivo para instalar y autenticar servidores MCP.
#
# Descubre las definiciones en mcp/servers/*.conf y, según su AUTH_TYPE,
# guía la autenticación:
#   - token: solicita un API key / token y lo guarda.
#   - oauth: guía el flujo OAuth (login en tu máquina local o device flow)
#            y guarda el token resultante.
#
# Los secretos se escriben en MCP_SECRETS_FILE (permisos 600) y NUNCA se
# versionan. Este script solo maneja NOMBRES de variables en git.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=../lib/common.sh
source "${REPO_ROOT}/lib/common.sh"

SERVERS_DIR="${SCRIPT_DIR}/servers"
INSTALL_DIR="${INSTALL_DIR:-/opt/hermes}"
MCP_SECRETS_FILE="${MCP_SECRETS_FILE:-${INSTALL_DIR}/.mcp.env}"

# --- Helpers de secretos --------------------------------------------------

ensure_secrets_file() {
  mkdir -p "$(dirname "$MCP_SECRETS_FILE")"
  if [[ ! -f "$MCP_SECRETS_FILE" ]]; then
    printf '# Secretos de servidores MCP. NO versionar. Generado por install-mcp.sh\n' > "$MCP_SECRETS_FILE"
  fi
  chmod 600 "$MCP_SECRETS_FILE"
}

# Guarda o reemplaza KEY=VALUE sin imprimir el valor.
save_secret() {
  local key="$1"
  local value="$2"
  ensure_secrets_file
  # Eliminar cualquier definición previa de la misma clave.
  local tmp
  tmp="$(mktemp)"
  grep -v "^${key}=" "$MCP_SECRETS_FILE" > "$tmp" || true
  mv "$tmp" "$MCP_SECRETS_FILE"
  printf '%s=%s\n' "$key" "$value" >> "$MCP_SECRETS_FILE"
  chmod 600 "$MCP_SECRETS_FILE"
  log_info "Guardado ${key} en ${MCP_SECRETS_FILE} (valor oculto)."
}

# Pide un secreto por cada variable declarada en ENV_VARS.
prompt_env_vars() {
  local env_vars="$1"
  local var value
  for var in $env_vars; do
    printf '  Ingresa el valor para %s (no se mostrará): ' "$var" >&2
    read -rs value
    printf '\n' >&2
    if [[ -z "$value" ]]; then
      log_warn "  ${var} quedó vacío; se omite."
      continue
    fi
    save_secret "$var" "$value"
  done
}

# --- Flujos de autenticación ---------------------------------------------

auth_token() {
  local display="$1" env_vars="$2" auth_url="$3" hint="$4"
  echo ""
  log_info "Autenticando ${display} por TOKEN / API key."
  [[ -n "$hint" ]]    && echo "  → ${hint}"
  [[ -n "$auth_url" ]] && echo "  → Obtén la credencial en: ${auth_url}"
  echo ""
  prompt_env_vars "$env_vars"
}

auth_oauth() {
  local display="$1" env_vars="$2" auth_url="$3" hint="$4"
  echo ""
  log_info "Autenticando ${display} por OAUTH (headless)."
  echo "  El VPS no tiene navegador: el login se hace en TU máquina local."
  echo ""
  echo "  1. En tu laptop, completa el OAuth del servicio (o usa device flow)."
  [[ -n "$auth_url" ]] && echo "     URL: ${auth_url}"
  [[ -n "$hint" ]]    && echo "     ${hint}"
  echo "  2. Copia el token/refresh_token resultante."
  echo "  3. Pégalo aquí abajo para guardarlo en el VPS."
  echo ""
  prompt_env_vars "$env_vars"
}

# --- Registro de servidores ----------------------------------------------

list_server_files() {
  find "$SERVERS_DIR" -maxdepth 1 -name '*.conf' 2>/dev/null | sort
}

load_server() {
  # Carga un .conf y exporta sus variables al scope actual.
  DISPLAY_NAME="" AUTH_TYPE="" ENV_VARS="" INSTALL_CMD="" AUTH_URL="" AUTH_HINT=""
  # shellcheck source=/dev/null
  source "$1"
}

configure_server() {
  local conf="$1"
  load_server "$conf"

  echo ""
  echo "=================================================="
  log_info "Configurando: ${DISPLAY_NAME} (${AUTH_TYPE})"
  echo "=================================================="

  case "$AUTH_TYPE" in
    token) auth_token "$DISPLAY_NAME" "$ENV_VARS" "$AUTH_URL" "$AUTH_HINT" ;;
    oauth) auth_oauth "$DISPLAY_NAME" "$ENV_VARS" "$AUTH_URL" "$AUTH_HINT" ;;
    *)     log_warn "AUTH_TYPE desconocido '${AUTH_TYPE}' en ${conf}, se omite." ; return 1 ;;
  esac

  if [[ -n "${INSTALL_CMD:-}" ]]; then
    echo ""
    log_info "Comando de registro sugerido para ${DISPLAY_NAME}:"
    echo "    ${INSTALL_CMD}"
    log_info "Regístralo en tu runtime MCP usando las variables de ${MCP_SECRETS_FILE}."
  fi

  log_info "${DISPLAY_NAME} configurado."
}

# --- Menú -----------------------------------------------------------------

print_menu() {
  local files=("$@")
  echo ""
  echo "==================== MCP: instalar ===================="
  local i=1 conf
  for conf in "${files[@]}"; do
    load_server "$conf"
    printf "  %d) %-18s [%s]\n" "$i" "$DISPLAY_NAME" "$AUTH_TYPE"
    i=$((i + 1))
  done
  echo "  a) Instalar TODOS"
  echo "  l) Listar variables ya configuradas"
  echo "  q) Salir"
  echo "======================================================="
  printf "Selecciona una opción: "
}

list_configured() {
  if [[ -f "$MCP_SECRETS_FILE" ]]; then
    log_info "Variables configuradas en ${MCP_SECRETS_FILE}:"
    grep -oE '^[A-Z0-9_]+=' "$MCP_SECRETS_FILE" | sed 's/=$//' | sed 's/^/  - /' || echo "  (ninguna)"
  else
    log_warn "Aún no hay secretos configurados (${MCP_SECRETS_FILE} no existe)."
  fi
}

main() {
  if [[ ! -d "$SERVERS_DIR" ]]; then
    die "No existe el directorio de definiciones: ${SERVERS_DIR}"
  fi

  local files=()
  local f
  while IFS= read -r f; do
    [[ -n "$f" ]] && files+=("$f")
  done < <(list_server_files)
  if [[ ${#files[@]} -eq 0 ]]; then
    die "No hay definiciones .conf en ${SERVERS_DIR}"
  fi

  log_info "Secretos se guardarán en: ${MCP_SECRETS_FILE}"

  while true; do
    print_menu "${files[@]}"
    local choice
    read -r choice
    case "$choice" in
      q|Q) log_info "Saliendo." ; break ;;
      l|L) list_configured ;;
      a|A)
        local conf
        for conf in "${files[@]}"; do configure_server "$conf" || true; done
        ;;
      ''|*[!0-9]*) log_warn "Opción inválida." ;;
      *)
        local idx=$((choice - 1))
        if [[ $idx -ge 0 && $idx -lt ${#files[@]} ]]; then
          configure_server "${files[$idx]}" || true
        else
          log_warn "Número fuera de rango."
        fi
        ;;
    esac
  done
}

main "$@"
