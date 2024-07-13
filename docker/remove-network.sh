
# using example: mrcmd_plugins_call_function "docker/remove-network"
function mrcmd_func_docker_remove_network() {
  local networkName="${1:?}"

  mrcmd_plugins_docker_validate_daemon_required

  if ! docker network ls | grep "${networkName}" > /dev/null; then
    mrcore_echo_notice "Docker network '${networkName}' is already removed"
    return
  fi

  docker network rm "${networkName}"
}
