# https://quay.io/repository/keycloak/keycloak
# https://www.keycloak.org/server/containers
# https://www.keycloak.org/downloads

function mrcmd_plugins_keycloak_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_keycloak_method_init() {
  readonly KEYCLOAK_CAPTION="Keycloak Quay.io"
  readonly KEYCLOAK_DOCKER_SERVICE="auth-keycloak"

  readonly KEYCLOAK_VARS=(
    "READONLY_KEYCLOAK_DOCKER_HOST"
    "KEYCLOAK_DOCKER_CONTAINER"
    "KEYCLOAK_DOCKER_CONTEXT_DIR"
    "KEYCLOAK_DOCKER_DOCKERFILE"
    "KEYCLOAK_DOCKER_COMPOSE_CONFIG_DIR"
    "KEYCLOAK_DOCKER_IMAGE"
    "KEYCLOAK_DOCKER_IMAGE_FROM"

    "KEYCLOAK_REALM_NAME"

    "KEYCLOAK_DB_TYPE"
    "KEYCLOAK_DB_USER"
    "KEYCLOAK_DB_PASSWORD"
    "KEYCLOAK_DB_URL"

    "KEYCLOAK_WEB_PUBLIC_PORT"
    "KEYCLOAK_WEB_ADMIN_USER"
    "KEYCLOAK_WEB_ADMIN_PASSWORD"
  )

  readonly KEYCLOAK_VARS_DEFAULT=(
    "${KEYCLOAK_DOCKER_SERVICE}"
    "${APPX_ID}-${KEYCLOAK_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}keycloak-postgres:22.0.1"
    "quay.io/keycloak/keycloak:22.0.1"

    "master"

    "postgres"
    "POSTGRES_DB_USER" # var with value
    "POSTGRES_DB_PASSWORD" # var with value
    "POSTGRES_DB_URL_JDBC" # var with value

    "127.0.0.1:9986"
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

    conf)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${KEYCLOAK_DOCKER_SERVICE}" \
        ./bin/kc.sh \
        show-config
      ;;

    certs)
      curl -s \
        "http://${KEYCLOAK_WEB_PUBLIC_PORT}/realms/${KEYCLOAK_REALM_NAME}/protocol/openid-connect/certs" \
        -H "Accept: application/json" | \
        json_pp -json_opt pretty,canonical
      ;;

    # https://www.keycloak.org/server/importExport
    # Import problem: https://www.helikube.de/keycloak-18-export-and-import-feature/
    realm-export)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${KEYCLOAK_DOCKER_SERVICE}" \
        ./bin/kc.sh \
        export \
        --file \
        "./data/import/${KEYCLOAK_REALM_NAME}.json" \
        --realm "${KEYCLOAK_REALM_NAME}"
      ;;

    realm-export-all)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${KEYCLOAK_DOCKER_SERVICE}" \
        ./bin/kc.sh \
        export \
        --dir \
        "./data/import"
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
  echo -e "  into                Enters to shell in the running container"
  echo -e "  logs                View output from the running container"
  echo -e "  restart             Restarts keycloak container"
  echo -e "  conf                ./bin/kc.sh show-config"
  echo -e "  realm-export        Exports realm '${CC_CYAN}${KEYCLOAK_REALM_NAME}${CC_END}' to ${CC_BLUE}./data/import${CC_END} of the container"
  echo -e "  realm-export-all    Exports all realms to ${CC_BLUE}./data/import${CC_END} of the container"
}

# private
function mrcmd_plugins_keycloak_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${KEYCLOAK_DOCKER_CONTEXT_DIR}" \
    "${KEYCLOAK_DOCKER_DOCKERFILE}" \
    "${KEYCLOAK_DOCKER_IMAGE}" \
    "${KEYCLOAK_DOCKER_IMAGE_FROM}" \
    --build-arg "DB_TYPE=${KEYCLOAK_DB_TYPE}" \
    --build-arg "DB_USER=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_USER}")" \
    --build-arg "DB_PASSWORD=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_PASSWORD}")" \
    --build-arg "DB_URL=$(mrcore_lib_get_var_value "${KEYCLOAK_DB_URL}")" \
    "$@"
}
