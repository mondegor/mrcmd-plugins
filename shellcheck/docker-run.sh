
# using example: mrcmd_plugins_call_function "shellcheck/docker-run"
function mrcmd_func_shellcheck_docker_run() {
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/mnt" \
    "${SHELLCHECK_DOCKER_IMAGE}" "$@"
}
