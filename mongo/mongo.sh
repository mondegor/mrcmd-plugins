# https://hub.docker.com/_/mongo

function mrcmd_plugins_mongo_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_mongo_method_init() {
  export MONGO_DOCKER_SERVICE="db-mongo"

  readonly MONGO_CAPTION="Mongo Jammy"

  readonly MONGO_VARS=(
    "MONGO_DOCKER_CONTAINER"
    "MONGO_DOCKER_CONTEXT_DIR"
    "MONGO_DOCKER_DOCKERFILE"
    "MONGO_DOCKER_COMPOSE_CONFIG_DIR"
    "MONGO_DOCKER_IMAGE"
    "MONGO_DOCKER_IMAGE_FROM"

    "MONGO_DB_PUBLIC_PORT"
    "MONGO_DB_ROOT_USER"
    "MONGO_DB_ROOT_PASSWORD"
  )

  readonly MONGO_VARS_DEFAULT=(
    "${APPX_ID}-${MONGO_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}mongo:6.0.11"
    "mongo:6.0.11-jammy"

    "127.0.0.1:27017"
    "mongo"
    "${APPX_DB_PASSWORD:-123456}"
  )

  mrcore_dotenv_init_var_array MONGO_VARS[@] MONGO_VARS_DEFAULT[@]
  mrcmd_plugins_mongo_db_dsn_init

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MONGO_DOCKER_COMPOSE_CONFIG_DIR}/db-mongo.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MONGO_DOCKER_COMPOSE_CONFIG_DIR}/db-mongo-init.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${MONGO_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_mongo_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_mongo_method_config() {
  mrcore_dotenv_echo_var_array MONGO_VARS[@]
  mrcore_echo_var "MONGO_DOCKER_SERVICE (host, readonly)" "${MONGO_DOCKER_SERVICE}"
  mrcore_echo_var "MONGO_DB_DSN (readonly)" "${MONGO_DB_DSN}"
  mrcore_echo_var "MONGO_DB_URL_JDBC (readonly)" "${MONGO_DB_URL_JDBC}"
}

function mrcmd_plugins_mongo_method_export_config() {
  mrcore_dotenv_export_var_array MONGO_VARS[@]
}

function mrcmd_plugins_mongo_method_install() {
  mrcmd_plugins_mongo_docker_build --no-cache
}

function mrcmd_plugins_mongo_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_mongo_method_config
      mrcmd_plugins_mongo_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${MONGO_DOCKER_SERVICE}" \
        mongosh \
        --host "${MONGO_DOCKER_CONTAINER}" \
        -u "${MONGO_DB_ROOT_USER}" \
        -p "${MONGO_DB_ROOT_PASSWORD}" \
        --authenticationDatabase admin \
        some-db
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${MONGO_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${MONGO_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${MONGO_DOCKER_CONTAINER}" \
        "${MONGO_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_mongo_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${MONGO_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${MONGO_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to mongosh in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

function mrcmd_plugins_mongo_db_dsn_init() {
  readonly MONGO_DB_DSN="mongodb://${MONGO_DB_USER}:${MONGO_DB_PASSWORD}@${MONGO_DOCKER_SERVICE}:27017/${MONGO_DB_NAME}"
  readonly MONGO_DB_URL_JDBC="jdbc:mongo://${MONGO_DOCKER_SERVICE}:27017/${MONGO_DB_NAME}"
}

# private
function mrcmd_plugins_mongo_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${MONGO_DOCKER_CONTEXT_DIR}" \
    "${MONGO_DOCKER_DOCKERFILE}" \
    "${MONGO_DOCKER_IMAGE}" \
    "${MONGO_DOCKER_IMAGE_FROM}" \
    "$@"
}
