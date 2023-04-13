
docker_golang_alpine_before_build() {
  DOCKER_BUILD_PARAMS_RESULT="--build-arg ALPINE_INSTALL_BASH=${ALPINE_INSTALL_BASH:-false}
                              --build-arg HOST_USER_ID=${HOST_USER_ID:-0}
                              --build-arg HOST_GROUP_ID=${HOST_GROUP_ID:-0}"
}
