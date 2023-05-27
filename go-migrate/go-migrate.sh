# https://hub.docker.com/r/migrate/migrate

function mrcmd_plugins_go_migrate_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_go_migrate_method_init() {
  readonly GO_MIGRATE_CAPTION="DB migrate utility"

  readonly GO_MIGRATE_VARS=(
    "GO_MIGRATE_DOCKER_CONFIG_DOCKERFILE"
    "GO_MIGRATE_DOCKER_IMAGE"
    "GO_MIGRATE_DOCKER_IMAGE_FROM"
    "GO_MIGRATE_DOCKER_NETWORK"

    "GO_MIGRATE_DB_URL"

    "GO_MIGRATE_DB_SRC_DIR"
  )

  readonly GO_MIGRATE_VARS_DEFAULT=(
    "${MRCMD_PLUGINS_DIR}/go-migrate/docker"
    "${DOCKER_PACKAGE_NAME}go-migrate:4.15.2"
    "migrate/migrate:v4.15.2"
    "${APPX_ID}-${DOCKER_COMPOSE_LOCAL_NETWORK}"

    "POSTGRES_DB_URL" # var with value

    "${APPX_DIR}/migrations"
  )

  mrcore_dotenv_init_var_array GO_MIGRATE_VARS[@] GO_MIGRATE_VARS_DEFAULT[@]
}

function mrcmd_plugins_go_migrate_method_config() {
  mrcore_dotenv_echo_var_array GO_MIGRATE_VARS[@]
}

function mrcmd_plugins_go_migrate_method_export_config() {
  mrcore_dotenv_export_var_array GO_MIGRATE_VARS[@]
}

function mrcmd_plugins_go_migrate_method_install() {
  mrcmd_plugins_go_migrate_docker_build --no-cache
}

function mrcmd_plugins_go_migrate_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_go_migrate_method_config
      mrcmd_plugins_go_migrate_docker_build "$@"
      ;;

    up)
      mrcmd_plugins_call_function "go-migrate/docker-run" up
      ;;

    down)
      mrcmd_plugins_call_function "go-migrate/docker-run" down 1
      ;;

    init)
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql -seq init
      ;;

    create)
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_go_migrate_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image ${CC_GREEN}${GO_MIGRATE_DOCKER_IMAGE}${CC_END}"
  echo -e "  up                  Run migrations UP"
  echo -e "  init                Run migrations INIT"
  echo -e "  down                Rollback migrations against non test DB"
  echo -e "  create              Create a DB migration files e.g 'make migrate-create name=migration-name'"
}

# private
function mrcmd_plugins_go_migrate_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${GO_MIGRATE_DOCKER_CONFIG_DOCKERFILE}" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    "${GO_MIGRATE_DOCKER_IMAGE_FROM}" \
    "$@"
}
