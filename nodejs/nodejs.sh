# https://hub.docker.com/_/node

function mrcmd_plugins_nodejs_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_nodejs_method_init() {
  readonly NODEJS_CAPTION="NodeJS"
  readonly NODEJS_DOCKER_SERVICE="web-app"

  readonly NODEJS_VARS=(
    "READONLY_NODEJS_DOCKER_HOST"
    "NODEJS_DOCKER_CONTAINER"
    "NODEJS_DOCKER_CONTEXT_DIR"
    "NODEJS_DOCKER_DOCKERFILE"
    "NODEJS_DOCKER_COMPOSE_CONFIG_DIR"
    "NODEJS_DOCKER_IMAGE"
    "NODEJS_DOCKER_IMAGE_FROM"

    "NODEJS_WEBAPP_PUBLIC_PORT"

    "NODEJS_APP_ENV_FILE"
  )

  readonly NODEJS_VARS_DEFAULT=(
    "${NODEJS_DOCKER_SERVICE}"
    "${APPX_ID}-${NODEJS_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}node:21.2.0"
    "node:21.2.0-alpine3.18"

    "127.0.0.1:3000"

    "${APPX_DIR}/.env.app"
  )

  mrcore_dotenv_init_var_array NODEJS_VARS[@] NODEJS_VARS_DEFAULT[@]

  mrcmd_plugins_call_function "docker-compose/register" \
    "${NODEJS_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml" \
    "${NODEJS_APP_ENV_FILE}" \
    "${NODEJS_DOCKER_COMPOSE_CONFIG_DIR}/env-file.yaml"

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${NODEJS_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_nodejs_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_nodejs_method_config() {
  mrcore_dotenv_echo_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_export_config() {
  mrcore_dotenv_export_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_install() {
  mrcmd_plugins_nodejs_docker_build --no-cache
  mrcmd_plugins_call_function "nodejs/docker-run" npm install
}

function mrcmd_plugins_nodejs_method_uninstall() {
  mrcore_lib_rmdir "${APPX_WORK_DIR}/node_modules"
}

function mrcmd_plugins_nodejs_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_nodejs_method_config
      mrcmd_plugins_nodejs_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "nodejs/docker-run" node "$@"
      ;;

    shell)
      mrcmd_plugins_call_function "nodejs/docker-run" "${DOCKER_DEFAULT_SHELL}" "$@"
      ;;

    npm)
      currentCommand="${1-}"
      local npmCommands=("build" "start" "test")

      if mrcore_lib_in_array "${currentCommand}" npmCommands[@] ; then
        mrcmd_plugins_call_function "nodejs/docker-run" npm run "$@"
        return
      fi

      mrcmd_plugins_call_function "nodejs/docker-run" npm "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${NODEJS_DOCKER_SERVICE}" \
        "${DOCKER_DEFAULT_SHELL}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${NODEJS_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${NODEJS_DOCKER_CONTAINER}" \
        "${NODEJS_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_nodejs_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${NODEJS_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'node [arguments]' in a container of the image"
  echo -e "  shell               Exec shell in a container of the image"
  echo -e "  npm [arguments]     Runs 'npm [arguments]' in a container of the image"
  echo -e "    install           Installs the dependencies to the local 'node_modules' dir"
  echo -e "    update            Updates the dependencies in the local 'node_modules' dir"
  echo -e "    build             Creates a production build of your app"
  echo -e "    start             Starts node server"
  echo -e "    test              Runs test scripts"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${NODEJS_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_nodejs_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${NODEJS_DOCKER_CONTEXT_DIR}" \
    "${NODEJS_DOCKER_DOCKERFILE}" \
    "${NODEJS_DOCKER_IMAGE}" \
    "${NODEJS_DOCKER_IMAGE_FROM}" \
    "$@"
}
