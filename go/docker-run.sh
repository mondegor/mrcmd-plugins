
# using example: mrcmd_plugins_call_function "go/docker-run"
function mrcmd_func_go_docker_run() {
  mrcore_validate_dir_required "GOPATH dir" "${GO_GOPATH_DIR}"
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  # 999 - $(getent group docker | cut -d ':' -f 3)
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    --group-add 999 \
    -v "$(mrcmd_os_realpath "${GO_GOPATH_DIR}"):/go" \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    --env "TZ=${APPX_TZ}" \
    --env-file "$(mrcmd_os_realpath "${GO_APPX_ENV_FILE}")" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
