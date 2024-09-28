# https://hub.docker.com/r/migrate/migrate

function mrcmd_plugins_go_migrate_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_go_migrate_method_init() {
  readonly GO_MIGRATE_CAPTION="DB migrate utility"

  readonly GO_MIGRATE_VARS=(
    "GO_MIGRATE_DOCKER_CONTEXT_DIR"
    "GO_MIGRATE_DOCKER_DOCKERFILE"
    "GO_MIGRATE_DOCKER_IMAGE"
    "GO_MIGRATE_DOCKER_IMAGE_FROM"
    "GO_MIGRATE_DOCKER_NETWORK"

    "GO_MIGRATE_DB_DSN"
    "GO_MIGRATE_DB_TABLE"

    "GO_MIGRATE_DB_SRC_DIR"
  )

  readonly GO_MIGRATE_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}go-migrate:4.17.1"
    "migrate/migrate:v4.17.1"
    "${DOCKER_COMPOSE_NETWORK}"

    "POSTGRES_DB_DSN" # var with value or value
    "schema_migrations"

    "${APPX_WORK_DIR}/migrations"
  )

  mrcore_dotenv_init_var_array GO_MIGRATE_VARS[@] GO_MIGRATE_VARS_DEFAULT[@]

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${GO_MIGRATE_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_go_migrate_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
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

    init)
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql -seq init
      ;;

    up | down)
      local migrationLimit="${1:-}"
      mrcmd_plugins_call_function "go-migrate/docker-run" "${currentCommand}" ${migrationLimit}
      ;;

    force)
      local migrationVersion="${1-}"
      mrcore_validate_value_required "Argument 'version'" ${migrationVersion}
      mrcmd_plugins_call_function "go-migrate/docker-run" force ${migrationVersion}
      ;;

    create)
      local migrationName="${1-}"
      mrcore_validate_value_required "Name" "${migrationName}"
      mrcore_validate_value "Name" "${REGEXP_PATTERN_FILE_NAME}" "${migrationName}"
      mrcmd_plugins_call_function "go-migrate/docker-run" create -ext sql "${migrationName}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_go_migrate_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  init                Run migrations INIT"
  echo -e "  up [limit=max]      Run migrations UP"
  echo -e "  down [limit=min]    Rollback migrations against non test DB"
  echo -e "  force [version]     Set migration version"
  echo -e "  create [name]       Create a DB migration files e.g 'make migrate-create name=migration-name'"
}

# private
function mrcmd_plugins_go_migrate_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${GO_MIGRATE_DOCKER_CONTEXT_DIR}" \
    "${GO_MIGRATE_DOCKER_DOCKERFILE}" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    "${GO_MIGRATE_DOCKER_IMAGE_FROM}" \
    "$@"
}
