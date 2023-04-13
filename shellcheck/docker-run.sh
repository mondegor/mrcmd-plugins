
# run: mrcmd_plugins_call_function "shellcheck/docker-run"
mrcmd_func_shellcheck_docker_run() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${SHELLCHECK_APP_VOLUME}:/mnt" \
    "${SHELLCHECK_DOCKER_IMAGE}" "$@"
}