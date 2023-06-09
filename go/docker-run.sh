
# using example: mrcmd_plugins_call_function "go/docker-run"
function mrcmd_func_go_docker_run() {
  mrcore_validate_dir_required "Go lib dir" "${GO_LIB_DIR}"
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${GO_LIB_DIR}"):/go" \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    --env "APPX_SERVICE_BIND=${GO_WEBAPP_BIND}" \
    --env "APPX_SERVICE_PORT=${GO_WEBAPP_PORT}" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
