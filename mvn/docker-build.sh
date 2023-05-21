
# run: mrcmd_plugins_call_function "mvn/docker-build"
function mrcmd_func_mvn_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${MVN_DOCKER_CONFIG_DOCKERFILE}" \
    "${MVN_DOCKER_IMAGE}" \
    "${MVN_DOCKER_IMAGE_FROM}" \
    --build-arg "USER_HOME_DIR=/home/maven" \
    --build-arg "CONFIG_DIR=${MVN_CONFIG_IN_DOCKER_DIR}" \
    "$@"
}
