
# run: mrcmd_plugins_call_function "go-migrate/docker-run"
function mrcmd_func_go_migrate_docker_run() {
  mrcore_validate_dir_required "DB migrate dir" "${GO_MIGRATE_DB_SRC_DIR}"
  mrcore_validate_value_required "DB URL" "${GO_MIGRATE_DB_URL}"

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${GO_MIGRATE_DB_SRC_DIR}"):/migrations" \
    --env "TZ=${APPX_TZ}" \
    --network "${GO_MIGRATE_DOCKER_NETWORK}" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    -path=/migrations \
    -database "$(mrcore_lib_get_var_value "${GO_MIGRATE_DB_URL}")" \
    "$@"
}
