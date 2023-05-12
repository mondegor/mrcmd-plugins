
# run: mrcmd_plugins_call_function "pm/create-plugin"
function mrcmd_func_pm_create_plugin() {
  local pluginName="${1-}"
  local funcName="first-function"
  local pluginDir="${APPX_PLUGINS_DIR}/${pluginName}"
  local templateFile="${MRCMD_CURRENT_PLUGINS_DIR}/${MRCMD_CURRENT_PLUGIN_NAME}/templates/plugin.sh.template"

  mrcore_validate_value_required "Plugin name" "${pluginName}"
  mrcore_validate_value "Plugin name" "${REGEXP_PATTERN_FILE_PREFIX}" "${pluginName}"
  mrcore_validate_resource_exists "Plugin dir" "${pluginDir}"
  mrcore_validate_file_required "Plugin template file" "${templateFile}"

  pm_create_plugin_exec "${pluginName}" "${funcName}" "${pluginDir}" "${templateFile}"

  mrcore_echo_ok "Plugin '${pluginName}' created"
  mrcore_echo_sample "Run '${MRCMD_INFO_NAME} ${pluginName}' for usage"

  mrcmd_plugins_call_function "pm/create-func" "${pluginName}" "${funcName}"
}

# private
function pm_create_plugin_exec() {
  local pluginName="${1:?}"
  local funcName="${2:?}"
  local pluginDir="${3:?}"
  local templateFile="${4:?}"

  mkdir -m 0755 "${pluginDir}"

  export MRVAR_PLUGIN_FILE="${pluginName}"
  export MRVAR_PLUGIN_NAME="${pluginName//[-]/_}"
  export MRVAR_PLUGIN_NAME_UPPER="${MRVAR_PLUGIN_NAME^^}"
  export MRVAR_FUNC_FILE="${funcName}"

  local vars="\${MRVAR_PLUGIN_NAME},\${MRVAR_PLUGIN_NAME_UPPER},\${MRVAR_PLUGIN_FILE},\$MRVAR_FUNC_FILE"

  envsubst "${vars}" < "${templateFile}" > "${pluginDir}/${pluginName}.sh"
}
