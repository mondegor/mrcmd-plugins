
# run: mrcmd_plugins_call_function "java/docker-run"
function mrcmd_func_java_docker_run() {
  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    --env "APPX_SERVICE_BIND=${JAVA_WEBAPP_BIND}" \
    --env "APPX_SERVICE_PORT=${JAVA_WEBAPP_PORT}" \
    "${JAVA_DOCKER_IMAGE}" \
    "$@"
}
