# https://go.dev/

function mrcmd_plugins_go_dev_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
}

function mrcmd_plugins_go_dev_method_init() {
  readonly GO_DEV_CAPTION="Go Dev"

  readonly GO_DEV_VARS=(
    "GO_DEV_TOOLS_BIN_DIR"
    "GO_DEV_APP_MAIN_FILE"
    "GO_DEV_LOCAL_PACKAGE"

    "GO_DEV_TOOLS_INSTALL_GOFUMPT_VERSION"
    "GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_DEV_TOOLS_INSTALL_STATICCHECK_VERSION"
    "GO_DEV_TOOLS_INSTALL_ERRCHECK_VERSION"

    "GO_DEV_TOOLS_INSTALL_MOCKGEN_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GRPC_GATEWAY_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_OPENAPIV2_VERSION"
  )

  readonly GO_DEV_VARS_DEFAULT=(
    ""
    "./cmd/app/main.go"
    ""

    "latest"
    "latest"
    "latest"
    "latest"

    "v1.6.0"
    "v1.34.1"
    "v1.3.0"
    "v2.20.0"
    "v2.20.0"
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

function mrcmd_plugins_go_dev_method_exec() {
  if [[ "${GO_DEV_IS_ENABLED}" == false ]]; then
    return
  fi

  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    env)
      mrcmd_plugins_go_dev_workdir go env
      ;;

    run)
      mrcmd_plugins_go_dev_workdir go run "${GO_DEV_APP_MAIN_FILE}"
      ;;

    get)
      mrcmd_plugins_go_dev_workdir go get "$@"
      ;;

    get-upgrade)
      mrcmd_plugins_go_dev_workdir go get -u ./...
      ;;

    download)
      mrcmd_plugins_go_dev_workdir go mod download "$@"
      ;;

    tidy)
      mrcmd_plugins_go_dev_workdir go mod tidy
      ;;

    generate)
      mrcmd_plugins_go_dev_workdir go generate ./...
      ;;

    test)
      mrcmd_plugins_go_dev_workdir go test -cover -count=1 ./...
      ;;

    test-report)
      mrcmd_plugins_go_dev_workdir go test -coverprofile=tmp-test-coverage.out ./...
      mrcmd_plugins_go_dev_workdir go tool cover -html=tmp-test-coverage.out -o ./test-coverage-full.html
      mrcmd_plugins_go_dev_workdir rm ./tmp-test-coverage.out
      ;;

    install-tools)
      mrcmd_plugins_go_dev_install_tools
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
      # https://giaogiaocat.github.io/go/how-to-fix-file-is-not-gofumpt-ed-gofumpt-error/
      # go get github.com/daixiang0/gci
      # gci -w -local github.com/daixiang0/gci main.go

      local extraParams=""
      if [ -n "${GO_DEV_LOCAL_PACKAGE}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_DEV_LOCAL_PACKAGE}"
      fi

      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/goimports -d ${extraParams} ./
      ;;

    goimports-fix)
      local extraParams=""
      if [ -n "${GO_DEV_LOCAL_PACKAGE}" ]; then
        extraParams="-local${CMD_SEPARATOR}${GO_DEV_LOCAL_PACKAGE}"
      fi

      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/goimports -l -w ${extraParams} ./
      ;;

    check)
      echo -e "${CC_YELLOW}go vet:${CC_END}"
      mrcmd go-dev vet
      echo -e "${CC_YELLOW}staticcheck:${CC_END}"
      mrcmd go-dev staticcheck
      echo -e "${CC_YELLOW}errcheck:${CC_END}"
      mrcmd go-dev errcheck
      ;;

    vet)
      mrcmd_plugins_go_dev_workdir go vet ./...
      ;;

    staticcheck | errcheck)
      mrcmd_plugins_go_dev_workdir ${GO_DEV_TOOLS_BIN_DIR}/${currentCommand} ./...
      ;;

    protoc-gen-go | protoc-gen-go-grpc | protoc-gen-grpc-gateway | protoc-gen-openapiv2)
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
  echo -e "  env                 Prints Go environment information."
  echo -e "  run                 Compiles and runs package ${CC_BLUE}${GO_DEV_APP_MAIN_FILE}${CC_END}"
  echo -e "  get [arguments]     Downloads the packages named by the import paths,"
  echo -e "                      along with their dependencies."
  echo -e "  get-upgrade         Downloads and upgrade the packages."
  echo -e "  download [args]     Downloads the named modules."
  echo -e "  tidy                Add missing and remove unused modules."
  echo -e "  generate            Generate runs commands described by directives"
  echo -e "                      within existing files."
  echo -e "  test                Automates testing the packages named by the import paths."
  echo -e "  test-report         Generates the test report:"
  echo -e "                      ${CC_BLUE}${APPX_WORK_DIR}test-coverage-full.html${CC_END}"
  echo -e "  install-tools       Downloads tools defined in GO_DEV_TOOLS_INSTALL_* vars"
  echo -e ""
  echo -e "${CC_YELLOW}Go tools:${CC_END}"
  echo -e "  fmt                 Run gofumpt-fix"
  echo -e "  check               Run vet, staticcheck, errcheck"
  echo -e "  gofmt[-fix]         Run formatter for Go source code."
  echo -e "  gofumpt[-fix]       Run extended formatter for Go source code."
  echo -e "  goimports[-fix]     Updates your Go import lines, adding missing ones"
  echo -e "                      and removing unreferenced ones."
  echo -e "  vet                 Vet examines Go source code and reports suspicious constructs."
  echo -e "  staticcheck         Contains analyzes that find bugs and performance issues."
  echo -e "  errcheck            Program for checking for unchecked errors in Go code."
  echo -e "  mockgen             It is a mocking framework for the Go"
  echo -e ""
  echo -e "${CC_YELLOW}Go proto tools:${CC_END}"
  echo -e "  protoc-gen-go [args]"
  echo -e "  protoc-gen-go-grpc [args]"
  echo -e "  protoc-gen-grpc-gateway [args]"
  echo -e "  protoc-gen-openapiv2 [args]"
}

# private
function mrcmd_plugins_go_dev_install_tools() {
  local toolsArray=(
    "mvdan.cc/gofumpt"                   "${GO_DEV_TOOLS_INSTALL_GOFUMPT_VERSION}"
    "golang.org/x/tools/cmd/goimports"   "${GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "honnef.co/go/tools/cmd/staticcheck" "${GO_DEV_TOOLS_INSTALL_STATICCHECK_VERSION}"
    "github.com/kisielk/errcheck"        "${GO_DEV_TOOLS_INSTALL_ERRCHECK_VERSION}"
    "github.com/golang/mock/mockgen"     "${GO_DEV_TOOLS_INSTALL_MOCKGEN_VERSION}"
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
