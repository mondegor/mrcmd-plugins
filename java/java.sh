# https://hub.docker.com/_/openjdk

function mrcmd_plugins_java_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_java_method_init() {
  readonly JAVA_CAPTION="Java OpenJDK 17"
  readonly JAVA_DOCKER_SERVICE="web-app"

  readonly JAVA_VARS=(
    "JAVA_DOCKER_CONTAINER"
    "JAVA_DOCKER_CONFIG_DOCKERFILE"
    "JAVA_DOCKER_COMPOSE_CONFIG_DIR"
    "JAVA_DOCKER_COMPOSE_CONFIG_FILE"
    "JAVA_DOCKER_IMAGE"
    "JAVA_DOCKER_IMAGE_FROM"

    "JAVA_WEBAPP_PUBLIC_PORT"
    "JAVA_WEBAPP_BIND"
    "JAVA_WEBAPP_PORT"

    "JAVA_APP_ENV_FILE"
    "JAVA_APP_JAR_PATH"
  )

  readonly JAVA_VARS_DEFAULT=(
    "${APPX_ID}-web-app"
    "${MRCMD_PLUGINS_DIR}/java/docker"
    "${MRCMD_PLUGINS_DIR}/java/docker-compose"
    "${APPX_DIR}/app.yaml"
    "${DOCKER_PACKAGE_NAME}openjdk:17"
    "openjdk:17-alpine3.14"

    "127.0.0.1:8080"
    "0.0.0.0"
    "8080"

    "${APPX_DIR}/env.app"
    "./app.jar"
  )

  mrcore_dotenv_init_var_array JAVA_VARS[@] JAVA_VARS_DEFAULT[@]

  mrcmd_plugins_call_function "docker-compose/register" \
    "${JAVA_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml" \
    "${JAVA_APP_ENV_FILE}" \
    "${JAVA_DOCKER_COMPOSE_CONFIG_DIR}/env-file.yaml" \
    "${JAVA_DOCKER_COMPOSE_CONFIG_FILE}"
}

function mrcmd_plugins_java_method_config() {
  mrcore_dotenv_echo_var_array JAVA_VARS[@]
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
      mrcmd_plugins_call_function "java/docker-run" "${DOCKER_DEFAULT_SHELL}" "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${JAVA_DOCKER_SERVICE}" \
        "${DOCKER_DEFAULT_SHELL}"
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
    "${JAVA_DOCKER_CONFIG_DOCKERFILE}" \
    "${JAVA_DOCKER_IMAGE}" \
    "${JAVA_DOCKER_IMAGE_FROM}" \
    "$@"
}
