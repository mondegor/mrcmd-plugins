# https://hub.docker.com/_/redis

readonly REDIS_VARS=(
  "REDIS_DOCKER_CONTAINER"
  "REDIS_DOCKER_CONFIG_DIR"
  "REDIS_DOCKER_CONFIG_YAML"
  "REDIS_DOCKER_IMAGE"
  "REDIS_DOCKER_NETWORK"
  "REDIS_INSTALL_BASH"
  "REDIS_TZ"
  "REDIS_EXT_PORT"
  "REDIS_PASSWORD"
)

# default values of array: REDIS_VARS
readonly REDIS_VARS_DEFAULT=(
  "${APPX_ID:-appx}-db-redis"
  "${MRCMD_DIR}/plugins/redis/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/redis/docker-compose.yaml"
  "redis:7.0.10-alpine3.17"
  "${APPX_NETWORK:-appx-network}"
  "${ALPINE_INSTALL_BASH:-false}"
  "${TZ:-Europe/Moscow}"
  "127.0.0.1:6379"
  "12345"
)

function mrcmd_plugins_redis_method_config() {
  mrcore_dotenv_echo_var_array REDIS_VARS[@]
}

function mrcmd_plugins_redis_method_export_config() {
  mrcore_dotenv_export_var_array REDIS_VARS[@]
}

function mrcmd_plugins_redis_method_init() {
  mrcore_dotenv_init_var_array REDIS_VARS[@] REDIS_VARS_DEFAULT[@]

  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${REDIS_DOCKER_CONFIG_YAML}"
  fi
}
