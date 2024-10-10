# https://go.dev/

function mrcmd_plugins_go_dev_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
}

function mrcmd_plugins_go_dev_method_init() {
  readonly GO_DEV_CAPTION="Go Dev"

  readonly GO_DEV_VARS=(
    "GO_DEV_IMPORTS_LOCAL_PREFIXES"
    "GO_DEV_TOOLS_BIN_DIR"

    "GO_DEV_TOOLS_INSTALL_GOFUMPT_VERSION"
    "GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_DEV_TOOLS_INSTALL_GCI_VERSION"

    "GO_DEV_TOOLS_INSTALL_MOCKGEN_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GRPC_GATEWAY_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_OPENAPIV2_VERSION"
  )

  readonly GO_DEV_VARS_DEFAULT=(
    "" # github.com/example/go-sample
    ""

    "latest"
    "latest"
    "latest"

    "false" # v1.6.0
    "false" # v1.34.1
    "false" # v1.3.0
    "false" # v2.20.0
    "false" # v2.20.0
  )

  mrcore_dotenv_init_var_array GO_DEV_VARS[@] GO_DEV_VARS_DEFAULT[@]

  if mrcore_command_exists "go${CMD_SEPARATOR}version" ; then
    readonly GO_DEV_IS_ENABLED=true
  else
    readonly GO_DEV_IS_ENABLED=false
  fi

  if [[ "${GO_DEV_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'go' not installed, so plugin '${GO_DEV_CAPTION}' was deactivated"
    return
  fi

  if [ -z "${GO_DEV_TOOLS_BIN_DIR}" ]; then
    if [ -n "${GOPATH-}" ] && [ -d "${GOPATH}" ]; then
      GO_DEV_TOOLS_BIN_DIR="$(mrcore_os_path_win_to_unix "${GOPATH}")/bin"
    else
      mrcore_debug_echo ${DEBUG_LEVEL_1} "${DEBUG_RED}" "${GO_DEV_CAPTION}: \$GOPATH not found"
    fi
  fi
}

function mrcmd_plugins_go_dev_method_canexec() {
  if [[ "${GO_DEV_IS_ENABLED}" == true ]]; then
    ${RETURN_TRUE}
  fi

  local pluginMethod="${1:?}"

  if mrcore_lib_in_array "${pluginMethod}" MRCMD_PLUGIN_METHODS_EXECUTE_COMMANDS_ARRAY[@] ; then
    ${RETURN_FALSE}
  fi

  ${RETURN_TRUE}
}

function mrcmd_plugins_go_dev_method_config() {
  mrcore_dotenv_echo_var_array GO_DEV_VARS[@]
}

function mrcmd_plugins_go_dev_method_export_config() {
  mrcore_dotenv_export_var_array GO_DEV_VARS[@]
}

function mrcmd_plugins_go_dev_method_install() {
  if [[ "${GO_DEV_IS_ENABLED}" == false ]]; then
    return
  fi

  mrcmd_plugins_go_dev_install_tools
  mrcmd_plugins_go_dev_workdir go mod tidy
  mrcmd_plugins_go_dev_workdir go mod download
}

function mrcmd_plugins_go_dev_method_uninstall() {
  mrcore_lib_rm "${APPX_WORK_DIR}/test-coverage-full.html"
}

function mrcmd_plugins_go_dev_method_exec() {
  if [[ "${GO_DEV_IS_ENABLED}" == false ]]; then
    return
  fi

  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    install-tools)
      mrcmd_plugins_go_dev_install_tools
      ;;

    deps)
      mrcmd_plugins_go_dev_workdir go get ./...
      mrcmd_plugins_go_dev_workdir go mod tidy
      ;;

    env)
      mrcmd_plugins_go_dev_workdir go env
      ;;

    get)
      mrcmd_plugins_go_dev_workdir go get "$@"
      ;;

    install)
      mrcmd_plugins_go_dev_workdir go install "$@"
      ;;

    download)
      mrcmd_plugins_go_dev_workdir go mod download "$@"
      ;;

    tidy)
      mrcmd_plugins_go_dev_workdir go mod tidy
      ;;

    gofmt)
      mrcmd_plugins_go_dev_workdir gofmt -d -s ./
      ;;

    gofmt-fix)
      mrcmd_plugins_go_dev_workdir gofmt -l -w ./
      ;;

    gofumpt)
      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/gofumpt -d -extra ./
      ;;

    fmt | gofumpt-fix)
      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/gofumpt -l -w -extra ./
      ;;

    goimports)
      local extraParams=""
      if [ -n "${GO_DEV_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_DEV_IMPORTS_LOCAL_PREFIXES}"
      fi

      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/goimports -d ${extraParams} ./
      ;;

    fmti | goimports-fix)
      local extraParams=""
      if [ -n "${GO_DEV_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_DEV_IMPORTS_LOCAL_PREFIXES}"
      fi

      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/goimports -l -w ${extraParams} ./
      ;;

    gci)
      local extraParams=()
      if [ -n "${GO_DEV_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams=(-s "prefix(${GO_DEV_IMPORTS_LOCAL_PREFIXES})")
      fi

      mrcmd_plugins_go_dev_workdir gci diff --skip-generated -s standard -s default "${extraParams[@]}" .
      ;;

    fmti2 | gci-fix)
      local extraParams=()
      if [ -n "${GO_DEV_IMPORTS_LOCAL_PREFIXES}" ]; then
        extraParams=(-s "prefix(${GO_DEV_IMPORTS_LOCAL_PREFIXES})")
      fi

      mrcmd_plugins_go_dev_workdir gci write --skip-generated -s standard -s default "${extraParams[@]}" .
      ;;

    generate)
      mrcmd_plugins_go_dev_workdir go generate ./...
      ;;

    test)
      mrcmd_plugins_go_dev_workdir go test -cover ./...
      ;;

    test-report)
      mrcmd_plugins_go_dev_workdir go test -coverprofile=tmp-test-coverage.out ./...
      mrcmd_plugins_go_dev_workdir go tool cover -html=tmp-test-coverage.out -o ./test-coverage-full.html
      mrcmd_plugins_go_dev_workdir rm ./tmp-test-coverage.out
      ;;

    bench)
      mrcmd_plugins_go_dev_workdir go test -run=NONE -bench=. -benchmem ./...
      ;;

    mockgen | protoc-gen-go | protoc-gen-go-grpc | protoc-gen-grpc-gateway | protoc-gen-openapiv2)
      "${GO_DEV_TOOLS_BIN_DIR}/${currentCommand}" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_go_dev_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
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
function mrcmd_plugins_go_dev_install_tools() {
  local toolsArray=(
    "mvdan.cc/gofumpt"                 "${GO_DEV_TOOLS_INSTALL_GOFUMPT_VERSION}"
    "golang.org/x/tools/cmd/goimports" "${GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "github.com/daixiang0/gci"         "${GO_DEV_TOOLS_INSTALL_GCI_VERSION}"
    "github.com/golang/mock/mockgen"   "${GO_DEV_TOOLS_INSTALL_MOCKGEN_VERSION}"
    "google.golang.org/protobuf/cmd/protoc-gen-go"  "${GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION}"
    "google.golang.org/grpc/cmd/protoc-gen-go-grpc" "${GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION}"
    "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway" "${GO_DEV_TOOLS_INSTALL_PROTOC_GRPC_GATEWAY_VERSION}"
    "github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2"    "${GO_DEV_TOOLS_INSTALL_PROTOC_GEN_OPENAPIV2_VERSION}"
  )

  mrcmd_plugins_call_function "go-dev/install-tools" toolsArray[@]
}

# private
function mrcmd_plugins_go_dev_workdir() {
  local currentCommand="${1:?}"
  shift

  cd "${APPX_WORK_DIR}"
  ${currentCommand} "$@"
  cd "${APPX_DIR_REAL}"
}
