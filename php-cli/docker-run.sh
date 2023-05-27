
# run: mrcmd_plugins_call_function "php-cli/docker-run"
function mrcmd_func_php_cli_docker_run() {
  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${PHP_CLI_DOCKER_IMAGE}" \
    "$@"
}