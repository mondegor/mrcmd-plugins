# https://hub.docker.com/_/rabbitmq

function mrcmd_plugins_rabbitmq_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_rabbitmq_method_init() {
  readonly RABBITMQ_CAPTION="RabbitMQ"
  readonly RABBITMQ_DOCKER_SERVICE="broker-rabbitmq"

  readonly RABBITMQ_VARS=(
    "READONLY_RABBITMQ_DOCKER_HOST"
    "RABBITMQ_DOCKER_CONTAINER"
    "RABBITMQ_DOCKER_CONTEXT_DIR"
    "RABBITMQ_DOCKER_DOCKERFILE"
    "RABBITMQ_DOCKER_COMPOSE_CONFIG_DIR"
    "RABBITMQ_DOCKER_IMAGE"
    "RABBITMQ_DOCKER_IMAGE_FROM"

    "RABBITMQ_PUBLIC_PORT"
    "RABBITMQ_USER"
    "RABBITMQ_PASSWORD"

    "RABBITMQ_WEB_PUBLIC_PORT"
  )

  readonly RABBITMQ_VARS_DEFAULT=(
    "${RABBITMQ_DOCKER_SERVICE}"
    "${APPX_ID}-${RABBITMQ_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}rabbitmq:3.12.9"
    "rabbitmq:3.12.9-management-alpine"

    "127.0.0.1:5672"
    "admin"
    "123456"

    "127.0.0.1:9983"
  )

  mrcore_dotenv_init_var_array RABBITMQ_VARS[@] RABBITMQ_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${RABBITMQ_DOCKER_COMPOSE_CONFIG_DIR}/broker-rabbitmq.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${RABBITMQ_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_rabbitmq_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_rabbitmq_method_config() {
  mrcore_dotenv_echo_var_array RABBITMQ_VARS[@]
}

function mrcmd_plugins_rabbitmq_method_export_config() {
  mrcore_dotenv_export_var_array RABBITMQ_VARS[@]
}

function mrcmd_plugins_rabbitmq_method_install() {
  mrcmd_plugins_rabbitmq_docker_build --no-cache
}

function mrcmd_plugins_rabbitmq_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_rabbitmq_method_config
      mrcmd_plugins_rabbitmq_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${RABBITMQ_DOCKER_SERVICE}" \
        rabbitmqctl "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${RABBITMQ_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${RABBITMQ_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${RABBITMQ_DOCKER_CONTAINER}" \
        "${RABBITMQ_DOCKER_SERVICE}"
      ;;

    dump)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${RABBITMQ_DOCKER_SERVICE}" \
        rabbitmqadmin \
        -u "${RABBITMQ_USER}" \
        -p "${RABBITMQ_PASSWORD}" \
        export /tmp/rabbitmq.dump.json

        mrcmd_plugins_call_function "docker-compose/command" exec \
        "${RABBITMQ_DOCKER_SERVICE}" \
        cat /tmp/rabbitmq.dump.json > "./rabbitmq_$(date +'%Y-%m-%d-%H-%M-%S').dump.json"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_rabbitmq_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${RABBITMQ_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${RABBITMQ_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to rabbitmq cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
  echo -e "  dump        Export db's dump to ${CC_BLUE}./${CC_END}"
}

# private
function mrcmd_plugins_rabbitmq_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${RABBITMQ_DOCKER_CONTEXT_DIR}" \
    "${RABBITMQ_DOCKER_DOCKERFILE}" \
    "${RABBITMQ_DOCKER_IMAGE}" \
    "${RABBITMQ_DOCKER_IMAGE_FROM}" \
    "$@"
}
