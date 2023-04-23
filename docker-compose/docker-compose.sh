
function mrcmd_plugins_docker_compose_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_docker_compose_method_init() {
  readonly DOCKER_COMPOSE_NAME="Docker compose"

  readonly DOCKER_COMPOSE_VARS=(
    "DOCKER_COMPOSE_PROJECT_NAME"
    "DOCKER_COMPOSE_CONFIG_DIR"
    "DOCKER_COMPOSE_GENERAL_NETWORK" # OFF, CREATE, USE
  )

  readonly DOCKER_COMPOSE_DEFAULT=(
    "${APPX_ID}"
    "${MRCMD_DIR}/plugins/docker-compose"
    "off"
  )

  mrcore_dotenv_init_var_array DOCKER_COMPOSE_VARS[@] DOCKER_COMPOSE_DEFAULT[@]
  mrcmd_plugins_docker_compose_general_network_var_init

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY=("${DOCKER_COMPOSE_CONFIG_DIR}/service-network.yaml")

  if [[ "${DOCKER_COMPOSE_GENERAL_NETWORK}" != off ]]; then
    DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${DOCKER_COMPOSE_CONFIG_DIR}/general-network.yaml")
  fi
}

function mrcmd_plugins_docker_compose_method_config() {
  mrcore_dotenv_echo_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_export_config() {
  mrcore_dotenv_export_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_install() {
  mrcmd_plugins_call_function "docker-compose/command" build --no-cache
}

function mrcmd_plugins_docker_compose_method_start() {
  mrcmd_plugins_call_function "docker-compose/command" build
  mrcmd_plugins_call_function "docker-compose/command" up -d --remove-orphans
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

  case ${currentCommand} in

    conf)
      mrcmd_plugins_call_function "docker-compose/command" config
      ;;

    build)
      mrcmd_plugins_call_function "docker-compose/command" build --no-cache
      ;;

    up)
      mrcmd_plugins_call_function "docker-compose/command" up -d --remove-orphans
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

    dc-start | dc-stop | ps)
      mrcmd_plugins_call_function "docker-compose/command" "${currentCommand}"
      ;;

    dc-restart)
      mrcmd_plugins_call_function "docker-compose/command" stop
      mrcmd_plugins_call_function "docker-compose/command" start
      ;;

    cli)
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
  echo -e "  conf        docker-compose config"
  echo -e "  build       docker-compose build --no-cache"
  echo -e "  up          docker-compose up -d --remove-orphans"
  echo -e "  ps          docker-compose ps"
  echo -e "  im          docker-compose images"
  echo -e "  logs        docker-compose logs --follow"
  echo -e "  down        docker-compose down --remove-orphans"
  echo -e "  dc-start    docker-compose start"
  echo -e "  dc-stop     docker-compose stop"
  echo -e "  dc-restart  docker-compose stop & docker-compose start"
  echo ""
  echo -e "${CC_YELLOW}Docker compose tool command:${CC_END}"
  echo -e "  cli [arguments]     Run original tool 'docker compose' using project yaml config"
  echo -e "  cli ${CC_BLUE}--help${CC_END}          More information about 'docker compose' commands"
  echo ""
}

function mrcmd_plugins_docker_compose_general_network_var_init() {
  if [[ "${DOCKER_COMPOSE_GENERAL_NETWORK}" == USE ]]; then
    DOCKER_COMPOSE_GENERAL_NETWORK=true
  elif [[ "${DOCKER_COMPOSE_GENERAL_NETWORK}" == CREATE ]]; then
    DOCKER_COMPOSE_GENERAL_NETWORK=false
  elif [[ "${DOCKER_COMPOSE_GENERAL_NETWORK}" != OFF ]]; then
    DOCKER_COMPOSE_GENERAL_NETWORK=OFF
    mrcore_echo_error "DOCKER_COMPOSE_GENERAL_NETWORK can have the following values: OFF, CREATE, USE"
  fi
}
