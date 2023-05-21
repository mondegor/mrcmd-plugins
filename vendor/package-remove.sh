
function mrcmd_func_vendor_package_remove() {
  local packagePath="${1-}"

  mrcore_validate_value_required "Package for remove" "${packagePath}"

  if [[ "${packagePath}" == "${packagePath##*/}" ]]; then
    packagePath="${VENDOR_DIR}/${packagePath}"
  fi

  mrcore_validate_resource_required "Package for remove" "${packagePath}"

  mrcore_lib_rm_resource "${packagePath}"
}
