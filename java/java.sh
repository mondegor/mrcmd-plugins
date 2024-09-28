# https://hub.docker.com/_/openjdk

function mrcmd_plugins_java_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_java_method_init() {
  export JAVA_DOCKER_SERVICE="web-app"

  readonly JAVA_CAPTION="Java OpenJDK 17"

  readonly JAVA_VARS=(
    "JAVA_DOCKER_CONTAINER"
    "JAVA_DOCKER_CONTEXT_DIR"
    "JAVA_DOCKER_DOCKERFILE"
    "JAVA_DOCKER_COMPOSE_CONFIG_DIR"
    "JAVA_DOCKER_IMAGE"
    "JAVA_DOCKER_IMAGE_FROM"

    ##### "JAVA_WEBAPP_PUBLIC_PORT"
    "JAVA_WEBAPP_INTERNAL_PORT"
    "JAVA_WEBAPP_DOMAIN"

    "JAVA_APPX_ENV_FILE"
    "JAVA_APPX_JAR_PATH"
  )

  readonly JAVA_VARS_DEFAULT=(
    "${APPX_ID}-${JAVA_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}openjdk:17"
    "openjdk:17-alpine3.14"

    ##### "127.0.0.1:8080"
    "8080"
    "web-app.local"

    "${APPX_DIR}/.env"
    "./app.jar"
  )

  mrcore_dotenv_init_var_array JAVA_VARS[@] JAVA_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${JAVA_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${JAVA_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_java_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_java_method_config() {
  mrcore_dotenv_echo_var_array JAVA_VARS[@]
  mrcore_echo_var "JAVA_DOCKER_SERVICE (host, readonly)" "${JAVA_DOCKER_SERVICE}"
}

function mrcmd_plugins_java_method_export_config() {
  mrcore_dotenv_export_var_array JAVA_VARS[@]
}

function mrcmd_plugins_java_method_install() {
  mrcmd_plugins_java_docker_build --no-cache
}

function mrcmd_plugins_java_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_java_method_config
      mrcmd_plugins_java_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "java/docker-run" java "$@"
      ;;

    shell)
      # sh - shell name
      mrcmd_plugins_call_function "java/docker-run" sh "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${JAVA_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${JAVA_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${JAVA_DOCKER_CONTAINER}" \
        "${JAVA_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_java_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${JAVA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'java [arguments]' in a container of the image"
  echo -e "  shell               Exec shell in a container of the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${JAVA_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_java_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${JAVA_DOCKER_CONTEXT_DIR}" \
    "${JAVA_DOCKER_DOCKERFILE}" \
    "${JAVA_DOCKER_IMAGE}" \
    "${JAVA_DOCKER_IMAGE_FROM}" \
    "$@"
}
