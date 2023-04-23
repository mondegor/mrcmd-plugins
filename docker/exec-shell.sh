
# run: mrcmd_plugins_call_function "docker/exec-shell"
mrcmd_func_docker_exec_shell() {
  local containerName="${1:?}"
  local isBash="${2:-false}"
  local shellName="sh"

  if [[ "${isBash}" == true ]]; then
    shellName="bash"
  fi

  ${MRCORE_TTY_INTERFACE} docker exec \
    -it \
    "${containerName}" \
    "${shellName}"
}
