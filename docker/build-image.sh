
# run: mrcmd_plugins_call_function "docker/build-image"
mrcmd_func_docker_build_image() {
  local dockerFilePath=${1:?}
  local dockerImageName=${2:?}
  local dockerImageFrom=${3:?}
  shift; shift; shift

  docker build ${dockerFilePath} -t ${dockerImageName} \
    --build-arg DOCKER_IMAGE=${dockerImageFrom} "$@"
}
