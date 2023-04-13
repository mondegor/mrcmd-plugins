# запуск докер контейнера для конкретной указанной конфигурации в определённым префиксом

# run: mrcmd_plugins_call_function "docker/compose-command"
mrcmd_func_docker_compose_command() {
  docker compose -p "${DOCKER_COMPOSE_APPX_ID}" ${DOCKER_COMPOSE_CONFIG_FILES} "$@"
}
