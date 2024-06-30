
readonly MRCMD_PLUGIN_RESERVED_METHODS_ARRAY=(
    "init"
    "${MRCMD_PLUGIN_METHOD_EXECUTE}"
    "${MRCMD_PLUGIN_METHOD_CAN_EXECUTE}"
    "${MRCMD_PLUGIN_METHODS_ARRAY[@]}"
  )

# using example: mrcmd_plugins_call_function "pm/available-plugins"
function mrcmd_func_pm_available_plugins() {
  local isShowMethods=${1:-false}
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

    if [[ ${i} -eq 0 ]] && [[ ${MRCMD_PLUGINS_DIR_INDEX_SHARED} -eq ${dirIndex} ]]; then
      echo -e "${CC_YELLOW}Available shared plugins:${CC_END}"
      echo ""
    fi

    if [[ ${dirIndex} -ne ${dirIndexLast} ]]; then
      echo -e "${CC_YELLOW}Enabled project plugins:${CC_END}"
      echo ""

      dirIndexLast=${dirIndex}
    fi

    pm_available_plugins_echo_plugin "${pluginName}" "${pluginsDir}/${pluginName}" ${dirIndex} "${isShowMethods}"

    i=$((i + 1))
  done
}

# private
function pm_available_plugins_echo_plugin() {
  local pluginName="${1:?}"
  local pluginDir="${2:?}"
  local dirIndex=${3:?}
  local isShowMethods=${4:?}
  local pluginProperties=""
  local pluginStatus="enabled"
  local statusColor="${CC_LIGHT_GREEN}"

  if [[ ${MRCMD_PLUGINS_DIR_INDEX_SHARED} -eq ${dirIndex} ]] &&
     ! mrcore_lib_in_array "${pluginName}" MRCMD_SHARED_PLUGINS_ENABLED_ARRAY[@] ; then
    pluginStatus="disabled"
    statusColor="${CC_RED}"
  fi

  if [[ "${pluginStatus}" == "enabled" ]] &&
     ! mrcore_lib_in_array "${pluginName}" MRCMD_PLUGINS_LOADED_ARRAY[@] ; then
    mrcmd_plugins_depends_plugin_load_depends "${pluginName}"
    mrcmd_plugins_depends_plugin_clean_depends

    pluginStatus="required: $(mrcmd_lib_implode ", " MRCMD_PLUGIN_DEPENDS_ARRAY[@])"
    statusColor="${CC_RED}"
  fi

  local pluginSupported=()

  if [ -d "${pluginDir}/docker" ]; then
    pluginSupported+=("docker")
  fi

  if [ -d "${pluginDir}/docker-compose" ]; then
    pluginSupported+=("docker-compose")
  fi

  echo -e "    ${CC_GREEN}${pluginName}${CC_END}${pluginProperties} [${statusColor}${pluginStatus}${CC_END}]"

  if [[ "${#pluginSupported[@]}" -gt 0 ]]; then
    echo -e "      ${CC_YELLOW}supported:${CC_END} $(mrcmd_lib_implode ", " pluginSupported[@])"
  fi

  mrcmd_plugins_depends_plugin_load_depends "${pluginName}"

  if [[ "${#MRCMD_PLUGIN_DEPENDS_ARRAY[@]}" -gt 0 ]]; then
    echo -e "      ${CC_YELLOW}depends:${CC_END} ${CC_GREEN}$(mrcmd_lib_implode ", " MRCMD_PLUGIN_DEPENDS_ARRAY[@])${CC_END}"
  fi

  echo -e "      ${CC_YELLOW}path:${CC_END} ${CC_BLUE}${pluginDir}${CC_END}"

  if [[ "${isShowMethods}" == true ]] && [[ "${pluginStatus}" == "enabled" ]]; then
    pm_available_plugins_echo_plugin_methods "${pluginName}"
  else
    echo ""
  fi

  echo "======================================================================="
  echo ""
}

# private
function pm_available_plugins_echo_plugin_methods() {
  local pluginName="${1:?}"
  local pluginMethod
  local fullPluginMethod
  local isAnyMethodExists=false

  echo -e "      ${CC_YELLOW}methods:${CC_END}"

  for pluginMethod in "${MRCMD_PLUGIN_RESERVED_METHODS_ARRAY[@]}"
  do
    fullPluginMethod=$(mrcmd_plugins_lib_get_plugin_method_name "${pluginName}" "${pluginMethod}")

    if mrcore_lib_func_exists "${fullPluginMethod}" ; then
      echo "      - ${fullPluginMethod}()"
      isAnyMethodExists=true
    else
      echo -e "      - ${CC_GRAY}${fullPluginMethod}${CC_END}() [${CC_GRAY}not found${CC_END}]"
    fi
  done

  if [[ "${isAnyMethodExists}" == true ]]; then
    echo ""
  else
    mrcore_echo_error "Plugin '${pluginName}' doesn't have any methods" "      "
  fi
}

