
# using example: mrcmd_plugins_call_function "docker/build-image-user"
function mrcmd_func_docker_build_image_user() {
  local dockerContextDir="${1:?}"
  local dockerFilePath="${2?}"
  local dockerImageName="${3:?}"
  local dockerImageFrom="${4:?}"
  shift; shift; shift; shift

  mrcmd_plugins_call_function "docker/build-image" \
    "${dockerContextDir}" \
    "${dockerFilePath}" \
    "${dockerImageName}" \
    "${dockerImageFrom}" \
    --build-arg "HOST_USER_ID=${HOST_USER_ID}" \
    --build-arg "HOST_GROUP_ID=${HOST_GROUP_ID}" \
    "$@"
}
