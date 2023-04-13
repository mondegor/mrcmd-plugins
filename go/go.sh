# https://hub.docker.com/_/golang

readonly GO_VARS=(
  "GO_DOCKER_CONFIG_DIR"
  "GO_DOCKER_IMAGE"
  "GO_DOCKER_IMAGE_FROM"
  "GO_DOCKER_NETWORK"
  "GO_TZ"
  "GO_HOST_USER_ID"
  "GO_HOST_GROUP_ID"
  "GO_APPX_HOST"
  "GO_APPX_PORT"
  "GO_APPX_EXT_PORT"
  "GO_LIB_DIR"
  "GO_APP_VOLUME"
  "GO_DB_HOST"
  "GO_DB_PORT"
  "GO_DB_NAME"
  "GO_DB_USER"
  "GO_DB_PASSWORD"
)

# default values of array: GO_VARS
readonly GO_VARS_DEFAULT=(
  "${MRCMD_DIR}/plugins/go/docker"
  "${APPX_ID:-appx}-golang:1.20.3-alpine3.17"
  "golang:1.20.3-alpine3.17"
  "${APPX_NETWORK:-appx-network}"
  "${TZ:-Europe/Moscow}"
  "${HOST_USER_ID:-1000}"
  "${HOST_GROUP_ID:-1000}"
  "127.0.0.1"
  "8090"
  "127.0.0.1:8090"
  "$(realpath "${APPX_DIR}")/golang"
  "$(realpath "${APPX_DIR}")/app"
  "${APPX_DB_HOST:-db-postgres}"
  "${APPX_DB_PORT:-5432}"
  "${APPX_DB_NAME:-db_app}"
  "${APPX_DB_USER:-user_app}"
  "${APPX_DB_PASSWORD:-12345}"
)

function mrcmd_plugins_go_method_config() {
  mrcore_dotenv_echo_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_export_config() {
  mrcore_dotenv_export_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_init() {
  mrcore_dotenv_init_var_array GO_VARS[@] GO_VARS_DEFAULT[@]
}

function mrcmd_plugins_go_method_install() {
    if [ ! -d ./golang ]; then
      mkdir -m 0755 ./golang
    fi

    mrcmd_plugins_call_function "go/docker-build" --no-cache
    mrcmd_plugins_call_function "go/docker-run-install" go mod download
}

function mrcmd_plugins_go_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    build)
      mrcmd_plugins_call_function "go/docker-build" "$@"
      ;;

    ## Create a DB migration files e.g `make migrate-create name=migration-name`
    run)
      mrcmd_plugins_call_function "go/docker-run" go run ./cmd/main/app.go
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_go_method_help() {
  echo -e "  ${CC_YELLOW}DB migrate utility:${CC_END}"
  echo -e "    ${CC_GREEN}build${CC_END}   Build"
  echo -e "    ${CC_GREEN}up${CC_END}      Run migrations UP"
  echo -e "    ${CC_GREEN}init${CC_END}    Run migrations INIT"
  echo -e "    ${CC_GREEN}down${CC_END}    Rollback migrations against non test DB"
  echo -e "    ${CC_GREEN}create${CC_END}  Create a DB migration files e.g 'make migrate-create name=migration-name'"
  echo ""
}
