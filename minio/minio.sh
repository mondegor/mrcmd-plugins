# https://hub.docker.com/r/minio/minio/

readonly MINIO_VARS=(
  "MINIO_DOCKER_CONTAINER"
  "MINIO_DOCKER_SERVICE"
  "MINIO_DOCKER_CONFIG_DIR"
  "MINIO_DOCKER_CONFIG_YAML"
  "MINIO_DOCKER_IMAGE"
  "MINIO_DOCKER_NETWORK"
  "MINIO_TZ"
  "MINIO_WEB_EXT_PORT"
  "MINIO_WEB_DOMAIN"
  "MINIO_WEB_PORT"
  "MINIO_WEB_ROOT_USER"
  "MINIO_WEB_ROOT_PASSWORD"
)

# default values of array: MINIO_VARS
readonly MINIO_VARS_DEFAULT=(
  "${APPX_ID:-appx}-s3-minio"
  "s3-minio"
  "${MRCMD_DIR}/plugins/minio/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/minio/docker-compose.yaml"
  "minio/minio:RELEASE.2023-04-13T03-08-07Z.fips"
  "${APPX_NETWORK:-appx-network}"
  "${TZ:-Europe/Moscow}"
  "127.0.0.1:8095"
  "s3-panel.local"
  "9001"
  "root"
  "12345678"
)

function mrcmd_plugins_minio_method_config() {
  mrcore_dotenv_echo_var_array MINIO_VARS[@]
}

function mrcmd_plugins_minio_method_export_config() {
  mrcore_dotenv_export_var_array MINIO_VARS[@]
}

function mrcmd_plugins_minio_method_init() {
  mrcore_dotenv_init_var_array MINIO_VARS[@] MINIO_VARS_DEFAULT[@]

  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${MINIO_DOCKER_CONFIG_YAML}"
  fi
}

function mrcmd_plugins_minio_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    bash)
      mrcmd_plugins_call_function "docker-compose/command" exec "${MINIO_DOCKER_SERVICE}" bash
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_minio_help() {
  echo -e "  ${CC_YELLOW}Minio:${CC_END}"
  echo -e "    ${CC_GREEN}shell${CC_END}   Shell"
  echo ""
}
