# https://hub.docker.com/r/provectuslabs/kafka-ui
# https://github.com/provectus/kafka-ui

function mrcmd_plugins_kafka_ui_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "traefik")
}

function mrcmd_plugins_kafka_ui_method_init() {
  export KAFKA_UI_DOCKER_SERVICE="broker-kafka-ui"

  readonly KAFKA_UI_CAPTION="UI for Apache Kafka"

  readonly KAFKA_UI_VARS=(
    "KAFKA_UI_DOCKER_CONTAINER"
    "KAFKA_UI_DOCKER_CONTEXT_DIR"
    "KAFKA_UI_DOCKER_DOCKERFILE"
    "KAFKA_UI_DOCKER_COMPOSE_CONFIG_DIR"
    "KAFKA_UI_DOCKER_IMAGE"
    "KAFKA_UI_DOCKER_IMAGE_FROM"

    "KAFKA_UI_KAFKA_HOSTS_PORTS"
    "KAFKA_UI_ZOOKEEPER_HOST_PORT"

    # "KAFKA_UI_WEB_PUBLIC_PORT"
    "KAFKA_UI_WEB_INTERNAL_PORT"
    "KAFKA_UI_WEB_DOMAIN"
  )

  readonly KAFKA_UI_VARS_DEFAULT=(
    "${APPX_ID}-${KAFKA_UI_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}kafka-ui:53a655"
    "provectuslabs/kafka-ui:53a6553765a806eda9905c43bfcfe09da6812035"

    "broker-kafka:9092" # ${KAFKA_DOCKER_SERVICE} or broker-kafka1:9092,broker-kafka2:9092
    "db-zookeeper:2181" # ${ZOOKEEPER_DOCKER_SERVICE}

    # "127.0.0.1:9952"
    "8080"
    "kafka.local"
  )

  mrcore_dotenv_init_var_array KAFKA_UI_VARS[@] KAFKA_UI_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${KAFKA_UI_DOCKER_COMPOSE_CONFIG_DIR}/broker-kafka-ui.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${KAFKA_UI_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_kafka_ui_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_kafka_ui_method_config() {
  mrcore_dotenv_echo_var_array KAFKA_UI_VARS[@]
  mrcore_echo_var "KAFKA_UI_DOCKER_SERVICE (host, readonly)" "${KAFKA_UI_DOCKER_SERVICE}"
}

function mrcmd_plugins_kafka_ui_method_export_config() {
  mrcore_dotenv_export_var_array KAFKA_UI_VARS[@]
}

function mrcmd_plugins_kafka_ui_method_install() {
  mrcmd_plugins_kafka_ui_docker_build --no-cache
}

function mrcmd_plugins_kafka_ui_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_kafka_ui_method_config
      mrcmd_plugins_kafka_ui_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${KAFKA_UI_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${KAFKA_UI_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${KAFKA_UI_DOCKER_CONTAINER}" \
        "${KAFKA_UI_DOCKER_SERVICE}"

      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${KAFKA_UI_NGINX_DOCKER_CONTAINER}" \
        "${KAFKA_UI_NGINX_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_kafka_ui_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${KAFKA_UI_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${KAFKA_UI_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running kafka-ui container"
  echo -e "  logs        View output from the running kafka-ui container"
  echo -e "  restart     Restart kafka-ui and nginx containers"
}

# private
function mrcmd_plugins_kafka_ui_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${KAFKA_UI_DOCKER_CONTEXT_DIR}" \
    "${KAFKA_UI_DOCKER_DOCKERFILE}" \
    "${KAFKA_UI_DOCKER_IMAGE}" \
    "${KAFKA_UI_DOCKER_IMAGE_FROM}" \
    "$@"
}
