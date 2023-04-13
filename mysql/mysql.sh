# https://hub.docker.com/_/mysql

readonly MYSQL_VARS=(
  "MYSQL_DOCKER_CONTAINER"
  "MYSQL_DOCKER_SERVICE"
  "MYSQL_DOCKER_CONFIG_DIR"
  "MYSQL_DOCKER_CONFIG_YAML"
  "MYSQL_DOCKER_IMAGE"
  "MYSQL_DOCKER_NETWORK"
  "MYSQL_TZ"
  "MYSQL_EXT_PORT"
  "MYSQL_DB_NAME"
  "MYSQL_DB_USER"
  "MYSQL_DB_PASSWORD"
  "MYSQL_DB_ROOT_PASSWORD"
)

# default values of array: MYSQL_VARS
readonly MYSQL_VARS_DEFAULT=(
  "${APPX_ID:-appx}-db-mysql"
  "db-mysql"
  "${MRCMD_DIR}/plugins/mysql/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/mysql/docker-compose.yaml"
  "mysql:8.0.32-oracle"
  "${APPX_NETWORK:-appx-network}"
  "${TZ:-Europe/Moscow}"
  "${APPX_DB_EXT_PORT:-127.0.0.1:3306}"
  "${APPX_DB_NAME:-db_app}"
  "${APPX_DB_USER:-user_app}"
  "${APPX_DB_PASSWORD:-12345}"
  "${APPX_DB_PASSWORD:-12345}"
)

function mrcmd_plugins_mysql_method_config() {
  mrcore_dotenv_echo_var_array MYSQL_VARS[@]
}

function mrcmd_plugins_mysql_method_export_config() {
  mrcore_dotenv_export_var_array MYSQL_VARS[@]
}

function mrcmd_plugins_mysql_method_init() {
  mrcore_dotenv_init_var_array MYSQL_VARS[@] MYSQL_VARS_DEFAULT[@]

  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${MYSQL_DOCKER_CONFIG_YAML}"
  fi
}

function mrcmd_plugins_mysql_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    bash)
      mrcmd_plugins_call_function "docker-compose/command" exec "${MYSQL_DOCKER_SERVICE}" bash
      ;;

    shell)
      ## Enter to database console
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${MYSQL_DOCKER_SERVICE}" \
        mysql \
        -u "root" \
        -p"${MYSQL_DB_ROOT_PASSWORD}" \
        "${MYSQL_DB_NAME}"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_mysql_help() {
  echo -e "  ${CC_YELLOW}Mysql:${CC_END}"
  echo -e "    ${CC_GREEN}shell${CC_END}   Shell"
  echo ""
}
