
# using example: mrcmd_plugins_call_function "php-cli/lib/phive-install-tools"
function mrcmd_func_php_cli_lib_phive_install_tool() {
  local toolName="${1:?}"
  local version="${2:?}"
  local gpgKey="${3:?}"

  echo "Installs tool: ${toolName}@${version}; gpg key: ${gpgKey}"

  mrcmd_plugins_call_function "php-cli/docker-run" \
    phive \
    install \
    --copy \
    --target vendor/bin \
    --trust-gpg-keys "${gpgKey}" \
    "${toolName}@${version}"
}
