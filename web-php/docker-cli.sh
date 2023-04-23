
# run: mrcmd_plugins_call_function "web-php/docker-cli"
mrcmd_func_web_php_docker_cli() {
  local mountTools=""

  if [ -n "${WEB_PHP_APPX_TOOLS_DIR}" ]; then
    mrcore_validate_dir_required "Tools dir" "${WEB_PHP_APPX_TOOLS_DIR}"
    mountTools="-v${CMD_SEPARATOR}${WEB_PHP_APPX_TOOLS_DIR}:/usr/bin-tools"
  fi

  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    ${mountTools} \
    -v "${WEB_PHP_WORK_DIR}:/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${WEB_PHP_CLI_DOCKER_IMAGE}" \
    "$@"
}
