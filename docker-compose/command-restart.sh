
# run: mrcmd_plugins_call_function "docker-compose/command-restart"
mrcmd_func_docker_compose_command_restart() {
  local containerName="${1:?}"
  local serviceName="${2:?}"

  docker stop "${containerName}" | xargs docker rm
  mrcmd_plugins_call_function "docker-compose/command" up -d --remove-orphans "${serviceName}"
}
