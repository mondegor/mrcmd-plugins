# https://hub.docker.com/r/confluentinc/cp-zookeeper
# https://docs.confluent.io/platform/current/installation/docker/config-reference.html#zk-configuration

function mrcmd_plugins_zookeeper_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_zookeeper_method_init() {
  readonly ZOOKEEPER_CAPTION="Apache Zookeeper"
  readonly ZOOKEEPER_DOCKER_SERVICE="db-zookeeper"

  readonly ZOOKEEPER_VARS=(
    "READONLY_ZOOKEEPER_DOCKER_HOST"
    "ZOOKEEPER_DOCKER_CONTAINER"
    "ZOOKEEPER_DOCKER_CONTEXT_DIR"
    "ZOOKEEPER_DOCKER_DOCKERFILE"
    "ZOOKEEPER_DOCKER_COMPOSE_CONFIG_DIR"
    "ZOOKEEPER_DOCKER_IMAGE"
    "ZOOKEEPER_DOCKER_IMAGE_FROM"

    "ZOOKEEPER_PUBLIC_PORT"
    "ZOOKEEPER_CLIENT_PORT"
    "ZOOKEEPER_TICK_TIME"
    "ZOOKEEPER_SYNC_LIMIT"
  )

  readonly ZOOKEEPER_VARS_DEFAULT=(
    "${ZOOKEEPER_DOCKER_SERVICE}"
    "${APPX_ID}-${ZOOKEEPER_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}zookeeper:7.4.3"
    "confluentinc/cp-zookeeper:7.4.3"

    "127.0.0.1:2181"
    "2181"
    "2000"
    "2"
  )

  mrcore_dotenv_init_var_array ZOOKEEPER_VARS[@] ZOOKEEPER_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${ZOOKEEPER_DOCKER_COMPOSE_CONFIG_DIR}/db-zookeeper.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${ZOOKEEPER_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_zookeeper_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_zookeeper_method_config() {
  mrcore_dotenv_echo_var_array ZOOKEEPER_VARS[@]
}

function mrcmd_plugins_zookeeper_method_export_config() {
  mrcore_dotenv_export_var_array ZOOKEEPER_VARS[@]
}

function mrcmd_plugins_zookeeper_method_install() {
  mrcmd_plugins_zookeeper_docker_build --no-cache
}

function mrcmd_plugins_zookeeper_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_zookeeper_method_config
      mrcmd_plugins_zookeeper_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${ZOOKEEPER_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${ZOOKEEPER_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${ZOOKEEPER_DOCKER_CONTAINER}" \
        "${ZOOKEEPER_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_zookeeper_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${ZOOKEEPER_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${ZOOKEEPER_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_zookeeper_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${ZOOKEEPER_DOCKER_CONTEXT_DIR}" \
    "${ZOOKEEPER_DOCKER_DOCKERFILE}" \
    "${ZOOKEEPER_DOCKER_IMAGE}" \
    "${ZOOKEEPER_DOCKER_IMAGE_FROM}" \
    "$@"
}
