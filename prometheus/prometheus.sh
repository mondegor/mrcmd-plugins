# https://hub.docker.com/r/prom/prometheus

function mrcmd_plugins_prometheus_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_prometheus_method_init() {
  export PROMETHEUS_DOCKER_SERVICE="mn-prometheus"

  readonly PROMETHEUS_CAPTION="Prometheus"

  readonly PROMETHEUS_VARS=(
    "PROMETHEUS_DOCKER_CONTAINER"
    "PROMETHEUS_DOCKER_CONTEXT_DIR"
    "PROMETHEUS_DOCKER_DOCKERFILE"
    "PROMETHEUS_DOCKER_COMPOSE_CONFIG_DIR"
    "PROMETHEUS_DOCKER_IMAGE"
    "PROMETHEUS_DOCKER_IMAGE_FROM"

    "PROMETHEUS_CONFIG_PATH"
    "PROMETHEUS_STORAGE_TSDB_RETENTION_TIME"
    "PROMETHEUS_STORAGE_TSDB_RETENTION_SIZE"

    # "PROMETHEUS_WEB_PUBLIC_PORT"
    "PROMETHEUS_WEB_DOMAIN"
  )

  readonly PROMETHEUS_VARS_DEFAULT=(
    "${APPX_ID}-${PROMETHEUS_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}prometheus:2.53.1"
    "prom/prometheus:v2.53.1"

    ""
    "14d"
    "5GB"

    # "127.0.0.1:9090"
    "prometheus.local"
  )

  mrcore_dotenv_init_var_array PROMETHEUS_VARS[@] PROMETHEUS_VARS_DEFAULT[@]

  if [ -z "${PROMETHEUS_CONFIG_PATH}" ]; then
    PROMETHEUS_CONFIG_PATH="${PROMETHEUS_DOCKER_COMPOSE_CONFIG_DIR}/default-config.yaml"
  fi

  DOCKER_COMPOSE_REQUIRED_SOURCES+=("Prometheus config path" "${PROMETHEUS_CONFIG_PATH}")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${PROMETHEUS_DOCKER_COMPOSE_CONFIG_DIR}/mn-prometheus.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${PROMETHEUS_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_prometheus_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_prometheus_method_config() {
  mrcore_dotenv_echo_var_array PROMETHEUS_VARS[@]
  mrcore_echo_var "PROMETHEUS_DOCKER_SERVICE (host, readonly)" "${PROMETHEUS_DOCKER_SERVICE}"
}

function mrcmd_plugins_prometheus_method_export_config() {
  mrcore_dotenv_export_var_array PROMETHEUS_VARS[@]
}

function mrcmd_plugins_prometheus_method_install() {
  mrcmd_plugins_prometheus_docker_build --no-cache
}

function mrcmd_plugins_prometheus_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_prometheus_method_config
      mrcmd_plugins_prometheus_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${PROMETHEUS_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${PROMETHEUS_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${PROMETHEUS_DOCKER_CONTAINER}" \
        "${PROMETHEUS_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_prometheus_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${PROMETHEUS_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${PROMETHEUS_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_prometheus_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${PROMETHEUS_DOCKER_CONTEXT_DIR}" \
    "${PROMETHEUS_DOCKER_DOCKERFILE}" \
    "${PROMETHEUS_DOCKER_IMAGE}" \
    "${PROMETHEUS_DOCKER_IMAGE_FROM}" \
    "$@"
}
