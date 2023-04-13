
# run: mrcmd_plugins_call_function "go/docker-run"
mrcmd_func_go_docker_run_install() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    -v ${GO_LIB_DIR}:/go \
    -v "${GO_APP_VOLUME}:/opt/app" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
