# https://hub.docker.com/_/node

function mrcmd_plugins_nodejs_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_nodejs_method_init() {
  readonly NODEJS_NAME="NodeJS"

  readonly NODEJS_VARS=(
    "NODEJS_DOCKER_CONTAINER"
    "NODEJS_DOCKER_SERVICE"
    "NODEJS_DOCKER_CONFIG_DOCKERFILE"
    "NODEJS_DOCKER_COMPOSE_CONFIG_DIR"
    "NODEJS_DOCKER_IMAGE"
    "NODEJS_DOCKER_IMAGE_FROM"

    "NODEJS_PUBLIC_PORT"
    "NODEJS_APPX_APP_DIR"
  )

  readonly NODEJS_VARS_DEFAULT=(
    "${APPX_ID}-web-app"
    "web-app"
    "${MRCMD_DIR}/plugins/nodejs/docker"
    "${MRCMD_DIR}/plugins/nodejs/docker-compose"
    "node:${APPX_ID}-19.9"
    "node:19.9.0-alpine3.17"

    "127.0.0.1:3000"
    "$(realpath "${APPX_DIR}")/app"
  )

  mrcore_dotenv_init_var_array NODEJS_VARS[@] NODEJS_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${NODEJS_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml")
}

function mrcmd_plugins_nodejs_method_config() {
  mrcore_dotenv_echo_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_export_config() {
  mrcore_dotenv_export_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_install() {
  mrcmd_plugins_nodejs_docker_build --no-cache
  mrcmd_plugins_call_function "nodejs/docker-cli" npm install
}

function mrcmd_plugins_nodejs_method_uninstall() {
  mrcore_lib_rmdir "${NODEJS_APPX_APP_DIR}/node_modules"
}

function mrcmd_plugins_nodejs_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array NODEJS_VARS[@]
      mrcmd_plugins_nodejs_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "nodejs/docker-cli" "$@"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${NODEJS_DOCKER_CONTAINER}" \
        "${NODEJS_DOCKER_SERVICE}"
      ;;

    shell)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${NODEJS_DOCKER_SERVICE}" \
        "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_nodejs_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image ${CC_GREEN}${NODEJS_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                         Enters to node cli in a container of image ${CC_GREEN}${NODEJS_DOCKER_IMAGE}${CC_END}"
  echo -e "  restart                     Restarts the container ${CC_GREEN}${NODEJS_DOCKER_CONTAINER}${CC_END}"
  echo -e "  shell                       Enters to shell in the running container ${CC_GREEN}${NODEJS_DOCKER_CONTAINER}${CC_END}"
}

# private
function mrcmd_plugins_nodejs_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${NODEJS_DOCKER_CONFIG_DOCKERFILE}" \
    "${NODEJS_DOCKER_IMAGE}" \
    "${NODEJS_DOCKER_IMAGE_FROM}" \
    "$@"
}
