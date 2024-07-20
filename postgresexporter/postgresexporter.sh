# https://github.com/prometheus-community/postgres_exporter
# https://hub.docker.com/r/prometheuscommunity/postgres-exporter

function mrcmd_plugins_postgresexporter_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_postgresexporter_method_init() {
  export POSTGRESEXPORTER_DOCKER_SERVICE="mn-postgresexporter"

  readonly POSTGRESEXPORTER_CAPTION="Postgres Exporter"

  readonly POSTGRESEXPORTER_VARS=(
    "POSTGRESEXPORTER_DOCKER_CONTAINER"
    "POSTGRESEXPORTER_DOCKER_CONTEXT_DIR"
    "POSTGRESEXPORTER_DOCKER_DOCKERFILE"
    "POSTGRESEXPORTER_DOCKER_COMPOSE_CONFIG_DIR"
    "POSTGRESEXPORTER_DOCKER_IMAGE"
    "POSTGRESEXPORTER_DOCKER_IMAGE_FROM"

    "POSTGRESEXPORTER_DB_URI"
    "POSTGRESEXPORTER_DB_USER"
    "POSTGRESEXPORTER_DB_PASSWORD"
  )

  readonly POSTGRESEXPORTER_VARS_DEFAULT=(
    "${APPX_ID}-${POSTGRESEXPORTER_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}postgres-exporter:0.15.0"
    "prometheuscommunity/postgres-exporter:v0.15.0"

    "db-postgres:5432/postgres?sslmode=disable"
    "user_pg"
    "123456"
  )

  mrcore_dotenv_init_var_array POSTGRESEXPORTER_VARS[@] POSTGRESEXPORTER_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${POSTGRESEXPORTER_DOCKER_COMPOSE_CONFIG_DIR}/mn-postgresexporter.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${POSTGRESEXPORTER_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_postgresexporter_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_postgresexporter_method_config() {
  mrcore_dotenv_echo_var_array POSTGRESEXPORTER_VARS[@]
  mrcore_echo_var "POSTGRESEXPORTER_DOCKER_SERVICE (host, readonly)" "${POSTGRESEXPORTER_DOCKER_SERVICE}"
}

function mrcmd_plugins_postgresexporter_method_export_config() {
  mrcore_dotenv_export_var_array POSTGRESEXPORTER_VARS[@]
}

function mrcmd_plugins_postgresexporter_method_install() {
  mrcmd_plugins_postgresexporter_docker_build --no-cache
}

function mrcmd_plugins_postgresexporter_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_postgresexporter_method_config
      mrcmd_plugins_postgresexporter_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${POSTGRESEXPORTER_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${POSTGRESEXPORTER_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${POSTGRESEXPORTER_DOCKER_CONTAINER}" \
        "${POSTGRESEXPORTER_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_postgresexporter_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${POSTGRESEXPORTER_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${POSTGRESEXPORTER_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
}

# private
function mrcmd_plugins_postgresexporter_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${POSTGRESEXPORTER_DOCKER_CONTEXT_DIR}" \
    "${POSTGRESEXPORTER_DOCKER_DOCKERFILE}" \
    "${POSTGRESEXPORTER_DOCKER_IMAGE}" \
    "${POSTGRESEXPORTER_DOCKER_IMAGE_FROM}" \
    "$@"
}
