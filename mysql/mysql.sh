# https://hub.docker.com/_/mysql

function mrcmd_plugins_mysql_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_mysql_method_init() {
  export MYSQL_DOCKER_SERVICE="db-mysql"

  readonly MYSQL_CAPTION="Mysql"

  readonly MYSQL_VARS=(
    "MYSQL_DOCKER_CONTAINER"
    "MYSQL_DOCKER_CONTEXT_DIR"
    "MYSQL_DOCKER_DOCKERFILE"
    "MYSQL_DOCKER_COMPOSE_CONFIG_DIR"
    "MYSQL_DOCKER_IMAGE"
    "MYSQL_DOCKER_IMAGE_FROM"

    "MYSQL_DB_PUBLIC_PORT"
    "MYSQL_DB_ROOT_PASSWORD"
  )

  readonly MYSQL_VARS_DEFAULT=(
    "${APPX_ID}-${MYSQL_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}mysql:8.2.0"
    "mysql:8.2.0-oracle"

    "127.0.0.1:3306"
    "${APPX_DB_PASSWORD:-123456}"
  )

  mrcore_dotenv_init_var_array MYSQL_VARS[@] MYSQL_VARS_DEFAULT[@]
  mrcmd_plugins_mysql_db_dsn_init

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MYSQL_DOCKER_COMPOSE_CONFIG_DIR}/db-mysql.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MYSQL_DOCKER_COMPOSE_CONFIG_DIR}/db-mysql-init.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${MYSQL_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_mysql_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_mysql_method_config() {
  mrcore_dotenv_echo_var_array MYSQL_VARS[@]
  mrcore_echo_var "MYSQL_DOCKER_SERVICE (host, readonly)" "${MYSQL_DOCKER_SERVICE}"
  mrcore_echo_var "MYSQL_DB_DSN (readonly)" "${MYSQL_DB_DSN}"
  mrcore_echo_var "MYSQL_DB_URL_JDBC (readonly)" "${MYSQL_DB_URL_JDBC}"
}

function mrcmd_plugins_mysql_method_export_config() {
  mrcore_dotenv_export_var_array MYSQL_VARS[@]
}

function mrcmd_plugins_mysql_method_install() {
  mrcmd_plugins_mysql_docker_build --no-cache
}

function mrcmd_plugins_mysql_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_mysql_method_config
      mrcmd_plugins_mysql_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${MYSQL_DOCKER_SERVICE}" \
        mysql \
        -u "root" \
        -p"${MYSQL_DB_ROOT_PASSWORD}" \
        "${APPX_DB_NAME}"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${MYSQL_DOCKER_SERVICE}" \
        bash # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${MYSQL_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${MYSQL_DOCKER_CONTAINER}" \
        "${MYSQL_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_mysql_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${MYSQL_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${MYSQL_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to mysql cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_mysql_db_dsn_init() {
  readonly MYSQL_DB_DSN="mysql://${MYSQL_DB_USER}:${MYSQL_DB_PASSWORD}@tcp${MYSQL_DOCKER_SERVICE}:3306/${MYSQL_DB_NAME}"
  readonly MYSQL_DB_URL_JDBC="jdbc:mysql://${MYSQL_DOCKER_SERVICE}:3306/${MYSQL_DB_NAME}"
}

# private
function mrcmd_plugins_mysql_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${MYSQL_DOCKER_CONTEXT_DIR}" \
    "${MYSQL_DOCKER_DOCKERFILE}" \
    "${MYSQL_DOCKER_IMAGE}" \
    "${MYSQL_DOCKER_IMAGE_FROM}" \
    "$@"
}
