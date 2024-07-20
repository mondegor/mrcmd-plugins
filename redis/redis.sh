# https://hub.docker.com/_/redis

function mrcmd_plugins_redis_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_redis_method_init() {
  export REDIS_DOCKER_SERVICE="db-redis"

  readonly REDIS_CAPTION="Redis"

  readonly REDIS_VARS=(
    "REDIS_DOCKER_CONTAINER"
    "REDIS_DOCKER_CONTEXT_DIR"
    "REDIS_DOCKER_DOCKERFILE"
    "REDIS_DOCKER_COMPOSE_CONFIG_DIR"
    "REDIS_DOCKER_IMAGE"
    "REDIS_DOCKER_IMAGE_FROM"

    "REDIS_PUBLIC_PORT"
    "REDIS_PASSWORD"
  )

  readonly REDIS_VARS_DEFAULT=(
    "${APPX_ID}-${REDIS_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}redis:7.2.5"
    "redis:7.2.5-alpine3.20"

    "127.0.0.1:6379"
    "123456"
  )

  mrcore_dotenv_init_var_array REDIS_VARS[@] REDIS_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${REDIS_DOCKER_COMPOSE_CONFIG_DIR}/db-redis.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${REDIS_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_redis_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_redis_method_config() {
  mrcore_dotenv_echo_var_array REDIS_VARS[@]
  mrcore_echo_var "REDIS_DOCKER_SERVICE (host, readonly)" "${REDIS_DOCKER_SERVICE}"
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

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_redis_method_config
      mrcmd_plugins_redis_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${REDIS_DOCKER_SERVICE}" \
        redis-cli -a "${REDIS_PASSWORD}"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${REDIS_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${REDIS_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${REDIS_DOCKER_CONTAINER}" \
        "${REDIS_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_redis_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${REDIS_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${REDIS_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to redis-cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_redis_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${REDIS_DOCKER_CONTEXT_DIR}" \
    "${REDIS_DOCKER_DOCKERFILE}" \
    "${REDIS_DOCKER_IMAGE}" \
    "${REDIS_DOCKER_IMAGE_FROM}" \
    --build-arg "REDIS_PASSWORD=${REDIS_PASSWORD}" \
    "$@"
}
