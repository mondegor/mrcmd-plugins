
# https://hub.docker.com/r/koalaman/shellcheck-alpine

# ./mrcmd shellcheck shellcheck shellcheck /mnt/mrcmd.sh

readonly SHELLCHECK_VARS=(
  "SHELLCHECK_DOCKER_IMAGE"
  "SHELLCHECK_APP_VOLUME"
)

# default values of array: SHELLCHECK_VARS
readonly SHELLCHECK_VARS_DEFAULT=(
  "koalaman/shellcheck-alpine:v0.9.0"
  "$(realpath "${APPX_DIR}")"
)

function mrcmd_plugins_shellcheck_method_config() {
  mrcore_dotenv_echo_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_export_config() {
  mrcore_dotenv_export_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_init() {
  mrcore_dotenv_init_var_array SHELLCHECK_VARS[@] SHELLCHECK_VARS_DEFAULT[@]
}

function mrcmd_plugins_shellcheck_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    shellcheck)
      mrcmd_plugins_call_function "shellcheck/docker-run" "$@"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_shellcheck_method_help() {
  echo -e "${CC_YELLOW}shellcheck${CC_END}:"
  echo -e "  ${CC_GREEN}docker-build${CC_END}        List of available plugins"
  echo -e "  ${CC_GREEN}docker-run${CC_END}        List of available plugins"
  echo ""
}