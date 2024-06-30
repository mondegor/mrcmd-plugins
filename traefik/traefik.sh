# https://hub.docker.com/_/traefik
# https://doc.traefik.io/traefik/routing/overview/
# https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/

function mrcmd_plugins_traefik_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_traefik_method_init() {
  readonly TRAEFIK_CAPTION="Traefik"
  readonly TRAEFIK_DOCKER_SERVICE="proxy-traefik"

  readonly TRAEFIK_VARS=(
    "READONLY_TRAEFIK_DOCKER_HOST"
    "TRAEFIK_DOCKER_CONTAINER"
    "TRAEFIK_DOCKER_CONTEXT_DIR"
    "TRAEFIK_DOCKER_DOCKERFILE"
    "TRAEFIK_DOCKER_COMPOSE_CONFIG_DIR"
    "TRAEFIK_DOCKER_IMAGE"
    "TRAEFIK_DOCKER_IMAGE_FROM"

    "TRAEFIK_PROXY_PUBLIC_PORT"
    "TRAEFIK_API_INTERNAL_PORT"
    "TRAEFIK_WEB_DOMAIN"

    "TRAEFIK_NETWORK"
  )

  readonly TRAEFIK_VARS_DEFAULT=(
    "${TRAEFIK_DOCKER_SERVICE}"
    "${APPX_ID}-${TRAEFIK_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}traefik:2.11.2"
    "traefik:2.11.2"

    "127.0.0.1:80"
    "19090"
    "traefik.local"

    "${DOCKER_COMPOSE_LOCAL_NETWORK}"
  )

  mrcore_dotenv_init_var_array TRAEFIK_VARS[@] TRAEFIK_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${TRAEFIK_DOCKER_COMPOSE_CONFIG_DIR}/proxy-traefik.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${TRAEFIK_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_traefik_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_traefik_method_config() {
  mrcore_dotenv_echo_var_array TRAEFIK_VARS[@]
}

function mrcmd_plugins_traefik_method_export_config() {
  mrcore_dotenv_export_var_array TRAEFIK_VARS[@]
}

function mrcmd_plugins_traefik_method_install() {
  mrcmd_plugins_traefik_docker_build --no-cache
}

function mrcmd_plugins_traefik_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_traefik_method_config
      mrcmd_plugins_traefik_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${TRAEFIK_DOCKER_SERVICE}" \
        "sh" # "${DOCKER_DEFAULT_SHELL}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${TRAEFIK_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${TRAEFIK_DOCKER_CONTAINER}" \
        "${TRAEFIK_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_traefik_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${TRAEFIK_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${TRAEFIK_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_traefik_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${TRAEFIK_DOCKER_CONTEXT_DIR}" \
    "${TRAEFIK_DOCKER_DOCKERFILE}" \
    "${TRAEFIK_DOCKER_IMAGE}" \
    "${TRAEFIK_DOCKER_IMAGE_FROM}" \
    "$@"
}
