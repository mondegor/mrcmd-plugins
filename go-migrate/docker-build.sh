
# run: mrcmd_plugins_call_function "go-migrate/docker-build"
mrcmd_func_go_migrate_docker_build() {
  local dockerFilePath="${GO_MIGRATE_DOCKER_CONFIG_DIR}"
  local dockerImageName="${GO_MIGRATE_DOCKER_IMAGE}"
  local dockerImageFrom="${GO_MIGRATE_DOCKER_IMAGE_FROM}"
  shift; shift; shift

  # --progress plain
  # --no-cache
  docker build "${dockerFilePath}" -t "${dockerImageName}" \
    --build-arg "DOCKER_IMAGE=${dockerImageFrom}" \
    --build-arg "HOST_USER_ID=${GO_MIGRATE_HOST_USER_ID}" \
    --build-arg "HOST_GROUP_ID=${GO_MIGRATE_HOST_GROUP_ID}" "$@"
}
