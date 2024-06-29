
# using example: mrcmd_plugins_call_function "golangci_lint/docker-run"
function mrcmd_func_golangci_lint_docker_run() {
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -t \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${GOLANGCI_GOPATH_DIR}"):/go" \
    -v "$(mrcmd_os_realpath "${GOLANGCI_LINT_CACHE_DIR}"):/root/.cache" \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/app" \
    "${GOLANGCI_LINT_DOCKER_IMAGE}" "$@"
}
