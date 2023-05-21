
# run: mrcmd_plugins_call_function "go-dev/install-tools"
function mrcmd_func_go_dev_install_tools() {
  local toolsArray=("${!1}")
  mrcmd_func_go_dev_each_tool_install "${toolsArray[@]}"
}

# private
function mrcmd_func_go_dev_each_tool_install() {
  local toolName="${1:?}"
  local version="${2:?}"
  shift; shift

  if [[ "${version}" != false ]]; then
    echo "Installs tool: ${toolName}@${version}"
    go install "${toolName}@${version}"
  fi

  if [ -n "${1-}" ]; then
    mrcmd_func_go_dev_each_tool_install "$@"
  fi
}
