# https://hub.docker.com/_/nginx

readonly NGINX_VARS=(
  "NGINX_DOCKER_CONTAINER"
  "NGINX_DOCKER_CONFIG_DIR"
  "NGINX_DOCKER_CONFIG_YAML"
  "NGINX_DOCKER_IMAGE"
  "NGINX_DOCKER_NETWORK"
  "NGINX_INSTALL_BASH"
  "NGINX_TZ"
  "NGINX_EXT_PORT"
  "NGINX_SERVICE_TYPE"
  "NGINX_SERVICE_DOMAIN"
  "NGINX_SERVICE_HOST"
  "NGINX_SERVICE_PORT"
)

# default values of array: NGINX_VARS
readonly NGINX_VARS_DEFAULT=(
  "${APPX_ID:-appx}-proxy-nginx"
  "${MRCMD_DIR}/plugins/nginx/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/nginx/docker-compose.yaml"
  "nginx:1.23.4-alpine3.17"
  "${APPX_NETWORK:-appx-network}"
  "${ALPINE_INSTALL_BASH:-false}"
  "${TZ:-Europe/Moscow}"
  "${APPX_EXT_PORT:-127.0.0.1:8080}"
  "${APPX_TYPE:-php}"
  "${APPX_DOMAIN:-appx.local}"
  "${APPX_HOST:-web-app}"
  "${APPX_PORT:-9000}"
)

function mrcmd_plugins_nginx_method_config() {
  mrcore_dotenv_echo_var_array NGINX_VARS[@]
}

function mrcmd_plugins_nginx_method_export_config() {
  mrcore_dotenv_export_var_array NGINX_VARS[@]
}

function mrcmd_plugins_nginx_method_init() {
  mrcore_dotenv_init_var_array NGINX_VARS[@] NGINX_VARS_DEFAULT[@]

#  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
#    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${NGINX_DOCKER_CONFIG_YAML}"
#  fi
}
