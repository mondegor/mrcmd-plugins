
# using example: mrcmd_plugins_call_function "pandoc/docker-run"
function mrcmd_func_pandoc_docker_run() {
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/data" \
    --env "TZ=${APPX_TZ}" \
    "${PANDOC_DOCKER_IMAGE}" \
    "$@"
}
