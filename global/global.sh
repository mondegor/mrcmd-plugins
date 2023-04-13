
readonly GLOBAL_VARS=(
  "MRCMD_DIR"
  "APPX_ID"
  "APPX_DIR"
  "ALPINE_INSTALL_BASH"
  "HOST_USER_ID"
  "HOST_GROUP_ID"
  "TZ"
  "APPX_DB_HOST"
  "APPX_DB_NAME"
  "APPX_DB_USER"
  "APPX_DB_PASSWORD"
)

# default values of array: GLOBAL_VARS
readonly GLOBAL_VARS_DEFAULT=(
  ""
  "appx8721"
  ""
  "false"
  "1000"
  "1000"
  "Europe/Moscow"
  ""
  ""
  ""
  ""
)

function mrcmd_plugins_global_method_config() {
  mrcore_dotenv_echo_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_export_config() {
  mrcore_dotenv_export_var_array GLOBAL_VARS[@]
}

function mrcmd_plugins_global_method_init() {
  mrcore_dotenv_init_var_array GLOBAL_VARS[@] GLOBAL_VARS_DEFAULT[@]
}

function mrcmd_plugins_global_method_exec() {
  local currentCommand=${1:?}

  case ${currentCommand} in

    app-no-root)
      sudo chown -R "${HOST_USER_ID}:${HOST_GROUP_ID}" "${APPX_DIR}"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_global_method_help() {
  echo -e "${CC_YELLOW}Global${CC_END}:"
  echo -e "  ${CC_GREEN}app-no-root${CC_END}        List of available plugins"
  echo ""
}