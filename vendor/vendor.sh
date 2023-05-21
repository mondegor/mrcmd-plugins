
#function mrcmd_plugins_vendor_method_depends() {
#  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
#}

function mrcmd_plugins_vendor_method_init() {
  readonly VENDOR_CAPTION="Vendor"

  readonly VENDOR_VARS=(
    "VENDOR_DIR"
    "VENDOR_SILENT_MODE" # true, false
    "VENDOR_GIT_CLONE_DEPTH" # --depth N, if N=0 then N=all
  )

  readonly VENDOR_VARS_DEFAULT=(
    "${APPX_DIR}/vendor"
    "true"
    "0"
  )

  mrcore_dotenv_init_var_array VENDOR_VARS[@] VENDOR_VARS_DEFAULT[@]
}

function mrcmd_plugins_vendor_method_config() {
  mrcore_dotenv_echo_var_array VENDOR_VARS[@]
}

function mrcmd_plugins_vendor_method_export_config() {
  mrcore_dotenv_export_var_array VENDOR_VARS[@]
}

function mrcmd_plugins_vendor_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    list)
      ls -l -a "${VENDOR_DIR}"
      ;;

    get)
      mrcmd_plugins_call_function "vendor/package-get" "$@"
      ;;

    pull)
      mrcmd_plugins_call_function "vendor/package-pull" "$@"
      ;;

    remove)
      mrcmd_plugins_call_function "vendor/package-remove" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_vendor_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  list                List of packages in ${CC_BLUE}${VENDOR_DIR}${CC_END}"
  echo -e "  get    ${CC_CYAN}URL${CC_END} [${CC_CYAN}DEST${CC_END}]   Downloads or clones packages"
  echo -e "                      ${CC_CYAN}URL${CC_END} is source url of package,"
  echo -e "                      ${CC_CYAN}DEST${CC_END} is name of vendor or local path"
  echo -e "  pull   ${CC_CYAN}PACKAGE${CC_END}      Pulls git project"
  echo -e "                      ${CC_CYAN}PACKAGE${CC_END} is name of vendor or path"
  echo -e "  remove  ${CC_CYAN}PACKAGE${CC_END}     Removes project"
  echo -e "                      ${CC_CYAN}PACKAGE${CC_END} is name of vendor or path"
}
