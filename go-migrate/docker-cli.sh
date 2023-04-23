
# run: mrcmd_plugins_call_function "go-migrate/docker-cli"
mrcmd_func_go_migrate_docker_cli() {
  mrcore_validate_dir_required "DB migrate dir" "${GO_MIGRATE_DB_SRC_DIR}"
  mrcore_validate_value_required "DB URL" "${APPX_DB_URL}"

  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    -v "${GO_MIGRATE_DB_SRC_DIR}:/migrations" \
    --env "TZ=${APPX_TZ}" \
    --network "${GO_MIGRATE_DOCKER_NETWORK}" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    -path=/migrations \
    -database "${APPX_DB_URL}" \
    "$@"
}
