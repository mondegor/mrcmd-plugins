
# run: mrcmd_plugins_call_function "go/download-tools"
function mrcmd_func_go_download_tools() {
  local toolsArray=("${!1}")

  local value
  local tool
  local i=0

  for value in "${toolsArray[@]}"
  do
    if [ $((i % 2)) -eq 0 ]; then
      tool="${value}"
    else
      if [ -n "${value}" ] && [[ "${value}" != false ]]; then
        echo -e "Installing tool ${CC_GREEN}'${tool}@${value}'${CC_END}"

        mrcmd_plugins_call_function "go/docker-cli" \
          go \
          install \
          "${tool}@${value}"
      fi
    fi

    i=$((i + 1))
  done
}
