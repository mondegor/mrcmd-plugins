# https://hub.docker.com/r/grafana/promtail

function mrcmd_plugins_grafana_promtail_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_grafana_promtail_method_init() {
  export GRAFANA_PROMTAIL_DOCKER_SERVICE="mn-grafana-promtail"

  readonly GRAFANA_PROMTAIL_CAPTION="Grafana Promtail"

  readonly GRAFANA_PROMTAIL_VARS=(
    "GRAFANA_PROMTAIL_DOCKER_CONTAINER"
    "GRAFANA_PROMTAIL_DOCKER_CONTEXT_DIR"
    "GRAFANA_PROMTAIL_DOCKER_DOCKERFILE"
    "GRAFANA_PROMTAIL_DOCKER_COMPOSE_CONFIG_DIR"
    "GRAFANA_PROMTAIL_DOCKER_IMAGE"
    "GRAFANA_PROMTAIL_DOCKER_IMAGE_FROM"

    "GRAFANA_PROMTAIL_CONFIG_PATH"

    ##### "GRAFANA_PROMTAIL_WEB_PUBLIC_PORT"
    "GRAFANA_PROMTAIL_WEB_DOMAIN"
  )

  readonly GRAFANA_PROMTAIL_VARS_DEFAULT=(
    "${APPX_ID}-${GRAFANA_PROMTAIL_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}grafana-promtail:3.1.0"
    "grafana/promtail:3.1.0"

    ""

    ##### "127.0.0.1:9080"
    "promtail.local"
  )

  mrcore_dotenv_init_var_array GRAFANA_PROMTAIL_VARS[@] GRAFANA_PROMTAIL_VARS_DEFAULT[@]

  if [ -z "${GRAFANA_PROMTAIL_CONFIG_PATH}" ]; then
    GRAFANA_PROMTAIL_CONFIG_PATH="${GRAFANA_PROMTAIL_DOCKER_COMPOSE_CONFIG_DIR}/default-config.yaml"
  fi

  DOCKER_COMPOSE_REQUIRED_SOURCES+=("Promtail config path" "${GRAFANA_PROMTAIL_CONFIG_PATH}")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GRAFANA_PROMTAIL_DOCKER_COMPOSE_CONFIG_DIR}/mn-grafana-promtail.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${GRAFANA_PROMTAIL_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_grafana_promtail_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_grafana_promtail_method_config() {
  mrcore_dotenv_echo_var_array GRAFANA_PROMTAIL_VARS[@]
  mrcore_echo_var "GRAFANA_PROMTAIL_DOCKER_SERVICE (host, readonly)" "${GRAFANA_PROMTAIL_DOCKER_SERVICE}"
}

function mrcmd_plugins_grafana_promtail_method_export_config() {
  mrcore_dotenv_export_var_array GRAFANA_PROMTAIL_VARS[@]
}

function mrcmd_plugins_grafana_promtail_method_install() {
  mrcmd_plugins_grafana_promtail_docker_build --no-cache
}

function mrcmd_plugins_grafana_promtail_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_grafana_promtail_method_config
      mrcmd_plugins_grafana_promtail_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${GRAFANA_PROMTAIL_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${GRAFANA_PROMTAIL_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${GRAFANA_PROMTAIL_DOCKER_CONTAINER}" \
        "${GRAFANA_PROMTAIL_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_grafana_promtail_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${GRAFANA_PROMTAIL_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${GRAFANA_PROMTAIL_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_grafana_promtail_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${GRAFANA_PROMTAIL_DOCKER_CONTEXT_DIR}" \
    "${GRAFANA_PROMTAIL_DOCKER_DOCKERFILE}" \
    "${GRAFANA_PROMTAIL_DOCKER_IMAGE}" \
    "${GRAFANA_PROMTAIL_DOCKER_IMAGE_FROM}" \
    "$@"
}
