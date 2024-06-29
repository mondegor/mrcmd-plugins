
function mrcmd_plugins_global_method_init() {
  readonly GLOBAL_CAPTION="Global vars"

  readonly GLOBAL_VARS=(
    "APPX_ID"
    "APPX_VER"
    "APPX_ENV"
    "APPX_WORK_DIR"
    "HOST_USER_ID"
    "HOST_GROUP_ID"
    "APPX_TZ"
  )

  readonly GLOBAL_VARS_DEFAULT=(
    "sx"
    "v0.0.0"
    "local" # dev, prod
    "${APPX_DIR}/app"

    "1000"
    "1000"
    "Europe/Moscow"
  )

  mrcore_dotenv_init_var_array GLOBAL_VARS[@] GLOBAL_VARS_DEFAULT[@]

  # try to set version from git
  if [[ "${APPX_VER}" == "v0.0.0" ]]; then
    APPX_VER=$(mrcmd_plugins_global_git_version)
  fi

  if [ -z "${APPX_VER}" ]; then
    unset APPX_VER
  fi
}

function mrcmd_plugins_global_method_config() {
  mrcore_dotenv_echo_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_export_config() {
  mrcore_dotenv_export_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    id | uname | which)
      "${currentCommand}" "$@"
      ;;

    capsh)
      capsh --print
      ;;

    chown)
      sudo chown -R "${HOST_USER_ID}:${HOST_GROUP_ID}" "${APPX_DIR}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_global_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  id          Print user and group information"
  echo -e "  uname       Print certain system information"
  echo -e "  which       Used to identify the location of executables"
  echo -e "  capsh       Display prevailing capability and related state"
  echo -e "              https://man7.org/linux/man-pages/man7/capabilities.7.html"
  echo -e "  chown       sudo chown -R ${HOST_USER_ID}:${HOST_GROUP_ID} ${APPX_DIR}"
}

# using example: $(mrcmd_plugins_global_git_version)
function mrcmd_plugins_global_git_version() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>&1)"

  if [[ "${branch}" == "master" ]] || [[ "${branch}" == "main" ]]; then
    branch="$(git describe --long --always --dirty)"
  fi

  echo "${branch}"
}
