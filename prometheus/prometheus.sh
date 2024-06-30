# https://hub.docker.com/r/prom/prometheus

function mrcmd_plugins_prometheus_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_prometheus_method_init() {
  readonly PROMETHEUS_CAPTION="Prometheus"
  readonly PROMETHEUS_DOCKER_SERVICE="mn-prometheus"

  readonly PROMETHEUS_VARS=(
    "READONLY_PROMETHEUS_DOCKER_HOST"
    "PROMETHEUS_DOCKER_CONTAINER"
    "PROMETHEUS_DOCKER_CONTEXT_DIR"
    "PROMETHEUS_DOCKER_DOCKERFILE"
    "PROMETHEUS_DOCKER_COMPOSE_CONFIG_DIR"
    "PROMETHEUS_DOCKER_IMAGE"
    "PROMETHEUS_DOCKER_IMAGE_FROM"

    "PROMETHEUS_PUBLIC_PORT"
    "PROMETHEUS_WEB_DOMAIN"
  )

  readonly PROMETHEUS_VARS_DEFAULT=(
    "${PROMETHEUS_DOCKER_SERVICE}"
    "${APPX_ID}-${PROMETHEUS_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}prometheus:2.51.2"
    "prom/prometheus:v2.51.2"

    "127.0.0.1:9090"
    "prometheus.local"
  )

  mrcore_dotenv_init_var_array PROMETHEUS_VARS[@] PROMETHEUS_VARS_DEFAULT[@]

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
        "sh" # "${DOCKER_DEFAULT_SHELL}"
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
