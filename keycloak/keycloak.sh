# https://quay.io/repository/keycloak/keycloak
# https://www.keycloak.org/server/containers

function mrcmd_plugins_keycloak_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_keycloak_method_init() {
  readonly KEYCLOAK_CAPTION="Keycloak Quay.io"
  readonly KEYCLOAK_DOCKER_SERVICE="auth-keycloak"

  readonly KEYCLOAK_VARS=(
    "KEYCLOAK_DOCKER_CONTAINER"
    "KEYCLOAK_DOCKER_CONFIG_DOCKERFILE"
    "KEYCLOAK_DOCKER_COMPOSE_CONFIG_DIR"
    "KEYCLOAK_DOCKER_IMAGE"
    "KEYCLOAK_DOCKER_IMAGE_FROM"

    "KEYCLOAK_DB_TYPE"
    "KEYCLOAK_DB_USER"
    "KEYCLOAK_DB_PASSWORD"
    "KEYCLOAK_DB_URL"

    "KEYCLOAK_WEB_PUBLIC_PORT"
    "KEYCLOAK_WEB_ADMIN_USER"
    "KEYCLOAK_WEB_ADMIN_PASSWORD"
  )

  readonly KEYCLOAK_VARS_DEFAULT=(
    "${APPX_ID}-auth-keycloak"
    "${MRCMD_PLUGINS_DIR}/keycloak/docker"
    "${MRCMD_PLUGINS_DIR}/keycloak/docker-compose"
    "${DOCKER_PACKAGE_NAME}keycloak-postgres:21.0"
    "quay.io/keycloak/keycloak:21.0"

    "postgres"
    "POSTGRES_DB_USER" # var with value
    "POSTGRES_DB_PASSWORD" # var with value
    "POSTGRES_DB_URL_JDBC" # var with value

    "3000"
    "admin"
    "12345678"
  )

  mrcore_dotenv_init_var_array KEYCLOAK_VARS[@] KEYCLOAK_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${KEYCLOAK_DOCKER_COMPOSE_CONFIG_DIR}/auth-keycloak.yaml")
}

function mrcmd_plugins_keycloak_method_config() {
  mrcore_dotenv_echo_var_array KEYCLOAK_VARS[@]
}

function mrcmd_plugins_keycloak_method_export_config() {
  mrcore_dotenv_export_var_array KEYCLOAK_VARS[@]
}

function mrcmd_plugins_keycloak_method_install() {
  mrcmd_plugins_keycloak_docker_build --no-cache
}

function mrcmd_plugins_keycloak_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_keycloak_method_config
      mrcmd_plugins_keycloak_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${KEYCLOAK_DOCKER_SERVICE}" \
        "bash" # "${DOCKER_DEFAULT_SHELL}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${KEYCLOAK_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${KEYCLOAK_DOCKER_CONTAINER}" \
        "${KEYCLOAK_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_keycloak_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${KEYCLOAK_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${KEYCLOAK_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts keycloak containers"
}

# private
function mrcmd_plugins_keycloak_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${KEYCLOAK_DOCKER_CONFIG_DOCKERFILE}" \
    "${KEYCLOAK_DOCKER_IMAGE}" \
    "${KEYCLOAK_DOCKER_IMAGE_FROM}" \
    --build-arg "DB_TYPE=${KEYCLOAK_DB_TYPE}" \
    --build-arg "DB_USER=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_USER}")" \
    --build-arg "DB_PASSWORD=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_PASSWORD}")" \
    --build-arg "DB_URL=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_URL}")" \
    "$@"
}
