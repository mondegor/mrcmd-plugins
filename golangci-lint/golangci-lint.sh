# https://hub.docker.com/r/golangci/golangci-lint
# https://github.com/golangci/awesome-go-linters

function mrcmd_plugins_golangci_lint_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_golangci_lint_method_init() {
  readonly GOLANGCI_LINT_CAPTION="GolangCI Lint"

  readonly GOLANGCI_LINT_VARS=(
    "GOLANGCI_LINT_DOCKER_CONTEXT_DIR"
    "GOLANGCI_LINT_DOCKER_DOCKERFILE"
    "GOLANGCI_LINT_DOCKER_IMAGE"
    "GOLANGCI_LINT_DOCKER_IMAGE_FROM"

    "GOLANGCI_GOPATH_DIR"
    "GOLANGCI_LINT_CACHE_DIR"
  )

  readonly GOLANGCI_LINT_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}golangci-lint:v1.59.0"
    "golangci/golangci-lint:v1.59.0-alpine"

    "${APPX_DIR}/../golang" # todo: временно
    "${APPX_DIR}/.cache/golangci-lint"
  )

  mrcore_dotenv_init_var_array GOLANGCI_LINT_VARS[@] GOLANGCI_LINT_VARS_DEFAULT[@]

  if [ -z "${GOLANGCI_GOPATH_DIR}" ]; then
    mrcore_validate_dir_required "System GOPATH" "${GOPATH-}"
    GOLANGCI_GOPATH_DIR="$(mrcore_os_path_win_to_unix "${GOPATH}")"
  fi

  mrcore_validate_dir_required "GOPATH" "${GOLANGCI_GOPATH_DIR}"
}

function mrcmd_plugins_golangci_lint_method_config() {
  mrcore_dotenv_echo_var_array GOLANGCI_LINT_VARS[@]
}

function mrcmd_plugins_golangci_lint_method_export_config() {
  mrcore_dotenv_export_var_array GOLANGCI_LINT_VARS[@]
}

function mrcmd_plugins_golangci_lint_method_install() {
  mrcore_lib_mkdir "${GOLANGCI_LINT_CACHE_DIR}"
  mrcmd_plugins_golangci_lint_docker_build --no-cache
}

function mrcmd_plugins_go_method_uninstall() {
  mrcore_lib_rmdir "${GOLANGCI_LINT_CACHE_DIR}"
}

function mrcmd_plugins_golangci_lint_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_golangci_lint_method_config
      mrcmd_plugins_golangci_lint_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "golangci-lint/docker-run" golangci-lint "$@"
      ;;

    check)
      mrcmd_plugins_call_function "golangci-lint/docker-run" golangci-lint run ./...
      ;;

    check-fast)
      mrcmd_plugins_call_function "golangci-lint/docker-run" golangci-lint run --fast ./...
      ;;

    check-fix)
      mrcmd_plugins_call_function "golangci-lint/docker-run" golangci-lint run --fix ./...
      ;;

    linters)
      mrcmd_plugins_call_function "golangci-lint/docker-run" golangci-lint linters
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_golangci_lint_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'golangci-lint [arguments]' in a container of the image"
  echo -e "  check [path]        "
  echo -e "  check-fast [path]   "
  echo -e "  check-fix [path]    "
  echo -e "  linters [path]      "
}

# private
function mrcmd_plugins_golangci_lint_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${GOLANGCI_LINT_DOCKER_CONTEXT_DIR}" \
    "${GOLANGCI_LINT_DOCKER_DOCKERFILE}" \
    "${GOLANGCI_LINT_DOCKER_IMAGE}" \
    "${GOLANGCI_LINT_DOCKER_IMAGE_FROM}" \
    "$@"
}
