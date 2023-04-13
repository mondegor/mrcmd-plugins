
# run: mrcmd_plugins_call_function "go/docker-run"
mrcmd_func_go_docker_run() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    --env "TZ=${GO_TZ}" \
    --env "APPX_HOST=${GO_APPX_HOST}" \
    --env "APPX_PORT=${GO_APPX_PORT}" \
    --env "APPX_DB_HOST=${GO_DB_HOST}" \
    --env "APPX_DB_PORT=${GO_DB_PORT}" \
    --env "APPX_DB_NAME=${GO_DB_NAME}" \
    --env "APPX_DB_USER=${GO_DB_USER}" \
    --env "APPX_DB_PASSWORD=${GO_DB_PASSWORD}" \
    --network "${GO_DOCKER_NETWORK}" \
    -p "${GO_APPX_EXT_PORT}:${GO_APPX_PORT}" \
    -v "${GO_LIB_DIR}:/go" \
    -v "${GO_APP_VOLUME}:/opt/app" \
    "${GO_DOCKER_IMAGE}" \
    "$@"
}
