
# run: mrcmd_plugins_call_function "docker-compose/command-exec-shell"
function mrcmd_func_docker_compose_command_exec_shell() {
  local serviceName="${1:?}"
  local shellName="${2-}"
  shift; shift

  mrcmd_plugins_call_function "docker-compose/command" \
    exec \
    "${serviceName}" \
    "$(mrcore_get_shell "${shellName}")" \
    "$@"
}
