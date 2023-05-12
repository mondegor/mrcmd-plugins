# https://hub.docker.com/_/golang

function mrcmd_plugins_go_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker-compose")
}

function mrcmd_plugins_go_method_init() {
  readonly GO_NAME="Go alpine"

  readonly GO_VARS=(
    "GO_DOCKER_CONTAINER"
    "GO_DOCKER_SERVICE"
    "GO_DOCKER_CONFIG_DOCKERFILE"
    "GO_DOCKER_COMPOSE_CONFIG_DIR"
    "GO_DOCKER_IMAGE"
    "GO_DOCKER_IMAGE_FROM"
    "GO_DOCKER_ADD_GENERAL_NETWORK"

    "GO_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_TOOLS_INSTALL_STATICCHECK_VERSION"
    "GO_TOOLS_INSTALL_ERRCHECK_VERSION"
    "GO_TOOLS_INSTALL_GOLINT_VERSION"

    "GO_LIB_DIR"
    "GO_WORK_DIR"
    "GO_DOCKER_APP_MAIN_FILE"

    "GO_APPX_PUBLIC_PORT"
    "GO_APPX_HOST"
    "GO_APPX_PORT"
  )

  readonly GO_VARS_DEFAULT=(
    "${APPX_ID}-web-app"
    "web-app"
    "${MRCMD_DIR}/plugins/go/docker"
    "${MRCMD_DIR}/plugins/go/docker-compose"
    "golang:${APPX_ID}-1.20.3"
    "golang:1.20.3-alpine3.17"
    "false"

    "v0.8.0"
    "v0.4.3"
    "v1.6.3"
    "v0.0.0-20210508222113-6edffad5e616"

    "$(realpath "${APPX_DIR}")/golang"
    "$(realpath "${APPX_DIR}")/app"
    "./cmd/app/main.go"

    "127.0.0.1:8090"
    "0.0.0.0"
    "8090"
  )

  mrcore_dotenv_init_var_array GO_VARS[@] GO_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GO_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml")

  if [[ "${GO_DOCKER_ADD_GENERAL_NETWORK}" == true ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GO_DOCKER_COMPOSE_CONFIG_DIR}/general-network.yaml")
  fi

  if [ -n "${APPX_DB_HOST-}" ]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GO_DOCKER_COMPOSE_CONFIG_DIR}/db-params.yaml")
  fi
}

function mrcmd_plugins_go_method_config() {
  mrcore_dotenv_echo_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_export_config() {
  mrcore_dotenv_export_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_install() {
  mrcore_lib_mkdir "${GO_LIB_DIR}"
  mrcore_lib_mkdir "${GO_WORK_DIR}/logs"
  mrcmd_plugins_go_docker_build --no-cache
  mrcmd_plugins_go_download_tools
  mrcmd_plugins_call_function "go/docker-cli" go mod download
}

function mrcmd_plugins_go_method_uninstall() {
  mrcore_lib_rmdir "${GO_LIB_DIR}"
  mrcore_lib_mkdir "${GO_WORK_DIR}/logs"
}

function mrcmd_plugins_go_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array GO_VARS[@]
      mrcmd_plugins_go_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "go/docker-cli" go "$@"
      ;;

    sh)
      mrcmd_plugins_call_function "go/docker-cli" "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${GO_DOCKER_SERVICE}" \
        "${ALPINE_INSTALL_BASH}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${GO_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${GO_DOCKER_CONTAINER}" \
        "${GO_DOCKER_SERVICE}"
      ;;

    download-tools)
      mrcmd_plugins_go_download_tools
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_go_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image ${CC_GREEN}${GO_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli                         Enters to go cli in a container of image ${CC_GREEN}${GO_DOCKER_IMAGE}${CC_END}"
  echo -e "  restart                     Restarts the container ${CC_GREEN}${GO_DOCKER_CONTAINER}${CC_END}"
  echo -e "  into                        Enters to shell in the running container ${CC_GREEN}${GO_DOCKER_CONTAINER}${CC_END}"
  echo -e "  download-tools              Download the checked go tools"
  echo -e "  cli mod tidy                Add missing and remove unused modules in a container of image ${CC_GREEN}${GO_DOCKER_IMAGE}${CC_END}"
  echo -e "  cli mod download            Download modules to local cache in a container of image ${CC_GREEN}${GO_DOCKER_IMAGE}${CC_END}"

  echo -e "    goimports"
  echo -e "    staticcheck"
  echo -e "    errcheck"
  echo -e "    golint"
}

# private
function mrcmd_plugins_go_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${GO_DOCKER_CONFIG_DOCKERFILE}" \
    "${GO_DOCKER_IMAGE}" \
    "${GO_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_go_download_tools() {
  local toolsArray=(
    "golang.org/x/tools/cmd/goimports" "${GO_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "honnef.co/go/tools/cmd/staticcheck" "${GO_TOOLS_INSTALL_STATICCHECK_VERSION}"
    "github.com/kisielk/errcheck" "${GO_TOOLS_INSTALL_ERRCHECK_VERSION}"
    "golang.org/x/lint/golint" "${GO_TOOLS_INSTALL_GOLINT_VERSION}"
  )

  mrcmd_plugins_call_function "go/download-tools" toolsArray[@]
}
