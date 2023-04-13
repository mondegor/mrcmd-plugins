
# run: mrcmd_plugins_call_function "docker/wrapper-build-image"
mrcmd_func_docker_wrapper_build_image() {
  local dockerFilePath=${1:?}
  local dockerImageName=${2:?}
  local dockerImageFrom=${3:?}
  shift; shift; shift

  local beforeBuildFunc="${dockerFilePath}/before-build"

  DOCKER_BUILD_PARAMS_RESULT=""

  echo -e "${CC_YELLOW}DOCKER FILE PATH:${CC_END} ${CC_GREEN}${dockerFilePath}${CC_END}"
  echo -e "${CC_YELLOW}BUILD IMAGE:${CC_END} ${CC_GREEN}${dockerImageName}${CC_END} ${CC_YELLOW}FROM:${CC_END} ${CC_GREEN}${dockerImageFrom}${CC_END}"

  mrcmd_plugins_call_function "${beforeBuildFunc}" "$@"

  mrcmd_plugins_call_function build-image \
    "${dockerFilePath}" \
    "${dockerImageName}" \
    "${dockerImageFrom}" \
    ${DOCKER_BUILD_PARAMS_RESULT} # :WARNING: it must be without quotes!!!
}
