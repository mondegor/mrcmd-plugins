# https://hub.docker.com/_/golang

function mrcmd_plugins_go_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_go_method_init() {
  readonly GO_CAPTION="Go alpine"
  readonly GO_DOCKER_SERVICE="web-app"

  readonly GO_VARS=(
    "GO_DOCKER_CONTAINER"
    "GO_DOCKER_CONFIG_DOCKERFILE"
    "GO_DOCKER_COMPOSE_CONFIG_DIR"
    "GO_DOCKER_COMPOSE_CONFIG_FILE"
    "GO_DOCKER_IMAGE"
    "GO_DOCKER_IMAGE_FROM"

    "GO_LIB_DIR"
    "GO_APP_ENV_FILE"
    "GO_APP_MAIN_FILE"

    "GO_WEBAPP_PUBLIC_PORT"
    "GO_WEBAPP_BIND"
    "GO_WEBAPP_PORT"

    "GO_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_TOOLS_INSTALL_STATICCHECK_VERSION"
    "GO_TOOLS_INSTALL_ERRCHECK_VERSION"
    "GO_TOOLS_INSTALL_GOLINT_VERSION"
  )

  readonly GO_VARS_DEFAULT=(
    "${APPX_ID}-web-app"
    "${MRCMD_PLUGINS_DIR}/go/docker"
    "${MRCMD_PLUGINS_DIR}/go/docker-compose"
    "${APPX_DIR}/app.yaml"
    "${DOCKER_PACKAGE_NAME}go:1.20.3"
    "golang:1.20.3-alpine3.17"

    "${APPX_DIR}/golang"
    "${APPX_DIR}/.env.app"
    "./cmd/app/main.go"

    "127.0.0.1:8090"
    "0.0.0.0"
    "8090"

    "v0.8.0"
    "v0.4.3"
    "v1.6.3"
    "v0.0.0-20210508222113-6edffad5e616"
  )

  mrcore_dotenv_init_var_array GO_VARS[@] GO_VARS_DEFAULT[@]

  mrcmd_plugins_call_function "docker-compose/register" \
    "${GO_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml" \
    "${GO_APP_ENV_FILE}" \
    "${GO_DOCKER_COMPOSE_CONFIG_DIR}/env-file.yaml" \
    "${GO_DOCKER_COMPOSE_CONFIG_FILE}"
}

function mrcmd_plugins_go_method_config() {
  mrcore_dotenv_echo_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_export_config() {
  mrcore_dotenv_export_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_install() {
  mrcore_lib_mkdir "${GO_LIB_DIR}"
  mrcore_lib_mkdir "${APPX_WORK_DIR}/logs"
  mrcmd_plugins_go_docker_build --no-cache
  mrcmd_plugins_go_install_tools
  mrcmd_plugins_call_function "go/docker-run" go mod download
}

function mrcmd_plugins_go_method_uninstall() {
  mrcore_lib_rmdir "${GO_LIB_DIR}"
  mrcore_lib_rmdir "${APPX_WORK_DIR}/logs"
}

function mrcmd_plugins_go_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_go_method_config
      mrcmd_plugins_go_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "go/docker-run" go "$@"
      ;;

    shell)
      mrcmd_plugins_call_function "go/docker-run" "${DOCKER_DEFAULT_SHELL}" "$@"
      ;;

    env)
      mrcmd_plugins_call_function "go/docker-run" go env
      ;;

    get)
      mrcmd_plugins_call_function "go/docker-run" go get "$@"
      ;;

    download)
      mrcmd_plugins_call_function "go/docker-run" go mod download "$@"
      ;;

    tidy)
      mrcmd_plugins_call_function "go/docker-run" go mod tidy
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${GO_DOCKER_SERVICE}" \
        "${DOCKER_DEFAULT_SHELL}"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${GO_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${GO_DOCKER_CONTAINER}" \
        "${GO_DOCKER_SERVICE}"
      ;;

    install-tools)
      mrcmd_plugins_go_install_tools
      ;;

    goimports | staticcheck | errcheck | golint)
      mrcmd_plugins_call_function "go/docker-run" "${currentCommand}" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_go_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${GO_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'go [arguments]' in a container of the image"
  echo -e "  shell               Exec shell in a container of the image"
  echo -e "  env                 Prints Go environment information"
  echo -e "  get                 Downloads the packages named by the import paths,"
  echo -e "                      along with their dependencies"
  echo -e "  download            Downloads the named modules in a container of the image"
  echo -e "  tidy                Add missing and remove unused modules in a container of the image"
  echo -e "  install-tools      Downloads tools defined in GO_DEV_TOOLS_INSTALL_* vars"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${GO_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
  echo -e ""
  echo -e "${CC_YELLOW}Go tools:${CC_END}"
  echo -e "  goimports           Updates your Go import lines, adding missing ones"
  echo -e "                      and removing unreferenced ones"
  echo -e "  staticcheck         Contains analyzes that find bugs and performance issues"
  echo -e "  errcheck            Program for checking for unchecked errors in Go code"
  echo -e "  golint              Linter for Go source code"
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
function mrcmd_plugins_go_install_tools() {
  local toolsArray=(
    "golang.org/x/tools/cmd/goimports"   "${GO_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "honnef.co/go/tools/cmd/staticcheck" "${GO_TOOLS_INSTALL_STATICCHECK_VERSION}"
    "github.com/kisielk/errcheck"        "${GO_TOOLS_INSTALL_ERRCHECK_VERSION}"
    "golang.org/x/lint/golint"           "${GO_TOOLS_INSTALL_GOLINT_VERSION}"
  )

  mrcmd_plugins_call_function "go/install-tools" toolsArray[@]
}
