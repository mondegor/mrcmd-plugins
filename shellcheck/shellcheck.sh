# https://hub.docker.com/r/koalaman/shellcheck-alpine

# ./mrcmd shellcheck shellcheck shellcheck /mnt/mrcmd.sh

function mrcmd_plugins_shellcheck_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
}

function mrcmd_plugins_shellcheck_method_init() {
  readonly SHELLCHECK_NAME="Shellcheck"

  readonly SHELLCHECK_VARS=(
    "SHELLCHECK_DOCKER_IMAGE"
    "SHELLCHECK_APPX_APP_DIR"
  )

  readonly SHELLCHECK_VARS_DEFAULT=(
    "koalaman/shellcheck-alpine:v0.9.0"
    "$(realpath "${APPX_DIR}")"
  )

  mrcore_dotenv_init_var_array SHELLCHECK_VARS[@] SHELLCHECK_VARS_DEFAULT[@]
}

function mrcmd_plugins_shellcheck_method_config() {
  mrcore_dotenv_echo_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_export_config() {
  mrcore_dotenv_export_var_array SHELLCHECK_VARS[@]
}

function mrcmd_plugins_shellcheck_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    check)
      mrcmd_plugins_call_function "shellcheck/docker-run" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_shellcheck_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                List of available plugins"
  echo -e "  docker-run                  List of available plugins"
}
