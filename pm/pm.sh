
function mrcmd_plugins_pm_method_init() {
  readonly PM_NAME="Plugins manager"
}

function mrcmd_plugins_pm_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    a | all)
      local isShowMethods=false

      if [[ "${1-}" == "--show-methods" ]]; then
        local isShowMethods=true
      fi

      mrcmd_plugins_call_function "pl/available-plugins" "${isShowMethods}"
      ;;

    cr | create)
      local pluginName="${1-}"
      mrcmd_plugins_call_function "pl/create-plugin" "${pluginName}"
      ;;

    cr-fn | create-func)
      local pluginName="${1-}"
      local funcName="${2-}"
      mrcmd_plugins_call_function "pl/create-func" "${pluginName}" "${funcName}"
      ;;

    cp | copy)
      local pluginName="${1-}"
      local newPluginName="${2-}"
      mrcmd_plugins_call_function "pl/copy-plugin" "${pluginName}" "${newPluginName}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_pm_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  all <${CC_BLUE}--show-methods${CC_END}>        List of available plugins"
  echo -e "                              ${CC_CYAN}show-methods${CC_END} is false or true, its enabled  show plugin methods"
  echo -e "  create ${CC_CYAN}PLUGIN${CC_END}               Create a new plugin in the project"
  echo -e "                              ${CC_CYAN}PLUGIN${CC_END} is a plugin name"
  echo -e "  create-func ${CC_CYAN}PLUGIN FUNC${CC_END}     Create a new function in the plugin of the project"
  echo -e "                              ${CC_CYAN}PLUGIN${CC_END} is a plugin name"
  echo -e "                              ${CC_CYAN}FUNC${CC_END} is a function name"
  echo -e "  copy ${CC_CYAN}SOURCE DEST${CC_END}            Copy source-plugin-name to project as plugin-name"
  echo -e "                              ${CC_CYAN}SOURCE${CC_END} is a plugin name"
  echo -e "                              ${CC_CYAN}DEST${CC_END} is a function name"
}
