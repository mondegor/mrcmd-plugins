
readonly DOCKER_COMPOSE_VARS=(
  "DOCKER_COMPOSE_APPX_ID"
  "DOCKER_COMPOSE_CONFIG_FILES"
)

# default values of array: DOCKER_COMPOSE_VARS
readonly DOCKER_COMPOSE_DEFAULT=(
  "${APPX_ID:-appx}"
  "-f${CMD_SEPARATOR}${MRCMD_DIR}/plugins/docker-compose/docker-compose.yaml"
  ""
)

function mrcmd_plugins_docker_compose_method_config() {
  mrcore_dotenv_echo_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_export_config() {
  mrcore_dotenv_export_var_array DOCKER_COMPOSE_VARS[@]
}

function mrcmd_plugins_docker_compose_method_init() {
  mrcore_dotenv_init_var_array DOCKER_COMPOSE_VARS[@] DOCKER_COMPOSE_DEFAULT[@]
}

function mrcmd_plugins_docker_compose_method_install() {
  mrcmd_plugins_call_function "docker-compose/command" build
}

function mrcmd_plugins_docker_compose_method_uninstall() {
  mrcmd_plugins_call_function "docker-compose/command" down -v --remove-orphans --rmi=all
}

function mrcmd_plugins_docker_compose_method_exec() {
  local currentCommand=${1:?}
  shift

  case ${currentCommand} in

    config)
      mrcmd_plugins_call_function "docker-compose/command" config "$@"
      ;;

    build)
      # --progress plain
      # --no-cache
      mrcmd_plugins_call_function "docker-compose/command" build "$@"
      ;;

    up)
      mrcmd_plugins_call_function "docker-compose/command" up -d --remove-orphans "$@"
      ;;

    start)
      mrcmd_plugins_call_function "docker-compose/command" start
      ;;

    stop)
      mrcmd_plugins_call_function "docker-compose/command" stop
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command" stop
      mrcmd_plugins_call_function "docker-compose/command" start
      ;;

    ps)
      mrcmd_plugins_call_function "docker-compose/command" ps "$@"
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --follow "$@"
      ;;

    down)
      mrcmd_plugins_call_function "docker-compose/command" down --remove-orphans "$@"
      ;;

    #reload)
    #  mrcmd_docker_compose_item_reload ${MRCMD_ARGS}
    #  ;;

    exec)
      # -u www-data
      mrcmd_plugins_call_function "docker-compose/command" exec "$@"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_docker_compose_method_help() {
  echo -e "  ${CC_YELLOW}Docker compose${CC_END} using ${CC_BLUE}${DOCKER_COMPOSE_CONFIG_FILES}${CC_END}:"
  echo -e "    ${CC_GREEN}build        ${CC_END}  Build or rebuild services"
  echo -e "    ${CC_GREEN}build-nocache${CC_END}  Build or rebuild services"
  echo -e "    ${CC_GREEN}up           ${CC_END}  Builds, (re)creates, starts, and attaches to containers"
  echo -e "    ${CC_GREEN}start        ${CC_END}  Starts existing containers"
  echo -e "    ${CC_GREEN}stop         ${CC_END}  Stops running containers without removing them. They can be started again with ${CC_GREEN}dc_start${CC_END}"
  echo -e "    ${CC_GREEN}restart      ${CC_END}  Restarts all stopped and running services"
  echo -e "    ${CC_GREEN}ps           ${CC_END}  Lists containers, with current status and exposed ports"
  echo -e "    ${CC_GREEN}logs         ${CC_END}  Displays log output from services"
  echo -e "    ${CC_GREEN}down         ${CC_END}  Stops containers and removes containers, networks, volumes, and images created by ${CC_GREEN}dc_up${CC_END}"
  echo ""
}
