
function mrcmd_plugins_manager_method_exec() {
  local currentCommand=${1:?}
  local pluginName=${2-}

  case ${currentCommand} in

    all)
      mrcmd_plugins_call_function "manager/available-plugins" "${pluginName}"
      ;;

    create)
      mrcmd_plugins_call_function "manager/create-plugin" "${pluginName}"
      ;;

    create-function)
      local funcName=${3-}
      mrcmd_plugins_call_function "manager/create-function" "${pluginName}" "${funcName}"
      ;;

    copy-plugin)
      local newPluginName=${3-}
      mrcmd_plugins_call_function "manager/copy-plugin" "${pluginName}" "${newPluginName}"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_manager_method_help() {
  echo -e "${CC_YELLOW}Plugins manager${CC_END}:"
  echo -e "  ${CC_GREEN}all${CC_END}                                            List of available plugins"
  echo -e "  ${CC_GREEN}create${CC_END} <plugin-name>                           Create a new plugin in the project"
  echo -e "  ${CC_GREEN}create-function${CC_END} <plugin-name> <function-name>  Create a new function in the plugin of the project"
  echo -e "  ${CC_GREEN}copy-plugin${CC_END} <source-plugin-name> <plugin-name> Copy source-plugin-name to project as plugin-name"
  echo ""
}
