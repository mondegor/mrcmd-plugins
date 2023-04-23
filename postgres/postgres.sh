# https://hub.docker.com/_/postgres

function mrcmd_plugins_postgres_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_postgres_method_init() {
  readonly POSTGRES_NAME="Postgres"

  readonly POSTGRES_VARS=(
    "POSTGRES_DOCKER_CONTAINER"
    "POSTGRES_DOCKER_SERVICE"
    "POSTGRES_DOCKER_CONFIG_DOCKERFILE"
    "POSTGRES_DOCKER_COMPOSE_CONFIG_DIR"
    "POSTGRES_DOCKER_IMAGE"
    "POSTGRES_DOCKER_IMAGE_FROM"
    "POSTGRES_DOCKER_ADD_GENERAL_NETWORK"

    "POSTGRES_DB_PUBLIC_PORT"
    "POSTGRES_DB_ROOT_USER"
    "POSTGRES_DB_ROOT_PASSWORD"
  )

  readonly POSTGRES_VARS_DEFAULT=(
    "${APPX_ID}-db-postgres"
    "db-postgres"
    "${MRCMD_DIR}/plugins/postgres/docker"
    "${MRCMD_DIR}/plugins/postgres/docker-compose"
    "postgres:${APPX_ID}-14.7"
    "postgres:14.7-alpine3.17"
    "false"

    "127.0.0.1:5432"
    "${APPX_DB_USER:-postgres}"
    "${APPX_DB_PASSWORD:-123456}"
  )

  mrcore_dotenv_init_var_array POSTGRES_VARS[@] POSTGRES_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRES_DOCKER_COMPOSE_CONFIG_DIR}/db-postgres.yaml")
  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRES_DOCKER_COMPOSE_CONFIG_DIR}/db-postgres-init.yaml")

  if [[ "${POSTGRES_DOCKER_ADD_GENERAL_NETWORK}" == true ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRES_DOCKER_COMPOSE_CONFIG_DIR}/general-network.yaml")
  fi
}

function mrcmd_plugins_postgres_method_config() {
  mrcore_dotenv_echo_var_array POSTGRES_VARS[@]
}

function mrcmd_plugins_postgres_method_export_config() {
  mrcore_dotenv_export_var_array POSTGRES_VARS[@]
}

function mrcmd_plugins_postgres_method_install() {
  mrcmd_plugins_postgres_docker_build --no-cache
}

function mrcmd_plugins_postgres_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array POSTGRES_VARS[@]
      mrcmd_plugins_postgres_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${POSTGRES_DOCKER_SERVICE}" \
        psql \
        -U "${POSTGRES_DB_ROOT_USER}" \
        -d "${APPX_DB_NAME}"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${POSTGRES_DOCKER_SERVICE}" \
        "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_postgres_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image ${CC_GREEN}${POSTGRES_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                 Enters to database cli in the running container ${CC_GREEN}${POSTGRES_DOCKER_CONTAINER}${CC_END}"
  echo -e "  into                Enters to shell in the running container ${CC_GREEN}${POSTGRES_DOCKER_CONTAINER}${CC_END}"
}

# private
function mrcmd_plugins_postgres_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${POSTGRES_DOCKER_CONFIG_DOCKERFILE}" \
    "${POSTGRES_DOCKER_IMAGE}" \
    "${POSTGRES_DOCKER_IMAGE_FROM}" \
    "$@"
}
