
# using example: mrcmd_plugins_call_function "docker/create-network"
function mrcmd_func_docker_create_network() {
  local networkName="${1:?}"
  local networkDriver="${2:?}"

  mrcmd_plugins_docker_validate_daemon_required

  if docker network ls | grep "${networkName}" > /dev/null; then
    mrcore_echo_notice "Docker network '${networkName}' is already created"
    return
  fi

  docker network create \
    --driver "${networkDriver}" \
    "${networkName}" > /dev/null
}
