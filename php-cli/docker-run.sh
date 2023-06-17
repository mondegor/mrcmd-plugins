
# using example: mrcmd_plugins_call_function "php-cli/docker-run"
function mrcmd_func_php_cli_docker_run() {
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${PHP_CLI_DOCKER_IMAGE}" \
    "$@"
}
