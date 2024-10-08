# https://hub.docker.com/r/minio/minio
# https://min.io/docs/minio/linux/index.html

function mrcmd_plugins_minio_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "nginx")
}

function mrcmd_plugins_minio_method_init() {
  export MINIO_DOCKER_SERVICE="s3-minio"
  export MINIO_NGINX_DOCKER_SERVICE="s3-minio-nginx"

  readonly MINIO_CAPTION="Minio"

  readonly MINIO_VARS=(
    "MINIO_DOCKER_CONTAINER"
    "MINIO_DOCKER_CONTEXT_DIR"
    "MINIO_DOCKER_DOCKERFILE"
    "MINIO_DOCKER_COMPOSE_CONFIG_DIR"
    "MINIO_DOCKER_IMAGE"
    "MINIO_DOCKER_IMAGE_FROM"

    "MINIO_NGINX_DOCKER_CONTAINER"
    "MINIO_NGINX_DOCKER_IMAGE"
    "MINIO_NGINX_DOCKER_IMAGE_FROM"
    ##### "MINIO_NGINX_PUBLIC_PORT"

    "MINIO_API_PUBLIC_PORT"
    "MINIO_API_INTERNAL_PORT"
    "MINIO_API_USER"
    "MINIO_API_PASSWORD"

    "MINIO_WEB_DOMAIN"
    "MINIO_WEB_INTERNAL_PORT"
  )

  readonly MINIO_VARS_DEFAULT=(
    "${APPX_ID}-${MINIO_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}minio:2024-07-13"
    "minio/minio:RELEASE.2024-07-13T01-46-15Z.fips"

    "${APPX_ID}-${MINIO_NGINX_DOCKER_SERVICE}"
    "${DOCKER_PACKAGE_NAME}nginx-minio:1.27.0"
    "nginx:1.27.0-alpine3.19"
    ##### "127.0.0.1:9984"

    "127.0.0.1:9000"
    "9000"
    "admin"
    "12345678"

    "minio.local"
    "9001"
  )

  mrcore_dotenv_init_var_array MINIO_VARS[@] MINIO_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${MINIO_DOCKER_COMPOSE_CONFIG_DIR}/s3-minio.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${MINIO_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_minio_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_minio_method_config() {
  mrcore_dotenv_echo_var_array MINIO_VARS[@]
  mrcore_echo_var "MINIO_DOCKER_SERVICE (host, readonly)" "${MINIO_DOCKER_SERVICE}"
  mrcore_echo_var "MINIO_NGINX_DOCKER_SERVICE (host, readonly)" "${MINIO_NGINX_DOCKER_SERVICE}"
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
        bash # shell name
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
        bash # shell name
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
