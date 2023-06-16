
# run: mrcmd_plugins_call_function "docker/build-image"
function mrcmd_func_docker_build_image() {
  local dockerContextDir="${1:?}"
  local dockerFilePath="${2?}"
  local dockerImageName="${3:?}"
  local dockerImageFrom="${4:?}"
  shift; shift; shift; shift

  mrcmd_plugins_docker_validate_daemon_required

  if [ -n "${dockerFilePath}" ]; then
    dockerFilePath="-f${CMD_SEPARATOR}${dockerFilePath}"
  fi

  # --progress=plain \
  docker build "${dockerContextDir}" ${dockerFilePath} -t "${dockerImageName}" \
    --build-arg "DOCKER_IMAGE_FROM=${dockerImageFrom}" \
    --build-arg "DEFAULT_SHELL=${DOCKER_DEFAULT_SHELL}" \
    "$@"
}
