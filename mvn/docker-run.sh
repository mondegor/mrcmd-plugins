
# using example: mrcmd_plugins_call_function "mvn/docker-run"
function mrcmd_func_mvn_docker_run() {
  mrcore_validate_dir_required "Maven config dir" "${MVN_CONFIG_DIR}"
  mrcmd_plugins_docker_validate_daemon_required

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${MVN_CONFIG_DIR}"):${MVN_CONFIG_IN_DOCKER_DIR}" \
    -v "$(mrcmd_os_realpath "${APPX_WORK_DIR}"):/opt/app" \
    --env "MAVEN_CONFIG=$(mrcmd_os_path "${MVN_CONFIG_IN_DOCKER_DIR}")" \
    --env "TZ=${APPX_TZ}" \
    "${MVN_DOCKER_IMAGE}" \
    "$@"
}
