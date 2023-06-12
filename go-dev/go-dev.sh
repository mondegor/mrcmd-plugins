# https://go.dev/

function mrcmd_plugins_go_dev_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
}

function mrcmd_plugins_go_dev_method_init() {
  readonly GO_DEV_CAPTION="Go Dev"

  readonly GO_DEV_VARS=(
    "GO_DEV_GOPATH"
    "GO_DEV_APP_MAIN_FILE"

    "GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION"
    "GO_DEV_TOOLS_INSTALL_STATICCHECK_VERSION"
    "GO_DEV_TOOLS_INSTALL_ERRCHECK_VERSION"
    "GO_DEV_TOOLS_INSTALL_GOLINT_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION"
    "GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION"
  )

  readonly GO_DEV_VARS_DEFAULT=(
    ""
    "./cmd/app/main.go"

    "v0.8.0"
    "v0.4.3"
    "v1.6.3"
    "v0.0.0-20210508222113-6edffad5e616"
    "v1.28"
    "v1.2"
  )

  if [ -n "${GOPATH-}" ] && [ -d "${GOPATH}" ]; then
    GO_DEV_GOPATH="$(mrcore_os_path_win_to_unix "${GOPATH}")/bin"
  else
    mrcore_echo_warning "${GO_DEV_CAPTION}: \$GOPATH not found"
  fi

  mrcore_dotenv_init_var_array GO_DEV_VARS[@] GO_DEV_VARS_DEFAULT[@]
}

function mrcmd_plugins_go_dev_method_config() {
  mrcore_dotenv_echo_var_array GO_DEV_VARS[@]
}

function mrcmd_plugins_go_dev_method_export_config() {
  mrcore_dotenv_export_var_array GO_DEV_VARS[@]
}

function mrcmd_plugins_go_dev_method_install() {
  mrcore_lib_mkdir "${APPX_WORK_DIR}/logs"
  mrcmd_plugins_go_dev_install_tools
  mrcmd_plugins_go_dev_go mod download
}

function mrcmd_plugins_go_dev_method_uninstall() {
  mrcore_lib_rmdir "${APPX_WORK_DIR}/logs"
}

function mrcmd_plugins_go_dev_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    env)
      mrcmd_plugins_go_dev_go env
      ;;

    run)
      mrcmd_plugins_go_dev_go run "${GO_DEV_APP_MAIN_FILE}"
      ;;

    get)
      mrcmd_plugins_go_dev_go get "$@"
      ;;

    download)
      mrcmd_plugins_go_dev_go mod download "$@"
      ;;

    tidy)
      mrcmd_plugins_go_dev_go mod tidy
      ;;

    install-tools)
      mrcmd_plugins_go_dev_install_tools
      ;;

    goimports | staticcheck | errcheck | golint | protoc-gen-go | protoc-gen-go-grpc)
      "${GO_DEV_GOPATH}/${currentCommand}" "$@"
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
  echo -e "  get                 Downloads the packages named by the import paths,"
  echo -e "                      along with their dependencies."
  echo -e "  download            Downloads the named modules."
  echo -e "  tidy                Add missing and remove unused modules."
  echo -e "  install-tools      Downloads tools defined in GO_DEV_TOOLS_INSTALL_* vars"
  echo -e ""
  echo -e "${CC_YELLOW}Go tools:${CC_END}"
  echo -e "  goimports           Updates your Go import lines, adding missing ones"
  echo -e "                      and removing unreferenced ones."
  echo -e "  staticcheck         Contains analyzes that find bugs and performance issues."
  echo -e "  errcheck            Program for checking for unchecked errors in Go code."
  echo -e "  golint              Linter for Go source code."
}

# private
function mrcmd_plugins_go_dev_install_tools() {
  local toolsArray=(
    "golang.org/x/tools/cmd/goimports"              "${GO_DEV_TOOLS_INSTALL_GOIMPORTS_VERSION}"
    "honnef.co/go/tools/cmd/staticcheck"            "${GO_DEV_TOOLS_INSTALL_STATICCHECK_VERSION}"
    "github.com/kisielk/errcheck"                   "${GO_DEV_TOOLS_INSTALL_ERRCHECK_VERSION}"
    "golang.org/x/lint/golint"                      "${GO_DEV_TOOLS_INSTALL_GOLINT_VERSION}"
    "google.golang.org/protobuf/cmd/protoc-gen-go"  "${GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_VERSION}"
    "google.golang.org/grpc/cmd/protoc-gen-go-grpc" "${GO_DEV_TOOLS_INSTALL_PROTOC_GEN_GO_GRPC_VERSION}"
  )

  mrcmd_plugins_call_function "go-dev/install-tools" toolsArray[@]
}

function mrcmd_plugins_go_dev_go() {
  cd "${APPX_WORK_DIR}"
  go "$@"
  cd "${APPX_DIR_REAL}"
}
