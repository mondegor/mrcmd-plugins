
readonly MRCMD_FUNC_VENDOR_PACKAGE_EXTS_ARRAY=("git" "zip")

function mrcmd_func_vendor_package_get() {
  local packageUrl="${1-}"
  local packageDest="${2-}"
  shift; shift

  mrcore_validate_value_required "Source URL" "${packageUrl}"
  # mrcore_validate_value "Source URL" "${REGEXP_PATTERN_URL}" "${packageUrl}"

  if ! mrcore_lib_in_array "${packageUrl##*.}" MRCMD_FUNC_VENDOR_PACKAGE_EXTS_ARRAY[@]; then
    mrcore_echo_error "Package '${packageUrl}' is not supported. Only packages like: $(mrcmd_lib_implode ", " MRCMD_FUNC_VENDOR_PACKAGE_EXTS_ARRAY[@])"
    ${EXIT_ERROR}
  fi

  local isVendorDir=false

  if [ -n "${packageDest}" ]; then
    if [[ "${packageDest: -1}" == "/" ]]; then
      packageDest=${packageDest%/}
    fi

    if [[ "${packageDest##*/}" == "${packageDest}" ]]; then
      packageDest="${VENDOR_DIR}/${packageDest}"
      isVendorDir=true
    fi
  else
    packageDest=${packageUrl##*/}
    packageDest=${packageDest%.*}

    if [ -z "${packageDest}" ]; then
      mrcore_echo_error "Package '${packageUrl}' is bad"
      ${EXIT_ERROR}
    fi

    packageDest="${VENDOR_DIR}/${packageDest%.*}"
    isVendorDir=true
  fi

  mrcore_validate_resource_exists "Dest path" "${packageDest}"

  if [[ "${isVendorDir}" == true ]]; then
    mrcore_lib_mkdir "${VENDOR_DIR}"
  fi

  mrcmd_func_vendor_package_get_${packageUrl##*.} "${packageUrl}" "${packageDest}" "$@"

  echo -e "Package copied to ${CC_BLUE}${packageDest}${CC_END}"
}

function mrcmd_func_vendor_package_get_git() {
  local packageUrl="${1:?}"
  local packageDest="${2:?}"
  local packageBranch="${3-}"
  local packageCloneDepth="${4-}"

  echo -e "Cloning git package ${CC_YELLOW}'${packageUrl}'${CC_END}"

  # -q, --quiet   This is passed to both underlying git-fetch to squelch reporting of during transfer
  # -b <name>, --branch <name>
  # --depth <depth>
  local flags=""

  if [ -n "${packageBranch}" ]; then
    flags="${flags}${CMD_SEPARATOR}-b${CMD_SEPARATOR}${packageBranch}"
  fi

  if [ -z "${packageCloneDepth}" ]; then
    packageCloneDepth=${VENDOR_GIT_CLONE_DEPTH}
  fi

  if [[ "${packageCloneDepth}" -gt 0 ]]; then
    flags="${flags}${CMD_SEPARATOR}--depth${CMD_SEPARATOR}${packageCloneDepth}"
  fi

  if [[ "${VENDOR_SILENT_MODE}" == true ]]; then
    flags="${flags}${CMD_SEPARATOR}--quiet"
  fi

  git clone ${flags} "${packageUrl}" "${packageDest}"

  if [ ! -d "${packageDest}/.git" ]; then
    mrcore_echo_error "Git package '${packageUrl}' not cloned"
    ${EXIT_ERROR}
  fi
}

function mrcmd_func_vendor_package_get_zip() {
  local packageUrl="${1:?}"
  local packageDest="${2:?}"

  local packageDestTmp="${packageDest}_tmp"
  local packageDestZip="${packageDest}_tmp/vendor.zip"

  mrcore_validate_resource_exists "Dest tmp path" "${packageDestTmp}"
  mkdir -m 0755 "${packageDestTmp}"

  echo -e "Downloads package ${CC_YELLOW}'${packageUrl}'${CC_END}"

  # -k, --insecure     Allow insecure server connections when using SSL
  # -L, --location     Follow redirects
  # -s, --silent       Silent mode
  # -S, --show-error   Show error even when -s is used
  local flags="-L"

  if [[ "${VENDOR_SILENT_MODE}" == true ]]; then
    flags="${flags}${CMD_SEPARATOR}--silent${CMD_SEPARATOR}-S"
  fi

  curl ${flags} -o "${packageDestZip}" "${packageUrl}"

  if [ ! -f "${packageDestZip}" ]; then
    mrcore_echo_error "Package '${packageUrl}' not downloaded"
    rmdir -R "${packageDestTmp}"
    ${EXIT_ERROR}
  fi

  unzip -q "${packageDestZip}" -d "${packageDestTmp}"
  rm "${packageDestZip}"

  if [[ "$(ls "${packageDestTmp}" | wc -l)" -eq 1 ]]; then
    mv "${packageDestTmp}/$(ls "${packageDestTmp}")" "${packageDest}"
    rmdir "${packageDestTmp}"
  else
    mv "${packageDestTmp}/" "${packageDest}"
  fi
}
