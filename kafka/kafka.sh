# https://hub.docker.com/r/confluentinc/cp-kafka

# To learn about configuring Kafka for access across networks see
# https://www.confluent.io/blog/kafka-client-cannot-connect-to-broker-on-aws-on-docker-etc

function mrcmd_plugins_kafka_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "zookeeper")
}

function mrcmd_plugins_kafka_method_init() {
  readonly KAFKA_CAPTION="Apache Kafka"
  readonly KAFKA_DOCKER_SERVICE="broker-kafka"

  readonly KAFKA_VARS=(
    "READONLY_KAFKA_DOCKER_HOST"
    "KAFKA_DOCKER_CONTAINER"
    "KAFKA_DOCKER_CONTEXT_DIR"
    "KAFKA_DOCKER_DOCKERFILE"
    "KAFKA_DOCKER_COMPOSE_CONFIG_DIR"
    "KAFKA_DOCKER_IMAGE"
    "KAFKA_DOCKER_IMAGE_FROM"

    "KAFKA_PUBLIC_PORT"
    "KAFKA_ZOOKEEPER_HOST_PORT"
  )

  readonly KAFKA_VARS_DEFAULT=(
    "${KAFKA_DOCKER_SERVICE}"
    "${APPX_ID}-${KAFKA_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}kafka:7.4.3"
    "confluentinc/cp-kafka:7.4.3"

    "127.0.0.1:9094"
    "db-zookeeper:2181" # ${ZOOKEEPER_DOCKER_SERVICE}
  )

  mrcore_dotenv_init_var_array KAFKA_VARS[@] KAFKA_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${KAFKA_DOCKER_COMPOSE_CONFIG_DIR}/broker-kafka.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${KAFKA_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_kafka_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_kafka_method_config() {
  mrcore_dotenv_echo_var_array KAFKA_VARS[@]
}

function mrcmd_plugins_kafka_method_export_config() {
  mrcore_dotenv_export_var_array KAFKA_VARS[@]
}

function mrcmd_plugins_kafka_method_install() {
  mrcmd_plugins_kafka_docker_build --no-cache
}

function mrcmd_plugins_kafka_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_kafka_method_config
      mrcmd_plugins_kafka_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${KAFKA_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${KAFKA_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${KAFKA_DOCKER_CONTAINER}" \
        "${KAFKA_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_kafka_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${KAFKA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${KAFKA_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts kafka containers"
}

# private
function mrcmd_plugins_kafka_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${KAFKA_DOCKER_CONTEXT_DIR}" \
    "${KAFKA_DOCKER_DOCKERFILE}" \
    "${KAFKA_DOCKER_IMAGE}" \
    "${KAFKA_DOCKER_IMAGE_FROM}" \
    "$@"
}
