# https://hub.docker.com/_/mysql

function mrcmd_plugins_mysql_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_mysql_method_init() {
  readonly MYSQL_NAME="Mysql"

  readonly MYSQL_VARS=(
    "MYSQL_DOCKER_CONTAINER"
    "MYSQL_DOCKER_SERVICE"
    "MYSQL_DOCKER_CONFIG_DOCKERFILE"
    "MYSQL_DOCKER_COMPOSE_CONFIG_DIR"
    "MYSQL_DOCKER_IMAGE"
    "MYSQL_DOCKER_IMAGE_FROM"
    "MYSQL_DOCKER_ADD_GENERAL_NETWORK"

    "MYSQL_DB_PUBLIC_PORT"
    "MYSQL_DB_ROOT_PASSWORD"
  )

  readonly MYSQL_VARS_DEFAULT=(
    "${APPX_ID}-db-mysql"
    "db-mysql"
    "${MRCMD_DIR}/plugins/mysql/docker"
    "${MRCMD_DIR}/plugins/mysql/docker-compose"
    "mysql:${APPX_ID}-8.0.32"
    "mysql:8.0.32-oracle"
    "false"

    "127.0.0.1:3306"
    "${APPX_DB_PASSWORD:-123456}"
  )

  mrcore_dotenv_init_var_array MYSQL_VARS[@] MYSQL_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MYSQL_DOCKER_COMPOSE_CONFIG_DIR}/db-mysql.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MYSQL_DOCKER_COMPOSE_CONFIG_DIR}/db-mysql-init.yaml")

  if [[ "${MYSQL_DOCKER_ADD_GENERAL_NETWORK}" == true ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MYSQL_DOCKER_COMPOSE_CONFIG_DIR}/general-network.yaml")
  fi
}

function mrcmd_plugins_mysql_method_config() {
  mrcore_dotenv_echo_var_array MYSQL_VARS[@]
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

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array MYSQL_VARS[@]
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
        true # "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_mysql_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image ${CC_GREEN}${MYSQL_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                 Enters to database cli in the running container ${CC_GREEN}${MYSQL_DOCKER_CONTAINER}${CC_END}"
  echo -e "  into                Enters to shell in the running container ${CC_GREEN}${MYSQL_DOCKER_CONTAINER}${CC_END}"
}

# private
function mrcmd_plugins_mysql_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${MYSQL_DOCKER_CONFIG_DOCKERFILE}" \
    "${MYSQL_DOCKER_IMAGE}" \
    "${MYSQL_DOCKER_IMAGE_FROM}" \
    "$@"
}
