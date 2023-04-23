
# run: mrcmd_plugins_call_function "go/docker-cli"
mrcmd_func_go_docker_cli() {
  mrcore_validate_dir_required "Go lib dir" "${GO_LIB_DIR}"

  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${GO_LIB_DIR}:/go" \
    -v "${GO_WORK_DIR}:/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
