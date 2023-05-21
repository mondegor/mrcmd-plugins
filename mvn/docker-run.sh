
# run: mrcmd_plugins_call_function "mvn/docker-run"
function mrcmd_func_mvn_docker_run() {
  mrcore_validate_dir_required "Maven config dir" "${MVN_CONFIG_DIR}"

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(realpath "${MVN_CONFIG_DIR}"):${MVN_CONFIG_IN_DOCKER_DIR}" \
    -v "$(realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "MAVEN_CONFIG=${MVN_CONFIG_IN_DOCKER_DIR}" \
    --env "TZ=${APPX_TZ}" \
    "${MVN_DOCKER_IMAGE}" \
    "$@"
}
