
# run: mrcmd_plugins_call_function "docker-compose/command"
function mrcmd_func_docker_compose_command() {
  local currentCommand="${1-}"
  local ttyInterface=""
  local configFiles=""

  local tmp="${DOCKER_COMPOSE_CONFIG_FILES_ARRAY[@]}"
  mrcore_debug_echo ${DEBUG_LEVEL_1} "${DEBUG_BLUE}" "DOCKER_COMPOSE_CONFIG_FILES_ARRAY=${tmp}"

  for configFile in "${DOCKER_COMPOSE_CONFIG_FILES_ARRAY[@]}"
  do
    configFiles="${configFiles}${CMD_SEPARATOR}-f${CMD_SEPARATOR}${configFile}"
  done

  if [[ "${currentCommand}" == "exec" ]]; then
    ttyInterface="${MRCORE_TTY_INTERFACE}"
  fi

  ${ttyInterface} docker compose \
    -p "${APPX_ID}" \
    --project-directory "${APPX_DIR}" \
    --env-file "${DOCKER_COMPOSE_CONFIG_DIR}/.env" \
    ${configFiles} \
    "$@"
}
