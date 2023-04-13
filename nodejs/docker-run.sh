
# --name ${NODEJS_DOCKER_CONTAINER} \
# -p ${NODEJS_EXT_PORT}:3000 \

# run: mrcmd_plugins_call_function "nodejs/docker-run"
mrcmd_func_nodejs_docker_run() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${NODEJS_APP_VOLUME}:/opt/app" \
    "${NODEJS_DOCKER_IMAGE}" "$@"
}
