# https://hub.docker.com/r/prom/node-exporter

function mrcmd_plugins_nodeexporter_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_nodeexporter_method_init() {
  export NODEEXPORTER_DOCKER_SERVICE="mn-nodeexporter"

  readonly NODEEXPORTER_CAPTION="Node Exporter"

  readonly NODEEXPORTER_VARS=(
    "NODEEXPORTER_DOCKER_CONTAINER"
    "NODEEXPORTER_DOCKER_CONTEXT_DIR"
    "NODEEXPORTER_DOCKER_DOCKERFILE"
    "NODEEXPORTER_DOCKER_COMPOSE_CONFIG_DIR"
    "NODEEXPORTER_DOCKER_IMAGE"
    "NODEEXPORTER_DOCKER_IMAGE_FROM"
  )

  readonly NODEEXPORTER_VARS_DEFAULT=(
    "${APPX_ID}-${NODEEXPORTER_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}node-exporter:1.8.2"
    "prom/node-exporter:v1.8.2"
  )

  mrcore_dotenv_init_var_array NODEEXPORTER_VARS[@] NODEEXPORTER_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${NODEEXPORTER_DOCKER_COMPOSE_CONFIG_DIR}/mn-nodeexporter.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${NODEEXPORTER_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_nodeexporter_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_nodeexporter_method_config() {
  mrcore_dotenv_echo_var_array NODEEXPORTER_VARS[@]
  mrcore_echo_var "NODEEXPORTER_DOCKER_SERVICE (host, readonly)" "${NODEEXPORTER_DOCKER_SERVICE}"
}

function mrcmd_plugins_nodeexporter_method_export_config() {
  mrcore_dotenv_export_var_array NODEEXPORTER_VARS[@]
}

function mrcmd_plugins_nodeexporter_method_install() {
  mrcmd_plugins_nodeexporter_docker_build --no-cache
}

function mrcmd_plugins_nodeexporter_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_nodeexporter_method_config
      mrcmd_plugins_nodeexporter_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${NODEEXPORTER_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${NODEEXPORTER_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${NODEEXPORTER_DOCKER_CONTAINER}" \
        "${NODEEXPORTER_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_nodeexporter_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${NODEEXPORTER_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${NODEEXPORTER_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_nodeexporter_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${NODEEXPORTER_DOCKER_CONTEXT_DIR}" \
    "${NODEEXPORTER_DOCKER_DOCKERFILE}" \
    "${NODEEXPORTER_DOCKER_IMAGE}" \
    "${NODEEXPORTER_DOCKER_IMAGE_FROM}" \
    "$@"
}
