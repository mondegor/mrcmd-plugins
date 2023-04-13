
# run: mrcmd_plugins_call_function "manager/available-plugins"
function mrcmd_func_manager_available_plugins() {
  local pluginName
  local dirIndex
  local dirIndexLast=0
  local pluginsDir
  local i=0

  echo -e "Current value of ${CC_YELLOW}MRCMD_SHARED_PLUGINS_ENABLED${CC_END}:"
  if [ -n "${MRCMD_SHARED_PLUGINS_ENABLED}" ]; then
    mrcore_echo_ok "${MRCMD_SHARED_PLUGINS_ENABLED}" "  "
    mrcore_echo_sample "Run '${MRCMD_INFO_NAME} config' for details" "  "
  fi

  for pluginName in "${MRCMD_PLUGINS_AVAILABLE_ARRAY[@]}"
  do
    dirIndex=${MRCMD_PLUGINS_AVAILABLE_DIRS_ARRAY[${i}]}
    pluginsDir="${MRCMD_PLUGINS_DIR_ARRAY[${dirIndex}]}"

    if [[ ${i} -eq 0 ]] && mrcmd_main_is_shared_dir_index ${dirIndex} ; then
      echo -e "${CC_YELLOW}Available shared plugins:${CC_END}"
      echo ""
    fi

    if [[ ${dirIndex} -ne ${dirIndexLast} ]]; then
      echo -e "${CC_YELLOW}Enabled project plugins:${CC_END}"
      echo ""

      dirIndexLast=${dirIndex}
    fi

    manager_available_plugins_echo_plugin "${pluginName}" "${pluginsDir}/${pluginName}" ${dirIndex}

    i=$((i + 1))
  done
}

# private
function manager_available_plugins_echo_plugin() {
  local pluginName=${1:?}
  local pluginDir=${2:?}
  local dirIndex=${3:?}
  local pluginProperties=""
  local pluginStatus="enabled"
  local pluginStatusBlock=""

  if mrcmd_main_is_shared_dir_index ${dirIndex} ; then
    local statusColor="${CC_LIGHT_GREEN}"

    if ! mrcore_lib_in_array "${pluginName}" MRCMD_SHARED_PLUGINS_ENABLED_ARRAY[@] ; then
      pluginStatus="disabled"
      statusColor="${CC_RED}"
    fi

    pluginStatusBlock=" [${statusColor}${pluginStatus}${CC_END}]"
  fi

  if [ -d "${pluginDir}/docker" ]; then
    pluginProperties="${pluginProperties} + ${CC_YELLOW}docker${CC_END}"
  fi

  if [ -f "${pluginDir}/docker-compose.yaml" ]; then
    pluginProperties="${pluginProperties} + ${CC_YELLOW}docker-compose${CC_END}"
  fi

  echo -e "  ${CC_GREEN}${pluginName}${CC_END}${pluginProperties} (in ${CC_BLUE}${pluginDir}${CC_END})${pluginStatusBlock}"

  if [[ "${pluginStatus}" == "enabled" ]]; then
    manager_available_plugins_echo_plugin_methods "${pluginName}"
  else
    echo ""
  fi
}

# private
function manager_available_plugins_echo_plugin_methods() {
  local pluginName=${1:?}
  local pluginMethod
  local fullPluginMethod
  local isAnyMethodExists=false

  echo -e "    ${CC_YELLOW}methods:${CC_END}"

  for pluginMethod in "${MRCMD_AVAILABLE_PLUGIN_METHODS_ARRAY[@]}"
  do
    fullPluginMethod="mrcmd_plugins_${pluginName//[\/-]/_}_method_${pluginMethod//-/_}"

    if mrcore_lib_function_exists "${fullPluginMethod}" ; then
      echo "    - ${fullPluginMethod}()"
      isAnyMethodExists=true
    else
      echo -e "    - ${CC_GRAY}${fullPluginMethod}${CC_END}() [${CC_GRAY}not found${CC_END}]"
    fi
  done

  if [[ "${isAnyMethodExists}" != true ]]; then
    mrcore_echo_error "The ${pluginName} plugin does not have any methods" "      "
  else
    echo ""
  fi
}

