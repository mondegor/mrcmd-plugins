
# run: mrcmd_plugins_call_function "docker-compose/command-exec-shell"
mrcmd_func_docker_compose_command_exec_shell() {
  local serviceName="${1:?}"
  local isBash="${2:-false}"
  local shellName="sh"

  if [[ "${isBash}" == true ]]; then
    shellName="bash"
  fi

  mrcmd_plugins_call_function "docker-compose/command" \
    exec \
    "${serviceName}" \
    "${shellName}"
}
