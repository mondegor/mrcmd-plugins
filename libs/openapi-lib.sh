
function openapi_lib_build_apidoc() {
  local functionName="${1:?}"
  local srcDir="${2:?}"
  local sharedDir="${3:?}"
  local assemblyDir="${4:?}"
  local sectionName="${5:?}"
  local fileNamePrefix="${6:-}"
  local fileNamePostfix="${7:-}"

  mrcore_validate_dir_required "OpenAPI source dir" "${srcDir}"

  if [ -z "${fileNamePostfix}" ]; then
    fileNamePostfix="full"
  fi

  openapi_lib_build_apidoc_file \
    "${functionName}" \
    "${srcDir}/${sectionName}" \
    "${sharedDir}" \
    "${assemblyDir}" \
    "${sectionName}/${fileNamePrefix}${fileNamePostfix}.yaml"
}

function openapi_lib_build_apidoc_file() {
  local functionName="${1:?}"
  local sectionDir="${2:?}"
  local sharedDir="${3:?}"
  local assemblyDir="${4:?}"
  local destFilePath="${5:?}"

  mrcore_validate_dir_required "OpenAPI section dir" "${sectionDir}"
  mrcore_validate_dir_required "OpenAPI shared dir" "${sharedDir}"
  mrcore_validate_dir_required "OpenAPI assembly dir" "${assemblyDir}"

  OPENAPI_VERSION="3.0.3"
  OPENAPI_HEADERS=()
  OPENAPI_SERVERS=()
  OPENAPI_TAGS=()
  OPENAPI_PATHS=()
  OPENAPI_COMPONENTS_HEADERS=()
  OPENAPI_COMPONENTS_PARAMETERS=()
  OPENAPI_COMPONENTS_SCHEMAS=()
  OPENAPI_COMPONENTS_RESPONSES=()
  OPENAPI_SECURITY_SCHEMES=()

  mrcore_lib_mkdir "$(dirname "${assemblyDir}/${destFilePath}")"
  mrcmd_plugins_call_function "${functionName}" "${sectionDir}" "${sharedDir}"

  openapi_lib_render_apidoc_file \
    "${functionName}" \
    "${assemblyDir}/${destFilePath}" \
    "${OPENAPI_VERSION}" \
    OPENAPI_HEADERS[@] \
    OPENAPI_SERVERS[@] \
    OPENAPI_TAGS[@] \
    OPENAPI_PATHS[@] \
    OPENAPI_COMPONENTS_HEADERS[@] \
    OPENAPI_COMPONENTS_PARAMETERS[@] \
    OPENAPI_COMPONENTS_SCHEMAS[@] \
    OPENAPI_COMPONENTS_RESPONSES[@] \
    OPENAPI_SECURITY_SCHEMES[@]
}

function openapi_lib_render_apidoc_file() {
  local functionName="${1:?}"
  local destFilePath="${2:?}"
  local openapiVersion="${3:?}"
  local headers=("${!4-}")
  local servers=("${!5-}")
  local tags=("${!6-}")
  local paths=("${!7-}")
  local componentsHeaders=("${!8-}")
  local componentsParameters=("${!9-}")
  local componentsSchemas=("${!10-}")
  local componentsResponses=("${!11-}")
  local securitySchemes=("${!12-}")

  mrcore_echo_sample "Run: ${functionName}.sh -> ${destFilePath}"

  echo -e "---\nopenapi: ${openapiVersion}\ninfo:" > "${destFilePath}"

  if ! mrcore_lib_is_array_empty headers[@] ; then
    openapi_lib_render_file_list headers[@] "${destFilePath}" 2;
  fi

  if ! mrcore_lib_is_array_empty servers[@] ; then
    echo -e "\nservers:" >> "${destFilePath}"
    openapi_lib_render_file_list servers[@] "${destFilePath}" 2;
  fi

  if ! mrcore_lib_is_array_empty tags[@] ; then
    echo -e "\ntags:" >> "${destFilePath}"
    openapi_lib_render_file_list tags[@] "${destFilePath}" 2;
  fi

  if ! mrcore_lib_is_array_empty paths[@] ; then
    echo -e "\n\npaths:" >> "${destFilePath}"
    openapi_lib_render_file_list paths[@] "${destFilePath}" 2;
  fi

  echo -e "\n\ncomponents:" >> "${destFilePath}"

  if ! mrcore_lib_is_array_empty componentsHeaders[@] ; then
    echo -e "\n  headers:" >> "${destFilePath}"
    openapi_lib_render_file_list componentsHeaders[@] "${destFilePath}" 4;
  fi

  if ! mrcore_lib_is_array_empty componentsParameters[@] ; then
    echo -e "\n  parameters:" >> "${destFilePath}"
    openapi_lib_render_file_list componentsParameters[@] "${destFilePath}" 4;
  fi

  if ! mrcore_lib_is_array_empty componentsSchemas[@] ; then
    echo -e "\n\n  schemas:" >> "${destFilePath}"
    openapi_lib_render_file_list componentsSchemas[@] "${destFilePath}" 4;
  fi

  if ! mrcore_lib_is_array_empty componentsResponses[@] ; then
    echo -e "\n\n  responses:" >> "${destFilePath}"
    openapi_lib_render_file_list componentsResponses[@] "${destFilePath}" 4;
  fi

  if ! mrcore_lib_is_array_empty securitySchemes[@] ; then
    echo -e "\n\n  securitySchemes:" >> "${destFilePath}"
    openapi_lib_render_file_list securitySchemes[@] "${destFilePath}" 4;
  fi

  openapi_lib_remove_spaces "${destFilePath}"

  mrcore_echo_ok "File ${destFilePath} created"
}

function openapi_lib_render_file_list() {
  local array=("${!1-}")
  local destFilePath="${2:?}"
  local indent=${3}
  local curDir
  local i=0

  for curPath in "${array[@]}"
  do
    mrcore_validate_file_required "File" "${curPath}"

    if [ ${i} -gt 0 ]; then
      echo -e "\n" >> "${destFilePath}"
    fi

    openapi_lib_add_string_to_end_file "${curPath}" "${destFilePath}" ${indent}

    i=$((i + 1))
  done
}

function openapi_lib_add_string_to_end_file() {
  local sourceFilePath=${1:?}
  local destFilePath=${2:?}
  local indent=${3}

  mrcore_validate_file_required "${FUNCNAME[0]}::FROM" "${sourceFilePath}"
  mrcore_validate_file_required "${FUNCNAME[0]}::TO" "${destFilePath}"

  if [[ ${indent} -ge 1 ]]; then
    local indentStr
    local tmpFilePath

    indentStr=$(mrcore_lib_repeat_string " " ${indent})
    tmpFilePath="./$(date +%s%N | xargs printf %x)"

    if ! cat "${sourceFilePath}" >"${tmpFilePath}" ||
      ! sed -i "s/^/${indentStr}/" "${tmpFilePath}" ||
      ! cat "${tmpFilePath}" >>"${destFilePath}" ||
      ! rm "${tmpFilePath}"; then
      ${EXIT_ERROR}
    fi
  else
    if ! cat "${sourceFilePath}" >"${destFilePath}"; then
      ${EXIT_ERROR}
    fi
  fi
}

function openapi_lib_remove_spaces() {
  local destFilePath=${1:?}

  sed -i 's/[[:space:]]*$//' "${destFilePath}"
  sed -i '/^$/N;/\n$/D' "${destFilePath}"
}
