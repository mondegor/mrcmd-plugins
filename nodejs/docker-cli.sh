
# run: mrcmd_plugins_call_function "nodejs/docker-cli"
mrcmd_func_nodejs_docker_cli() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${NODEJS_APPX_APP_DIR}:/opt/app" \
    --env "TZ=${APPX_TZ}" \
    "${NODEJS_DOCKER_IMAGE}" \
    "$@"
}
