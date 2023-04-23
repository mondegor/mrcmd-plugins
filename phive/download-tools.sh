
# run: mrcmd_plugins_call_function "web-php/download-tools"
function mrcmd_func_phive_download_tools() {
  local toolsArray=("${!1}")

  local value
  local version
  local tool
  local i=0

  for value in "${toolsArray[@]}"
  do
    if [ $((i % 3)) -eq 0 ]; then
      tool="${value}"
    elif [ $((i % 3)) -eq 1 ]; then
      version="${value}"
    else
      if [ -n "${version}" ] && [[ "${version}" != false ]]; then
        echo "Phive tool: ${tool}@${version}; key: ${value}"

        mrcmd_plugins_call_function "phive/docker-cli" \
          install \
          --copy \
          --trust-gpg-keys "${value}" \
          "${tool}@${version}"
      fi
    fi

    i=$((i + 1))
  done
}
