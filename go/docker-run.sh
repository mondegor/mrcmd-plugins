
# run: mrcmd_plugins_call_function "go/docker-run"
function mrcmd_func_go_docker_run() {
  mrcore_validate_dir_required "Go lib dir" "${GO_LIB_DIR}"

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${GO_LIB_DIR}"):/go" \
    -v "$(realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    --env "APP_BIND=${GO_WEBAPP_BIND}" \
    --env "APP_PORT=${GO_WEBAPP_PORT}" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
