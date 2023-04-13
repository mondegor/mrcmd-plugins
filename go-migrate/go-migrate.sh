# https://hub.docker.com/r/migrate/migrate

readonly GO_MIGRATE_VARS=(
  "GO_MIGRATE_DOCKER_CONFIG_DIR"
  "GO_MIGRATE_DOCKER_IMAGE"
  "GO_MIGRATE_DOCKER_IMAGE_FROM"
  "GO_MIGRATE_DOCKER_NETWORK"
  "GO_MIGRATE_TZ"
  "GO_MIGRATE_HOST_USER_ID"
  "GO_MIGRATE_HOST_GROUP_ID"
  "GO_MIGRATE_APP_VOLUME"
  "GO_MIGRATE_DB_URL"
)

# default values of array: GO_MIGRATE_VARS
readonly GO_MIGRATE_VARS_DEFAULT=(
  "${MRCMD_DIR}/plugins/go-migrate/docker"
  "${APPX_ID:-appx}-migrate/migrate:v4.15.2"
  "migrate/migrate:v4.15.2"
  "${APPX_NETWORK:-appx-network}"
  "${TZ:-Europe/Moscow}"
  "${HOST_USER_ID:-1000}"
  "${HOST_GROUP_ID:-1000}"
  "$(realpath "${APPX_DIR}")/migrations"
  "postgres://${APPX_DB_USER:-user_app}:${APPX_DB_PASSWORD:-12345}@${APPX_DB_HOST:-db-postgres:5432}/${APPX_DB_NAME:-db_app}?sslmode=disable"
  # "$(realpath "${APPX_DIR}")/migrations-mysql"
  # "mysql://${APPX_DB_USER:-user_app}:${APPX_DB_PASSWORD:-12345}@tcp(${APPX_DB_HOST:-db-mysql:3306})/${APPX_DB_NAME:-db_app}"
)

function mrcmd_plugins_go_migrate_method_config() {
  mrcore_dotenv_echo_var_array GO_MIGRATE_VARS[@]
}

function mrcmd_plugins_go_migrate_method_export_config() {
  mrcore_dotenv_export_var_array GO_MIGRATE_VARS[@]
}

function mrcmd_plugins_go_migrate_method_init() {
  mrcore_dotenv_init_var_array GO_MIGRATE_VARS[@] GO_MIGRATE_VARS_DEFAULT[@]
}

function mrcmd_plugins_go_migrate_method_install() {
  mrcmd_plugins_call_function "go-migrate/docker-build" --no-cache
}

function mrcmd_plugins_go_migrate_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    build)
      mrcmd_plugins_call_function "go-migrate/docker-build" "$@"
      ;;

    ## Run migrations UP
    up)
      mrcmd_plugins_call_function "go-migrate/docker-run" up
      ;;

    ## Rollback migrations against non test DB
    down)
      mrcmd_plugins_call_function "go-migrate/docker-run" down 1
      ;;

    init)
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql -seq init
      ;;

    ## Create a DB migration files e.g `make migrate-create name=migration-name`
    create)
      # bash ./utils/golang-db-migrate.sh create -ext sql -dir /migrations ${ARGS}
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql "$@"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_go_migrate_method_help() {
  echo -e "  ${CC_YELLOW}DB migrate utility:${CC_END}"
  echo -e "    ${CC_GREEN}build${CC_END}   Build"
  echo -e "    ${CC_GREEN}up${CC_END}      Run migrations UP"
  echo -e "    ${CC_GREEN}init${CC_END}    Run migrations INIT"
  echo -e "    ${CC_GREEN}down${CC_END}    Rollback migrations against non test DB"
  echo -e "    ${CC_GREEN}create${CC_END}  Create a DB migration files e.g 'make migrate-create name=migration-name'"
  echo ""
}
