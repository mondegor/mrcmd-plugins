
# run: mrcmd_plugins_call_function "nodejs/docker-build"
mrcmd_func_nodejs_docker_build() {
  local dockerFilePath="${NODEJS_DOCKER_CONFIG_DIR}"
  local dockerImageName="${NODEJS_DOCKER_IMAGE}"
  local dockerImageFrom="${NODEJS_DOCKER_IMAGE_FROM}"
  shift; shift; shift

  # --progress plain
  # --no-cache
  docker build "${dockerFilePath}" -t "${dockerImageName}" \
    --build-arg "DOCKER_IMAGE=${dockerImageFrom}" \
    --build-arg "INSTALL_BASH=${NODEJS_INSTALL_BASH}" \
    --build-arg "HOST_USER_ID=${NODEJS_HOST_USER_ID}" \
    --build-arg "HOST_GROUP_ID=${NODEJS_HOST_GROUP_ID}" "$@"
}
