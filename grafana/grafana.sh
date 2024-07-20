# https://hub.docker.com/r/grafana/grafana
# for auth type: "admin / admin", after set new password 12345678

function mrcmd_plugins_grafana_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_grafana_method_init() {
  export GRAFANA_DOCKER_SERVICE="mn-grafana"

  readonly GRAFANA_CAPTION="Grafana"

  readonly GRAFANA_VARS=(
    "GRAFANA_DOCKER_CONTAINER"
    "GRAFANA_DOCKER_CONTEXT_DIR"
    "GRAFANA_DOCKER_DOCKERFILE"
    "GRAFANA_DOCKER_COMPOSE_CONFIG_DIR"
    "GRAFANA_DOCKER_IMAGE"
    "GRAFANA_DOCKER_IMAGE_FROM"

    "GRAFANA_WEB_PUBLIC_PORT"
    "GRAFANA_WEB_DOMAIN"
  )

  readonly GRAFANA_VARS_DEFAULT=(
    "${APPX_ID}-${GRAFANA_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}grafana:11.0.1"
    "grafana/grafana:11.0.1"

    "127.0.0.1:3000"
    "grafana.local"
  )

  mrcore_dotenv_init_var_array GRAFANA_VARS[@] GRAFANA_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GRAFANA_DOCKER_COMPOSE_CONFIG_DIR}/mn-grafana.yaml")
}

function mrcmd_plugins_grafana_method_config() {
  mrcore_dotenv_echo_var_array GRAFANA_VARS[@]
  mrcore_echo_var "GRAFANA_DOCKER_SERVICE (host, readonly)" "${GRAFANA_DOCKER_SERVICE}"
}

function mrcmd_plugins_grafana_method_export_config() {
  mrcore_dotenv_export_var_array GRAFANA_VARS[@]
}

function mrcmd_plugins_grafana_method_install() {
  mrcmd_plugins_grafana_docker_build --no-cache
}

function mrcmd_plugins_grafana_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_grafana_method_config
      mrcmd_plugins_grafana_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${GRAFANA_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${GRAFANA_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${GRAFANA_DOCKER_CONTAINER}" \
        "${GRAFANA_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_grafana_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${GRAFANA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${GRAFANA_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_grafana_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${GRAFANA_DOCKER_CONTEXT_DIR}" \
    "${GRAFANA_DOCKER_DOCKERFILE}" \
    "${GRAFANA_DOCKER_IMAGE}" \
    "${GRAFANA_DOCKER_IMAGE_FROM}" \
    "$@"
}
