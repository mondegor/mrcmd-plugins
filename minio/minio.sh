# https://hub.docker.com/r/minio/minio/

function mrcmd_plugins_minio_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "nginx")
}

function mrcmd_plugins_minio_method_init() {
  readonly MINIO_NAME="Minio - High Performance Object Storage"

  readonly MINIO_VARS=(
    "MINIO_DOCKER_CONTAINER"
    "MINIO_DOCKER_SERVICE"
    "MINIO_DOCKER_CONFIG_DOCKERFILE"
    "MINIO_DOCKER_COMPOSE_CONFIG_DIR"
    "MINIO_DOCKER_IMAGE"
    "MINIO_DOCKER_IMAGE_FROM"

    "MINIO_NGINX_DOCKER_CONTAINER"
    "MINIO_NGINX_DOCKER_IMAGE"
    "MINIO_WEB_PUBLIC_PORT"
    "MINIO_WEB_DOMAIN"
    "MINIO_WEB_PORT"
    "MINIO_WEB_ROOT_USER"
    "MINIO_WEB_ROOT_PASSWORD"
  )

  readonly MINIO_VARS_DEFAULT=(
    "${APPX_ID}-s3-minio"
    "s3-minio"
    "${MRCMD_DIR}/plugins/minio/docker"
    "${MRCMD_DIR}/plugins/minio/docker-compose"
    "minio:${APPX_ID}-2023-04-13T03-08-07Z"
    "minio/minio:RELEASE.2023-04-13T03-08-07Z.fips"

    "${APPX_ID}-s3-minio-nginx"
    "minio-nginx:${APPX_ID}"
    "127.0.0.1:8095"
    "s3-panel.local"
    "9001"
    "root"
    "12345678"
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

function mrcmd_plugins_minio_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array MINIO_VARS[@]
      mrcmd_plugins_minio_docker_build "$@"
      mrcmd_plugins_minio_nginx_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "docker-compose/command" exec \
        "${MINIO_DOCKER_SERVICE}" \
        minio
      ;;

    shell)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${MINIO_DOCKER_SERVICE}" \
        true # "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_minio_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image ${CC_GREEN}${MINIO_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                         Enters to minio cli in the running container ${CC_GREEN}${MINIO_DOCKER_CONTAINER}${CC_END}"
  echo -e "  shell                       Enters to shell in the running container ${CC_GREEN}${MINIO_DOCKER_CONTAINER}${CC_END}"
}

# private
function mrcmd_plugins_minio_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${MINIO_DOCKER_CONFIG_DOCKERFILE}" \
    "${MINIO_DOCKER_IMAGE}" \
    "${MINIO_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_minio_nginx_docker_build() {
  mrcmd_plugins_call_function "nginx/docker-build-image" \
    "${NGINX_DOCKER_CONFIG_DOCKERFILE}" \
    "${MINIO_NGINX_DOCKER_IMAGE}" \
    "${NGINX_DOCKER_IMAGE_FROM}" \
    "web-service" \
    "${MINIO_WEB_DOMAIN}" \
    "${MINIO_DOCKER_SERVICE}" \
    "${MINIO_WEB_PORT}" \
    "$@"
}
