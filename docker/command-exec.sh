
# run: mrcmd_plugins_call_function "docker/command-exec"
function mrcmd_func_docker_command_exec() {
  local containerName="${1-}"
  shift

  mrcmd_plugins_docker_validate_daemon_required

  if [ -n "${containerName}" ]; then
    local containerHash
    containerHash=$(docker ps -q --filter="NAME=${containerName}")

    if [ -n "${containerHash}" ]; then
      docker exec "${containerHash}" "$@"
      ${RETURN_TRUE}
    else
      mrcore_echo_error "Container with name '${containerName}' not found"
    fi
  else
    mrcore_echo_error "Container name required"
  fi

  ${RETURN_FALSE}
}
