
# using example: mrcmd_plugins_call_function "docker-compose/register"
function mrcmd_func_docker_compose_register() {
  local configYaml="${1:?}"
  local customEnvFile="${2:?}"
  local customEnvYaml="${3:?}"

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${configYaml}")

  if [ -f "${customEnvFile}" ]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${customEnvYaml}")
  fi
}
