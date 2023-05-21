
# run: mrcmd_plugins_call_function "java/docker-run"
function mrcmd_func_java_docker_run() {
  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    --env "APP_BIND=${JAVA_WEBAPP_BIND}" \
    --env "APP_PORT=${JAVA_WEBAPP_PORT}" \
    "${JAVA_DOCKER_IMAGE}" \
    "$@"
}
