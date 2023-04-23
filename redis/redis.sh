# https://hub.docker.com/_/redis

function mrcmd_plugins_redis_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_redis_method_init() {
  readonly REDIS_NAME="Redis"

  readonly REDIS_VARS=(
    "REDIS_DOCKER_CONTAINER"
    "REDIS_DOCKER_SERVICE"
    "REDIS_DOCKER_CONFIG_DOCKERFILE"
    "REDIS_DOCKER_COMPOSE_CONFIG_DIR"
    "REDIS_DOCKER_IMAGE"
    "REDIS_DOCKER_IMAGE_FROM"
    "REDIS_DOCKER_ADD_GENERAL_NETWORK"

    "REDIS_PUBLIC_PORT"
    "REDIS_ROOT_PASSWORD"
  )

  readonly REDIS_VARS_DEFAULT=(
    "${APPX_ID}-db-redis"
    "db-redis"
    "${MRCMD_DIR}/plugins/redis/docker"
    "${MRCMD_DIR}/plugins/redis/docker-compose"
    "redis:${APPX_ID}-7.0.10"
    "redis:7.0.10-alpine3.17"
    "false"

    "127.0.0.1:6379"
    "123456"
  )

  mrcore_dotenv_init_var_array REDIS_VARS[@] REDIS_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${REDIS_DOCKER_COMPOSE_CONFIG_DIR}/db-redis.yaml")

  if [[ "${REDIS_DOCKER_ADD_GENERAL_NETWORK}" == true ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${REDIS_DOCKER_COMPOSE_CONFIG_DIR}/general-network.yaml")
  fi
}

function mrcmd_plugins_redis_method_config() {
  mrcore_dotenv_echo_var_array REDIS_VARS[@]
}

function mrcmd_plugins_redis_method_export_config() {
  mrcore_dotenv_export_var_array REDIS_VARS[@]
}

function mrcmd_plugins_redis_method_install() {
  mrcmd_plugins_redis_docker_build --no-cache
}

function mrcmd_plugins_redis_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array REDIS_VARS[@]
      mrcmd_plugins_redis_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${REDIS_DOCKER_SERVICE}" \
        redis-cli
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${REDIS_DOCKER_SERVICE}" \
        "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_redis_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image ${CC_GREEN}${REDIS_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                         Enters to redis-cli in the running container ${CC_GREEN}${REDIS_DOCKER_CONTAINER}${CC_END}"
  echo -e "  into                        Enters to shell in the running container ${CC_GREEN}${REDIS_DOCKER_CONTAINER}${CC_END}"
}

# private
function mrcmd_plugins_redis_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${REDIS_DOCKER_CONFIG_DOCKERFILE}" \
    "${REDIS_DOCKER_IMAGE}" \
    "${REDIS_DOCKER_IMAGE_FROM}" \
    --build-arg "REDIS_PASSWORD=${REDIS_ROOT_PASSWORD}" \
    "$@"
}
