
# run: mrcmd_plugins_call_function "docker/build-image-user"
function mrcmd_func_docker_build_image_user() {
  local dockerFilePath="${1:?}"
  local dockerImageName="${2:?}"
  local dockerImageFrom="${3:?}"
  shift; shift; shift

  mrcmd_plugins_call_function "docker/build-image" \
    "${dockerFilePath}" \
    "${dockerImageName}" \
    "${dockerImageFrom}" \
    --build-arg "HOST_USER_ID=${HOST_USER_ID}" \
    --build-arg "HOST_GROUP_ID=${HOST_GROUP_ID}" \
    "$@"
}
