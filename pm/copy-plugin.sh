
# run: mrcmd_plugins_call_function "pl/copy-plugin"
function mrcmd_func_pm_copy_plugin() {
  local sourcePluginName="${1-}"
  local destPluginName="${2-}"
  local sourcePluginDir
  local destPluginDir="${APPX_PLUGINS_DIR}/${destPluginName}"

  mrcore_validate_value_required "Source plugin name" "${sourcePluginName}"
  sourcePluginDir=$(pm_copy_plugin_get_plugin_dir "${sourcePluginName}")

  if [ ! -d "${sourcePluginDir}" ]; then
    mrcore_echo_error "Dir '${sourcePluginName}' not found"
    ${EXIT_ERROR}
  fi

  mrcore_validate_value_required "Dest plugin name" "${destPluginName}"
  mrcore_validate_value "Dest plugin name" "${REGEXP_PATTERN_FILE_PREFIX}" "${destPluginName}"

  if mrcore_lib_in_array "${destPluginDir}" MRCMD_PLUGINS_AVAILABLE_ARRAY[@] ; then
    mrcore_echo_error "Plugin '${destPluginDir}' already exists"
    ${EXIT_ERROR}
  fi

  mrcore_validate_resource_exists "Dest plugin dir" "${destPluginDir}"

  pm_copy_plugin_copy "${sourcePluginName}" "${destPluginName}" "${sourcePluginDir}" "${destPluginDir}"
  pm_copy_plugin_rename "${sourcePluginName}" "${destPluginName}" "${destPluginDir}"

  mrcore_echo_ok "Plugin '${destPluginName}' copied from '${sourcePluginName}'"
  mrcore_echo_sample "Run '${MRCMD_INFO_NAME} help ${destPluginName}' for usage"
}

# private
function pm_copy_plugin_copy() {
  local sourcePluginName="${1:?}"
  local destPluginName="${2:?}"
  local sourcePluginDir="${3:?}"
  local destPluginDir="${4:?}"

  cp -R "${sourcePluginDir}" "${destPluginDir}"
  mv "${destPluginDir}/${sourcePluginName}.sh" "${destPluginDir}/${destPluginName}.sh"
}

# private
function pm_copy_plugin_rename() {
  local sourcePluginName="${1:?}"
  local destPluginName="${2:?}"
  local pluginDir="${3:?}"

  echo "${sourcePluginName} -> ${destPluginName} from ${pluginDir}"
}

# private
function pm_copy_plugin_get_plugin_dir() {
  local searchPluginName="${1:?}"
  local pluginName
  local i=0

  for pluginName in "${MRCMD_PLUGINS_AVAILABLE_ARRAY[@]}"
  do
    if [[ "${pluginName}" == "${searchPluginName}" ]]; then
      local dirIndex=${MRCMD_PLUGINS_AVAILABLE_DIRS_ARRAY[${i}]}
      echo "${MRCMD_PLUGINS_DIR_ARRAY[${dirIndex}]}/${pluginName}"
      return
    fi

    i=$((i + 1))
  done

  echo ""
}
