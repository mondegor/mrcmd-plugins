
# run: mrcmd_plugins_call_function "plantuml/docker-run"
function mrcmd_func_plantuml_docker_run() {
  mrcore_validate_dir_required "Source dir" "${PLANTUML_SOURCE_DIR}"

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${PLANTUML_SOURCE_DIR}"):/data" \
    --env "TZ=${APPX_TZ}" \
    "${PLANTUML_DOCKER_IMAGE}" \
    "$@"
}
