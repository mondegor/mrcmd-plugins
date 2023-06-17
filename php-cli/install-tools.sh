
# using example: mrcmd_plugins_call_function "php-cli/install-tools"
function mrcmd_func_php_cli_install_tools() {
  local toolsArray=("${!1}")
  mrcmd_func_php_cli_each_tool_install "${toolsArray[@]}"
}

# private
function mrcmd_func_php_cli_each_tool_install() {
  local toolName="${1:?}"
  local toolNameComposer="${2?}"
  local version="${3:?}"
  local gpgKey="${4:?}"
  shift; shift; shift; shift

  mrcmd_func_php_cli_tool_echo_caption "${toolName}" "${version}" "${gpgKey}"

  if [[ "${version}" != false ]]; then
    mrcmd_func_php_cli_${PHP_CLI_TOOLS_INSTALL_BASE}_install_tool \
      "${toolName}" \
      "${toolNameComposer}" \
      "${version}" \
      "${gpgKey}"
  fi

  if [ -n "${1-}" ]; then
    mrcmd_func_php_cli_each_tool_install "$@"
  fi
}

# private
function mrcmd_func_php_cli_tool_echo_caption() {
  toolName="${1:?}"
  version="${2:?}"
  gpgKey="${3:?}"

  echo "Tool: ${toolName}@${version}; gpg key: ${gpgKey}"
}

# private
function mrcmd_func_php_cli_phive_install_tool() {
  local toolName="${1:?}"
  local toolNameComposer="${2?}"
  local version="${3:?}"
  local gpgKey="${4:?}"

  mrcmd_plugins_call_function "php-cli/lib/phive-install-tool" \
    "${toolName}" \
    "${version}" \
    "${gpgKey}"
}

# private
function mrcmd_func_php_cli_composer_install_tool() {
  local toolName="${1:?}"
  local toolNameComposer="${2?}"
  local version="${3:?}"
  local gpgKey="${4:?}"

  if [ -z "${toolNameComposer}" ]; then
    return
  fi

  mrcmd_plugins_call_function "php-cli/lib/composer-install-tool" \
    "${toolNameComposer}" \
    "${version}"
}
