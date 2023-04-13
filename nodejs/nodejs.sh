# https://hub.docker.com/_/node

readonly NODEJS_VARS=(
  "NODEJS_DOCKER_CONTAINER"
  "NODEJS_DOCKER_CONFIG_DIR"
  "NODEJS_DOCKER_CONFIG_YAML"
  "NODEJS_DOCKER_IMAGE"
  "NODEJS_DOCKER_IMAGE_FROM"
  "NODEJS_DOCKER_NETWORK"
  "NODEJS_INSTALL_BASH"
  "NODEJS_TZ"
  "NODEJS_HOST_USER_ID"
  "NODEJS_HOST_GROUP_ID"
  "NODEJS_EXT_PORT"
  "NODEJS_APP_VOLUME"
)

# default values of array: NODEJS_VARS
readonly NODEJS_VARS_DEFAULT=(
  "${APPX_ID:-appx}-nodejs"
  "${MRCMD_DIR}/plugins/nodejs/docker"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/nodejs/docker-compose.yaml"
  "${APPX_ID:-appx}-node:19.8.1-alpine3.17"
  "node:19.8.1-alpine3.17"
  "${APPX_NETWORK:-appx-network}"
  "${ALPINE_INSTALL_BASH:-false}"
  "${TZ:-Europe/Moscow}"
  "${HOST_USER_ID:-1000}"
  "${HOST_GROUP_ID:-1000}"
  "127.0.0.1:3000"
  "$(realpath "${APPX_DIR}")/app"
)

function mrcmd_plugins_nodejs_method_config() {
  mrcore_dotenv_echo_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_export_config() {
  mrcore_dotenv_export_var_array NODEJS_VARS[@]
}

function mrcmd_plugins_nodejs_method_init() {
  mrcore_dotenv_init_var_array NODEJS_VARS[@] NODEJS_VARS_DEFAULT[@]

  if [[ -n "${DOCKER_COMPOSE_CONFIG_FILES}" ]]; then
    DOCKER_COMPOSE_CONFIG_FILES="${DOCKER_COMPOSE_CONFIG_FILES}${CMD_SEPARATOR}${NODEJS_DOCKER_CONFIG_YAML}"
  fi
}

function mrcmd_plugins_nodejs_method_install() {
  mrcmd_plugins_call_function "nodejs/docker-build" --no-cache
  mrcmd_plugins_call_function "nodejs/docker-run" npm install
}

function mrcmd_plugins_nodejs_method_uninstall() {
  local removingDir="${NODEJS_APP_VOLUME}/node_modules"

  if [ -d "${removingDir}" ]; then
    rm -R "${removingDir}"
    echo -e "${CC_RED}Dir ${removingDir} removed${CC_END}"
  fi
}

function mrcmd_plugins_nodejs_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    docker-build)
      mrcmd_plugins_call_function "nodejs/docker-build" "$@"
      ;;

    docker-run)
      mrcmd_plugins_call_function "nodejs/docker-run" "$@"
      ;;

    # :TODO:
    shell)
      bash ./mrcmd/utils/docker-compose.sh exec -u node main-nodejs bash
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_nodejs_method_help() {
  echo -e "${CC_YELLOW}Nodejs${CC_END}:"
  echo -e "  ${CC_GREEN}docker-build${CC_END}        List of available plugins"
  echo -e "  ${CC_GREEN}docker-run${CC_END}        List of available plugins"
  echo ""
}
