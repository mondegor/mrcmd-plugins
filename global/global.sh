
function mrcmd_plugins_global_method_init() {
  readonly GLOBAL_NAME="Global vars"

  readonly GLOBAL_VARS=(
    "APPX_ID"
    "APPX_NETWORK"

    "ALPINE_INSTALL_BASH"
    "HOST_USER_ID"
    "HOST_GROUP_ID"
    "APPX_TZ"

    "APPX_APP_DIR"

    "APPX_DB_TYPE"
    "APPX_DB_HOST"
    "APPX_DB_PORT"
    "APPX_DB_USER"
    "APPX_DB_PASSWORD"
    "APPX_DB_NAME"
    "APPX_DB_URL"
  )

  readonly GLOBAL_VARS_DEFAULT=(
    "sx"
    "service-network"

    "false"
    "1000"
    "1000"
    "Europe/Moscow"

    "${APPX_DIR}/app"

    "postgres"
    "db-postgres" # ${POSTGRES_DOCKER_SERVICE}
    "5432"
    "sx_user"
    "12345"
    "sx_db"
    ""
  )

  mrcore_dotenv_init_var_array GLOBAL_VARS[@] GLOBAL_VARS_DEFAULT[@]
  mrcmd_plugins_global_db_url_init
}

function mrcmd_plugins_global_method_config() {
  mrcore_dotenv_echo_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_export_config() {
  mrcore_dotenv_export_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_exec() {
  local currentCommand="${1:?}"

  case ${currentCommand} in

    chown)
      sudo chown -R "${HOST_USER_ID}:${HOST_GROUP_ID}" "${APPX_DIR}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_global_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  chown                       sudo chown -R ${HOST_USER_ID}:${HOST_GROUP_ID} ${APPX_DIR}"
}

function mrcmd_plugins_global_db_url_init() {
  case ${APPX_DB_TYPE} in

    postgres)
      APPX_DB_URL="postgres://${APPX_DB_USER}:${APPX_DB_PASSWORD}@${APPX_DB_HOST}:${APPX_DB_PORT}/${APPX_DB_NAME}?sslmode=disable"
      ;;

    mysql)
      APPX_DB_URL="mysql://${APPX_DB_USER}:${APPX_DB_PASSWORD}@tcp(${APPX_DB_HOST}:${APPX_DB_PORT})/${APPX_DB_NAME}"
      ;;

  esac
}
