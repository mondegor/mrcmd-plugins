
# using example: mrcmd_plugins_call_function "java/docker-run"
function mrcmd_func_java_docker_run() {
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    --env-file "$(mrcmd_os_realpath "${JAVA_APPX_ENV_FILE}")" \
    "${JAVA_DOCKER_IMAGE}" \
    "$@"
}
