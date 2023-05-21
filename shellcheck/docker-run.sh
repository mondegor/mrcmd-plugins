
# run: mrcmd_plugins_call_function "shellcheck/docker-run"
function mrcmd_func_shellcheck_docker_run() {
  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${APPX_WORK_DIR}"):/mnt" \
    "${SHELLCHECK_DOCKER_IMAGE}" "$@"
}
