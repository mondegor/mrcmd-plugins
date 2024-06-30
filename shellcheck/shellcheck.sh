# https://hub.docker.com/r/koalaman/shellcheck-alpine
# https://github.com/koalaman/shellcheck

function mrcmd_plugins_shellcheck_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_shellcheck_method_init() {
  readonly SHELLCHECK_CAPTION="Shellcheck"

  readonly SHELLCHECK_VARS=(
    "SHELLCHECK_DOCKER_CONTEXT_DIR"
    "SHELLCHECK_DOCKER_DOCKERFILE"
    "SHELLCHECK_DOCKER_IMAGE"
    "SHELLCHECK_DOCKER_IMAGE_FROM"
  )

  readonly SHELLCHECK_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}shellcheck:v0.9.0"
    "koalaman/shellcheck-alpine:v0.9.0"
  )

  mrcore_dotenv_init_var_array SHELLCHECK_VARS[@] SHELLCHECK_VARS_DEFAULT[@]

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${SHELLCHECK_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_shellcheck_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_shellcheck_method_config() {
  mrcore_dotenv_echo_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_export_config() {
  mrcore_dotenv_export_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_install() {
  mrcmd_plugins_shellcheck_docker_build --no-cache
}

function mrcmd_plugins_shellcheck_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_shellcheck_method_config
      mrcmd_plugins_shellcheck_docker_build "$@"
      ;;

    check)
      mrcmd_plugins_call_function "shellcheck/docker-run" shellcheck "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_shellcheck_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  check [file-name]   Check shell scripts by static analysis"
}

# private
function mrcmd_plugins_shellcheck_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${SHELLCHECK_DOCKER_CONTEXT_DIR}" \
    "${SHELLCHECK_DOCKER_DOCKERFILE}" \
    "${SHELLCHECK_DOCKER_IMAGE}" \
    "${SHELLCHECK_DOCKER_IMAGE_FROM}" \
    "$@"
}
