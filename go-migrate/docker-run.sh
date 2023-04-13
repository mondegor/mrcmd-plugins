#!/bin/bash

# 1. запуск миграции БД:
# для этого нужна: сеть для доступа к БД, соединение с БД

# run: mrcmd_plugins_call_function "go-migrate/docker-run"
mrcmd_func_go_migrate_docker_run() {
  ${MRCORE_TTY_INTERFACE} docker run \
    -it \
    --rm \
    --network "${GO_MIGRATE_DOCKER_NETWORK}" \
    -v "${GO_MIGRATE_APP_VOLUME}:/migrations" \
    "${GO_MIGRATE_DOCKER_IMAGE}" \
    -path=/migrations \
    -database "${GO_MIGRATE_DB_URL}" \
    "$@"
}
