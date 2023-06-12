
# run: mrcmd_plugins_call_function "pm/create-func"
function mrcmd_func_pm_create_func() {
  local pluginName="${1-}"
  local funcName="${2-}"
  local pluginDir="${APPX_PLUGINS_DIR}/${pluginName}"
  local templateFile="${MRCMD_CURRENT_PLUGIN_DIR}/templates/function.sh.template"

  mrcore_validate_value_required "Plugin name" "${pluginName}"
  mrcore_validate_value "Plugin name" "${REGEXP_PATTERN_FILE_PREFIX}" "${pluginName}"
  mrcore_validate_value_required "Plugin function name" "${funcName}"
  mrcore_validate_value "Plugin function name" "${REGEXP_PATTERN_FILE_PREFIX}" "${funcName}"
  mrcore_validate_dir_required "Plugin dir" "${pluginDir}"
  mrcore_validate_resource_exists "Plugin function file" "${pluginDir}/${funcName}.sh"
  mrcore_validate_file_required "Plugin function template file" "${templateFile}"

  pm_create_function_exec "${pluginName}" "${funcName}" "${pluginDir}" "${templateFile}"

  mrcore_echo_ok "Function '${funcName}' for plugin '${pluginName}' created"
  mrcore_echo_sample "Run '${MRCMD_INFO_NAME} ${pluginName} ${funcName}' for usage"
}

# private
function pm_create_function_exec() {
  local pluginName="${1:?}"
  local funcName="${2:?}"
  local pluginDir="${3:?}"
  local templateFile="${4:?}"

  export MRVAR_PLUGIN_NAME="${pluginName//[-]/_}"
  export MRVAR_FUNC_NAME="${funcName//[-]/_}"

  local vars="\${MRVAR_PLUGIN_NAME},\${MRVAR_FUNC_NAME}"

  envsubst "${vars}" < "${templateFile}" > "${pluginDir}/${funcName}.sh"
}
