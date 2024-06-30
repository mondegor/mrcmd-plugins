
function mrcmd_plugins_docker_compose_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_docker_compose_method_init() {
  readonly DOCKER_COMPOSE_CAPTION="Docker Compose"

  export DOCKER_COMPOSE_LOCAL_NETWORK="local-network"
  export DOCKER_COMPOSE_GENERAL_NETWORK="general-network"
  export DOCKER_COMPOSE_GENERAL_NETWORK_IS_EXTERNAL=true

  readonly DOCKER_COMPOSE_VARS=(
    "DOCKER_COMPOSE_CONFIG_DIR"
    "DOCKER_COMPOSE_CONFIG_FILE_LAST"
    "DOCKER_COMPOSE_USE_GENERAL_NETWORK"
  )

  readonly DOCKER_COMPOSE_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}"
    "${APPX_DIR}/docker-compose-app.yaml"
    "false"
  )

  mrcore_dotenv_init_var_array DOCKER_COMPOSE_VARS[@] DOCKER_COMPOSE_DEFAULT[@]
  mrcore_validate_file_required "Docker compose network" "${DOCKER_COMPOSE_CONFIG_DIR}/${DOCKER_COMPOSE_LOCAL_NETWORK}.yaml"

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY=("${DOCKER_COMPOSE_CONFIG_DIR}/${DOCKER_COMPOSE_LOCAL_NETWORK}.yaml")

  if [[ "${DOCKER_COMPOSE_USE_GENERAL_NETWORK}" == true ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${DOCKER_COMPOSE_CONFIG_DIR}/${DOCKER_COMPOSE_GENERAL_NETWORK}.yaml")
  fi

  if [ -f "${DOCKER_COMPOSE_CONFIG_FILE_LAST}" ]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${DOCKER_COMPOSE_CONFIG_FILE_LAST}")
  fi

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${DOCKER_COMPOSE_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_docker_compose_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_docker_compose_method_config() {
  mrcore_dotenv_echo_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_export_config() {
  mrcore_dotenv_export_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_start() {
  mrcmd_plugins_docker_compose_up -d --remove-orphans
}

function mrcmd_plugins_docker_compose_method_stop() {
  mrcmd_plugins_call_function "docker-compose/command" down --remove-orphans
}

function mrcmd_plugins_docker_compose_method_uninstall() {
  mrcmd_plugins_call_function "docker-compose/command" down -v --remove-orphans --rmi=all
}

function mrcmd_plugins_docker_compose_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    conf)
      echo -e "${CC_YELLOW}DOCKER_COMPOSE_CONFIG_FILES_ARRAY:${CC_END}"
      echo -e "  - $(mrcmd_lib_implode "\n  - " DOCKER_COMPOSE_CONFIG_FILES_ARRAY[@])\n"

      mrcmd_plugins_call_function "docker-compose/command" config
      ;;

    up)
      mrcmd_plugins_docker_compose_up -d --remove-orphans
      ;;

    ps)
      mrcmd_plugins_call_function "docker-compose/command" ps
      ;;

    im)
      mrcmd_plugins_call_function "docker-compose/command" images
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --follow
      ;;

    down)
      mrcmd_plugins_call_function "docker-compose/command" down --remove-orphans
      ;;

    dc-start)
      mrcmd_plugins_call_function "docker-compose/command" start
      ;;

    dc-stop)
      mrcmd_plugins_call_function "docker-compose/command" stop
      ;;

    dc-restart)
      mrcmd_plugins_call_function "docker-compose/command" stop
      mrcmd_plugins_call_function "docker-compose/command" start
      ;;

    cmd)
      mrcmd_plugins_call_function "docker-compose/command" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_docker_compose_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  conf        docker compose config"
  echo -e "  up          docker compose up -d --remove-orphans"
  echo -e "  ps          docker compose ps"
  echo -e "  im          docker compose images"
  echo -e "  logs        docker compose logs --follow"
  echo -e "  down        docker compose down --remove-orphans"
  echo -e "  dc-start    docker compose start"
  echo -e "  dc-stop     docker compose stop"
  echo -e "  dc-restart  docker compose stop & docker compose start"
  echo ""
  echo -e "${CC_YELLOW}Docker compose tool command:${CC_END}"
  echo -e "  cmd [arguments]     Run original tool 'docker compose [arguments]'"
  echo -e "                      using project yaml config"
  echo -e "  cmd ${CC_BLUE}--help${CC_END}          More information about tool 'docker compose'"
  echo ""
}

# private
function mrcmd_plugins_docker_compose_up() {
  if [[ "${DOCKER_COMPOSE_USE_GENERAL_NETWORK}" == true ]]; then
    if ! docker network ls | grep "${DOCKER_COMPOSE_GENERAL_NETWORK}" > /dev/null; then
      DOCKER_COMPOSE_GENERAL_NETWORK_IS_EXTERNAL=false
    fi
  fi

  mrcmd_plugins_call_function "docker-compose/command" up "$@"
}
