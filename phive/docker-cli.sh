
# run: mrcmd_plugins_call_function "phive/docker-cli"
mrcmd_func_phive_docker_cli() {
  mrcore_validate_dir_required "Tools dir" "${PHIVE_TOOLS_DIR}"

  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${PHIVE_TOOLS_DIR}:/opt/tools" \
    "${PHIVE_DOCKER_IMAGE}" \
    "$@"
}
