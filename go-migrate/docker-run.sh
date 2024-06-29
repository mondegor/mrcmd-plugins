
# using example: mrcmd_plugins_call_function "go-migrate/docker-run"
function mrcmd_func_go_migrate_docker_run() {
  mrcore_validate_dir_required "DB migrate dir" "${GO_MIGRATE_DB_SRC_DIR}"
  mrcore_validate_value_required "DB URL" "${GO_MIGRATE_DB_URL}"
  mrcmd_plugins_docker_validate_daemon_required

  # TODO: check GO_MIGRATE_DB_URL if "?" exists before join GO_MIGRATE_DB_TABLE
  local goMigrateDbUrl="$(mrcore_lib_get_var_value "${GO_MIGRATE_DB_URL}")&x-migrations-table=${GO_MIGRATE_DB_TABLE}"

  mrcore_echo_notice "GO_MIGRATE_DB_URL: ${goMigrateDbUrl}"

  # --user root
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "$(mrcmd_os_realpath "${GO_MIGRATE_DB_SRC_DIR}"):/migrations" \
    --env "TZ=${APPX_TZ}" \
    --network "${GO_MIGRATE_DOCKER_NETWORK}" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    -path="$(mrcmd_os_realpath "/migrations")" \
    -database "${goMigrateDbUrl}" \
    "$@"
}
