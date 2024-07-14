# https://hub.docker.com/_/golang

function mrcmd_plugins_go_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_go_method_init() {
  readonly GO_CAPTION="Go alpine"
  readonly GO_DOCKER_SERVICE="web-app"
  readonly GO_TMP_DIR="${APPX_DIR}/.cache"

  readonly GO_VARS=(
    "READONLY_GO_DOCKER_HOST"
    "GO_DOCKER_CONTAINER"
    "GO_DOCKER_CONTEXT_DIR"
    "GO_DOCKER_DOCKERFILE"
    "GO_DOCKER_COMPOSE_CONFIG_DIR"
    "GO_DOCKER_IMAGE"
    "GO_DOCKER_IMAGE_FROM"

    "GO_GOPATH_DIR"
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
    "${GO_DOCKER_SERVICE}"
    "${APPX_ID}-${GO_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}go:1.22.5"
    "golang:1.22.5-alpine3.20"

    "${GO_TMP_DIR}/golang"
    "${APPX_DIR}/.env"
    "./cmd/app/main.go"

    "127.0.0.1:8080"
    "0.0.0.0"
    "8080"

    "v0.8.0"
    "v0.4.3"
    "v1.6.3"
    "v0.0.0-20210508222113-6edffad5e616"
  )

  mrcore_dotenv_init_var_array GO_VARS[@] GO_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${GO_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${GO_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_go_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_go_method_config() {
  mrcore_dotenv_echo_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_export_config() {
  mrcore_dotenv_export_var_array GO_VARS[@]
}

function mrcmd_plugins_go_method_install() {
  mrcore_lib_mkdir "${GO_TMP_DIR}"
  mrcore_lib_mkdir "${GO_GOPATH_DIR}"

  mrcmd_plugins_go_docker_build --no-cache
  mrcmd_plugins_go_install_tools
  mrcmd_plugins_call_function "go/docker-run" go mod tidy
  mrcmd_plugins_call_function "go/docker-run" go mod download
}

function mrcmd_plugins_go_method_start() {
  mrcore_validate_dir_required "GOPATH dir" "${GO_GOPATH_DIR}"
}

function mrcmd_plugins_go_method_uninstall() {
  mrcore_lib_rmdir "${GO_TMP_DIR}"
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
       # sh - shell name
      mrcmd_plugins_call_function "go/docker-run" sh "$@"
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
        sh # shell name
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
  echo -e "  gofmt               Formatter for Go source code"
  echo -e "  golint              Linter for Go source code"
}

# private
function mrcmd_plugins_go_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${GO_DOCKER_CONTEXT_DIR}" \
    "${GO_DOCKER_DOCKERFILE}" \
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
