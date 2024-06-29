# https://hub.docker.com/r/minio/minio
# https://min.io/docs/minio/linux/index.html

function mrcmd_plugins_minio_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "nginx")
}

function mrcmd_plugins_minio_method_init() {
  readonly MINIO_CAPTION="Minio"
  readonly MINIO_DOCKER_SERVICE="s3-minio"
  readonly MINIO_NGINX_DOCKER_SERVICE="s3-minio-nginx"

  readonly MINIO_VARS=(
    "READONLY_MINIO_DOCKER_HOST"
    "MINIO_DOCKER_CONTAINER"
    "MINIO_DOCKER_CONTEXT_DIR"
    "MINIO_DOCKER_DOCKERFILE"
    "MINIO_DOCKER_COMPOSE_CONFIG_DIR"
    "MINIO_DOCKER_IMAGE"
    "MINIO_DOCKER_IMAGE_FROM"

    "READONLY_MINIO_NGINX_DOCKER_HOST"
    "MINIO_NGINX_DOCKER_CONTAINER"
    "MINIO_NGINX_DOCKER_IMAGE"
    "MINIO_NGINX_DOCKER_IMAGE_FROM"
    "MINIO_NGINX_PUBLIC_PORT"

    "MINIO_API_PUBLIC_PORT"
    "MINIO_API_INTERNAL_PORT"
    "MINIO_API_USER"
    "MINIO_API_PASSWORD"

    "MINIO_WEB_INTERNAL_PORT"
    "MINIO_WEB_DOMAIN"
  )

  readonly MINIO_VARS_DEFAULT=(
    "${MINIO_DOCKER_SERVICE}"
    "${APPX_ID}-${MINIO_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}minio:2023-11-15"
    "minio/minio:RELEASE.2023-11-15T20-43-25Z.fips"

    "${MINIO_NGINX_DOCKER_SERVICE}"
    "${APPX_ID}-${MINIO_NGINX_DOCKER_SERVICE}"
    "${DOCKER_PACKAGE_NAME}nginx-minio:1.25.3"
    "nginx:1.25.3-alpine3.18"
    "127.0.0.1:9984"

    "127.0.0.1:9000"
    "9000"
    "admin"
    "12345678"

    "9001"
    "minio.local"
  )

  mrcore_dotenv_init_var_array MINIO_VARS[@] MINIO_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MINIO_DOCKER_COMPOSE_CONFIG_DIR}/s3-minio.yaml")
}

function mrcmd_plugins_minio_method_config() {
  mrcore_dotenv_echo_var_array MINIO_VARS[@]
}

function mrcmd_plugins_minio_method_export_config() {
  mrcore_dotenv_export_var_array MINIO_VARS[@]
}

function mrcmd_plugins_minio_method_install() {
  mrcmd_plugins_minio_docker_build --no-cache
  mrcmd_plugins_minio_nginx_docker_build --no-cache
}

function mrcmd_plugins_minio_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_minio_method_config
      mrcmd_plugins_minio_docker_build "$@"
      mrcmd_plugins_minio_nginx_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${MINIO_DOCKER_SERVICE}" \
        minio
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${MINIO_DOCKER_SERVICE}" \
        "bash" # "${DOCKER_DEFAULT_SHELL}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${MINIO_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${MINIO_DOCKER_CONTAINER}" \
        "${MINIO_DOCKER_SERVICE}"

      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${MINIO_NGINX_DOCKER_CONTAINER}" \
        "${MINIO_NGINX_DOCKER_SERVICE}"
      ;;

    ng-into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${MINIO_NGINX_DOCKER_SERVICE}" \
        "${DOCKER_DEFAULT_SHELL}"
      ;;

    ng-logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${MINIO_NGINX_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_minio_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${MINIO_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${MINIO_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  cli         Enters to minio cli in a container of the image"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restart minio and nginx containers"
  echo -e "  ng-into     Enters to shell in the running nginx container"
  echo -e "  ng-logs     View output from the running nginx container"
}

# private
function mrcmd_plugins_minio_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${MINIO_DOCKER_CONTEXT_DIR}" \
    "${MINIO_DOCKER_DOCKERFILE}" \
    "${MINIO_DOCKER_IMAGE}" \
    "${MINIO_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
# web-app - nginx SERVICE_TYPE
function mrcmd_plugins_minio_nginx_docker_build() {
  mrcmd_plugins_call_function "nginx/build-image" \
    "${MINIO_NGINX_DOCKER_IMAGE}" \
    "${MINIO_NGINX_DOCKER_IMAGE_FROM}" \
    "web-minio" \
    "${MINIO_DOCKER_SERVICE}" \
    "${MINIO_WEB_INTERNAL_PORT}" \
    "$@"
}
