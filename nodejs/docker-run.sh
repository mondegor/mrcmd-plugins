
# run: mrcmd_plugins_call_function "nodejs/docker-run"
function mrcmd_func_nodejs_docker_run() {
  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${NODEJS_DOCKER_IMAGE}" \
    "$@"
}
