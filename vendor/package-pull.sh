
function mrcmd_func_vendor_package_pull() {
  local packagePath="${1-}"

  mrcore_validate_value_required "Package name" "${packagePath}"

  if [[ "${packagePath}" == "${packagePath##*/}" ]]; then
    packagePath="${VENDOR_DIR}/${packagePath}"
  fi

  mrcore_validate_dir_required "Package" "${packagePath}"
  mrcore_validate_dir_required "Package .git" "${packagePath}/.git"

  # -q, --quiet   This is passed to both underlying git-fetch to squelch reporting of during transfer
  local flags=""

  if [[ "${VENDOR_SILENT_MODE}" == true ]]; then
    flags="${flags}${CMD_SEPARATOR}--quiet"
  fi

  git -C "${packagePath}" pull ${flags}

  echo -e "Git package ${CC_BLUE}${packagePath}${CC_END} pulled"
}
