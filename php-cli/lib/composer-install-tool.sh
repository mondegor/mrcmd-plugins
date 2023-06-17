
# using example: mrcmd_plugins_call_function "php-cli/lib/composer-install-tools"
function mrcmd_func_php_cli_lib_composer_install_tool() {
  local toolName="${1:?}"
  local version="${2:?}"

  echo "Installs tool: ${toolName}@${version}"

  mrcmd_plugins_call_function "php-cli/docker-run" \
    composer \
    require \
    --dev \
    "${toolName}:${version}"
}
