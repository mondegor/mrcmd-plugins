# https://hub.docker.com/_/golang

function mrcmd_plugins_go_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose")
}

function mrcmd_plugins_go_method_init() {
  export GO_DOCKER_SERVICE="web-app"

  readonly GO_CAPTION="Go alpine"
  readonly GO_TMP_DIR="${APPX_DIR}/.cache"

  readonly GO_VARS=(
    "GO_DOCKER_CONTAINER"
    "GO_DOCKER_CONTEXT_DIR"
    "GO_DOCKER_DOCKERFILE"
    "GO_DOCKER_COMPOSE_CONFIG_DIR"
    "GO_DOCKER_IMAGE"
    "GO_DOCKER_IMAGE_FROM"

    "GO_GOPATH_DIR"
    "GO_APPX_ENV_FILE"
    "GO_APPX_MAIN_FILE"
    "GO_IMPORTS_LOCAL_PREFIXES"

    ##### "GO_WEBAPP_PUBLIC_PORT"
    "GO_WEBAPP_INTERNAL_PORT"
    "GO_WEBAPP_DOMAIN"

    "GO_TOOLS_INSTALL_GOFUMPT_VERSION"
    "GO_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_TOOLS_INSTALL_GCI_VERSION"

    "GO_TOOLS_INSTALL_MOCKGEN_VERSION"
    "GO_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION"
    "GO_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION"
    "GO_TOOLS_INSTALL_PROTOC_GRPC_GATEWAY_VERSION"
    "GO_TOOLS_INSTALL_PROTOC_GEN_OPENAPIV2_VERSION"
  )

  readonly GO_VARS_DEFAULT=(
    "${APPX_ID}-${GO_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}go:1.22.5"
    "golang:1.22.5-alpine3.20"

    "${GO_TMP_DIR}/golang"
    "${APPX_DIR}/.env"
    "./cmd/app/main.go"
    "" # github.com/example/go-sample

    ##### "127.0.0.1:8080"
    "8080"
    "web-app.local"

    "latest"
    "latest"
    "latest"

    "false" # v1.6.0
    "false" # v1.34.1
    "false" # v1.3.0
    "false" # v2.20.0
    "false" # v2.20.0
  )

  mrcore_dotenv_init_var_array GO_VARS[@] GO_VARS_DEFAULT[@]

  DOCKER_COMPOSE_REQUIRED_SOURCES+=("GOPATH dir" "${GO_GOPATH_DIR}")
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
  mrcore_echo_var "GO_DOCKER_SERVICE (host, readonly)" "${GO_DOCKER_SERVICE}"
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

function mrcmd_plugins_go_method_uninstall() {
  mrcore_lib_rmdir "${GO_TMP_DIR}"
  mrcore_lib_rm "${APPX_WORK_DIR}/test-coverage-full.html"
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

    deps)
      mrcmd_plugins_call_function "go/docker-run" sh -c "go get ./... && \
                                                         go mod tidy"
      ;;

    env)
      mrcmd_plugins_call_function "go/docker-run" go env
      ;;

    get)
      mrcmd_plugins_call_function "go/docker-run" go get "$@"
      ;;

    install)
      mrcmd_plugins_call_function "go/docker-run" go install "$@"
      ;;

    download)
      mrcmd_plugins_call_function "go/docker-run" go mod download "$@"
      ;;

    tidy)
      mrcmd_plugins_call_function "go/docker-run" go mod tidy
      ;;

    gofmt)
      mrcmd_plugins_call_function "go/docker-run" gofmt -d -s ./
      ;;

    gofmt-fix)
      mrcmd_plugins_call_function "go/docker-run" gofmt -l -w ./
      ;;

    gofumpt)
      mrcmd_plugins_call_function "go/docker-run" gofumpt -d -extra ./
      ;;

    fmt | gofumpt-fix)
      mrcmd_plugins_call_function "go/docker-run" gofumpt -l -w -extra ./
      ;;

    goimports)
      local extraParams=""
      if [ -n "${GO_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_IMPORTS_LOCAL_PREFIXES}"
      fi

      mrcmd_plugins_call_function "go/docker-run" goimports -d ${extraParams} ./
      ;;

    fmti | goimports-fix)
      local extraParams=""
      if [ -n "${GO_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_IMPORTS_LOCAL_PREFIXES}"
      fi

      mrcmd_plugins_call_function "go/docker-run" goimports -l -w ${extraParams} ./
      ;;

    gci)
      local extraParams=()
      if [ -n "${GO_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams=(-s "prefix(${GO_IMPORTS_LOCAL_PREFIXES})")
      fi

      mrcmd_plugins_call_function "go/docker-run" gci diff --skip-generated -s standard -s default "${extraParams[@]}" .
      ;;

    fmti2 | gci-fix)
      local extraParams=()
      if [ -n "${GO_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams=(-s "prefix(${GO_IMPORTS_LOCAL_PREFIXES})")
      fi

      mrcmd_plugins_call_function "go/docker-run" gci write --skip-generated -s standard -s default "${extraParams[@]}" .
      ;;

    generate)
      mrcmd_plugins_call_function "go/docker-run" go generate ./...
      ;;

    test)
      mrcmd_plugins_call_function "go/docker-run" go test -cover ./...
      ;;

    test-report)
      mrcmd_plugins_call_function "go/docker-run" sh -c "go test -coverprofile=tmp-test-coverage.out ./... && \
                                                         go tool cover -html=tmp-test-coverage.out -o ./test-coverage-full.html && \
                                                         rm ./tmp-test-coverage.out"
      ;;

    bench)
      mrcmd_plugins_call_function "go/docker-run" go test -run=NONE -bench=. -benchmem ./...
      ;;

    mockgen | protoc-gen-go | protoc-gen-go-grpc | protoc-gen-grpc-gateway | protoc-gen-openapiv2)
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
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${GO_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into                Enters to shell in the running container"
  echo -e "  logs                View output from the running container"
  echo -e "  restart             Restarts the container"
  echo -e ""
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  install-tools       Downloads tools defined in GO_TOOLS_INSTALL_* vars"
  echo -e "  deps                Downloads modules to local cache if need"
  echo -e "                      and refresh their dependencies."
  echo -e "  env                 Prints Go environment information."
  echo -e "  get [arguments]     Downloads the packages named by the import paths,"
  echo -e "                      along with their dependencies."
  echo -e "  install [args]      Compile and install packages and dependencies."
  echo -e "  download [args]     Download modules to local cache."
  echo -e "  tidy                Add missing and remove unused modules."
  echo -e "  gofmt[-fix]         Run formatter for Go source code."
  echo -e "  gofumpt[-fix]       Run extended formatter for Go source code."
  echo -e "  fmt                 Run gofumpt-fix."
  echo -e "  goimports[-fix]     Updates your Go import lines, adding missing ones"
  echo -e "                      and removing unreferenced ones."
  echo -e "  gci[-fix]           Controls Go package import order and makes"
  echo -e "                      it always deterministic."
  echo -e "  fmti                Alias for goimports-fix."
  echo -e "  fmti2               Alias for gci-fix."
  echo -e "  generate            Generate runs commands described by directives"
  echo -e "                      within existing files."
  echo -e "  test                Automates testing the packages named by the import paths."
  echo -e "  test-report         Generates the test report: ${CC_BLUE}${APPX_WORK_DIR}test-coverage-full.html${CC_END}"
  echo -e "  bench               Run benchmarks of the packages named by the import paths."
  echo -e ""
  echo -e "${CC_YELLOW}Go tools:${CC_END}"
  echo -e "  mockgen [args]              It is a mocking framework for the Go."
  echo -e "  protoc-gen-go [args]"
  echo -e "  protoc-gen-go-grpc [args]"
  echo -e "  protoc-gen-grpc-gateway [args]"
  echo -e "  protoc-gen-openapiv2 [args]"
}

# private
function mrcmd_plugins_go_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${GO_DOCKER_CONTEXT_DIR}" \
    "${GO_DOCKER_DOCKERFILE}" \
    "${GO_DOCKER_IMAGE}" \
    "${GO_DOCKER_IMAGE_FROM}" \
    --build-arg "WEBAPP_INTERNAL_PORT=${GO_WEBAPP_INTERNAL_PORT}" \
    "$@"
}

# private
function mrcmd_plugins_go_install_tools() {
  local toolsArray=(
    "mvdan.cc/gofumpt"                 "${GO_TOOLS_INSTALL_GOFUMPT_VERSION}"
    "golang.org/x/tools/cmd/goimports" "${GO_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "github.com/daixiang0/gci"         "${GO_TOOLS_INSTALL_GCI_VERSION}"
    "github.com/golang/mock/mockgen"   "${GO_TOOLS_INSTALL_MOCKGEN_VERSION}"
    "google.golang.org/protobuf/cmd/protoc-gen-go"  "${GO_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION}"
    "google.golang.org/grpc/cmd/protoc-gen-go-grpc" "${GO_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION}"
    "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway" "${GO_TOOLS_INSTALL_PROTOC_GRPC_GATEWAY_VERSION}"
    "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2"    "${GO_TOOLS_INSTALL_PROTOC_GEN_OPENAPIV2_VERSION}"
  )

  mrcmd_plugins_call_function "go/install-tools" toolsArray[@]
}
