# https://hub.docker.com/_/postgres

readonly POSTGRES_VARS=(
  "POSTGRES_DOCKER_CONTAINER"
  "POSTGRES_DOCKER_SERVICE"
  "POSTGRES_DOCKER_CONFIG_DIR"
  "POSTGRES_DOCKER_CONFIG_YAML"
  "POSTGRES_DOCKER_IMAGE"
  "POSTGRES_DOCKER_NETWORK"
  "POSTGRES_INSTALL_BASH"
  "POSTGRES_TZ"
  "POSTGRES_DB_EXT_PORT"
  "POSTGRES_DB_NAME"
  "POSTGRES_DB_USER"
  "POSTGRES_DB_PASSWORD"
)

# default values of array: POSTGRES_VARS
readonly POSTGRES_VARS_DEFAULT=(
  "${APPX_ID:-appx}-db-postgres"
  "db-postgres"
  "${MRCMD_DIR}/plugins/postgres/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/postgres/docker-compose.yaml"
  "postgres:14.7-alpine3.17"
  "${APPX_NETWORK:-appx-network}"
  "${ALPINE_INSTALL_BASH:-false}"
  "${TZ:-Europe/Moscow}"
  "${APPX_DB_EXT_PORT:-127.0.0.1:5432}"
  "${APPX_DB_NAME:-db_app}"
  "${APPX_DB_USER:-user_app}"
  "${APPX_DB_PASSWORD:-12345}"
)

function mrcmd_plugins_postgres_method_config() {
  mrcore_dotenv_echo_var_array POSTGRES_VARS[@]
}

function mrcmd_plugins_postgres_method_export_config() {
  mrcore_dotenv_export_var_array POSTGRES_VARS[@]
}

function mrcmd_plugins_postgres_method_init() {
  mrcore_dotenv_init_var_array POSTGRES_VARS[@] POSTGRES_VARS_DEFAULT[@]

  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${POSTGRES_DOCKER_CONFIG_YAML}"
  fi
}

function mrcmd_plugins_postgres_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    bash)
      mrcmd_plugins_call_function "docker-compose/command" exec bash
      ;;

    shell)
      ## Enter to database console
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${POSTGRES_DOCKER_SERVICE}" \
        psql \
        -U "${POSTGRES_DB_USER}" \
        -d "${POSTGRES_DB_NAME}"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_postgres_help() {
  echo -e "  ${CC_YELLOW}Postgres:${CC_END}"
  echo -e "    ${CC_GREEN}shell${CC_END}   Shell"
  echo ""
}
