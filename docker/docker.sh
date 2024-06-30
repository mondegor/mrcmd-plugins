
function mrcmd_plugins_docker_method_init() {
  readonly DOCKER_CAPTION="Docker"
  DOCKER_DAEMON_IS_RUNNING=false

  readonly DOCKER_VARS=(
    "DOCKER_PACKAGE_NAME"
    "DOCKER_DEFAULT_SHELL" # sh, bash
  )

  readonly DOCKER_DEFAULT=(
    "p/"
    "sh"
  )

  mrcore_dotenv_init_var_array DOCKER_VARS[@] DOCKER_DEFAULT[@]

  if mrcore_command_exists "docker${CMD_SEPARATOR}-v" ; then
    readonly DOCKER_IS_ENABLED=true
  else
    readonly DOCKER_IS_ENABLED=false
  fi

  DOCKER_DEFAULT_SHELL=$(mrcore_get_shell "${DOCKER_DEFAULT_SHELL}")

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${DOCKER_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_docker_method_canexec() {
  if [[ "${DOCKER_IS_ENABLED}" == true ]]; then
    ${RETURN_TRUE}
  fi

  local pluginMethod="${1:?}"

  if mrcore_lib_in_array "${pluginMethod}" MRCMD_PLUGIN_METHODS_EXECUTE_COMMANDS_ARRAY[@] ; then
    ${RETURN_FALSE}
  fi

  ${RETURN_TRUE}
}

function mrcmd_plugins_docker_method_config() {
  mrcore_dotenv_echo_var_array DOCKER_VARS[@]
}

function mrcmd_plugins_docker_method_export_config() {
  mrcore_dotenv_export_var_array DOCKER_VARS[@]
}

function mrcmd_plugins_docker_method_exec() {
  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    return
  fi

  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

      d-start | d-restart | d-stop)
        mrcore_validate_tool_required docker
        sudo service docker "${currentCommand:2:${#currentCommand}}"
        return
        ;;

  esac

  mrcmd_plugins_docker_validate_daemon_required

  case "${currentCommand}" in

    ps)
      docker ps -a
      ;;

    ps-stop)
      docker stop $(docker ps -a -q)
      ;;

    ps-rm)
      mrcmd_plugins_docker_containers_remove false
      ;;

    im)
      docker images -a
      ;;

    im-rm)
      mrcmd_plugins_docker_images_remove false
      ;;

    im-rm-f)
      mrcmd_plugins_docker_images_remove true
      ;;

    net)
      docker network ls
      ;;

    net-rm)
      mrcmd_plugins_docker_networks_remove false
      ;;

    net-i)
      docker network inspect "$@"
      ;;

    c-ip)
      local containerName="${1-}"
      if ! mrcmd_plugins_call_function "docker/command-exec" "${containerName}" /sbin/ip route ; then
        mrcore_echo_sample "Run '${MRCMD_INFO_NAME} docker ps' and see column NAMES"
      fi
      ;;

    vol)
      docker volume ls
      ;;

    vol-rm)
      mrcmd_plugins_docker_volumes_remove false
      ;;

    vol-rm-f)
      mrcmd_plugins_docker_volumes_remove true
      ;;

    clean)
      mrcmd_plugins_docker_clean false
      ;;

    destroy)
      mrcmd_plugins_docker_clean true
      ;;

    cmd)
      ${MRCORE_TTY_INTERFACE} docker "$@"
      ;;

    d-start)
      sudo service docker start
      ;;

    d-restart)
      sudo service docker restart
      ;;

    d-stop)
      sudo service docker stop
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_docker_method_help() {
  #markup:"--|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  ps                  docker ps -a"
  echo -e "  ps-stop             docker stop \$(docker ps -a -q)"
  echo -e "  ps-rm               docker rm \$(docker ps -a -q)"
  echo -e "  im                  docker images -a"
  echo -e "  im-rm               docker rmi \$(docker images -q)"
  echo -e "  im-rm-f             docker rmi -f \$(docker images -q)"
  echo -e "  net                 docker network ls"
  echo -e "  net-i ${CC_CYAN}NETWORK${CC_END}       docker network inspect ${CC_CYAN}NETWORK${CC_END}"
  echo -e "  net-rm              docker network prune"
  echo -e "  c-ip ${CC_CYAN}NAME${CC_END}           Show ip route list of container ${CC_CYAN}NAME${CC_END}"
  echo -e "  vol                 docker volume ls"
  echo -e "  vol-rm              docker volume prune"
  echo -e "  vol-rm-f            docker volume rm \$(docker volume ls -q)"
  echo -e "  clean               Clear unused docker resources"
  echo -e "  destroy             Destroy all docker resources"
  echo ""
  echo -e "${CC_YELLOW}Docker tool command:${CC_END}"
  echo -e "  cmd [arguments]     Runs original tool 'docker [arguments]'"
  echo -e "  cmd ${CC_BLUE}--help${CC_END}          More information about tool 'docker'"
  echo ""
  echo -e "${CC_YELLOW}Docker service commands:${CC_END}"
  echo -e "  d-start     sudo service docker start"
  echo -e "  d-restart   sudo service docker restart"
  echo -e "  d-stop      sudo service docker stop"
}

# private
function mrcmd_plugins_docker_clean() {
  mrcmd_plugins_docker_containers_remove "$@"
  mrcmd_plugins_docker_images_remove "$@"
  mrcmd_plugins_docker_networks_remove "$@"
  mrcmd_plugins_docker_volumes_remove "$@"
}

# private
function mrcmd_plugins_docker_containers_remove() {
  local force="${1:?}"
  local items

  items=$(docker ps -a -q)

  if [ -n "${items}" ] && docker stop ${items} ; then
    docker rm ${items}
  fi
}

# private
function mrcmd_plugins_docker_images_remove() {
  local force="${1:?}"
  local items

  items=$(docker images -q)

  if [ -n "${items}" ]; then
    if [[ "${force}" == true ]]; then
      docker rmi -f ${items}
    else
      docker rmi ${items}
    fi
  fi
}

# private
function mrcmd_plugins_docker_networks_remove() {
  local force="${1:?}"

  docker network prune -f
}

# private
function mrcmd_plugins_docker_volumes_remove() {
  local force="${1:?}"
  local items

  if [[ "${force}" == true ]]; then
    items=$(docker volume ls -q)

    if [ -n "${items}" ]; then
      docker volume rm ${items}
    fi
  else
    docker volume prune -f
  fi
}

# public
function mrcmd_plugins_docker_validate_daemon_required() {
  if [[ "${DOCKER_DAEMON_IS_RUNNING}" == true ]]; then
    return
  fi

  mrcore_validate_tool_required docker

  message=$(docker ps 2>&1)

  if [[ ${message} =~ "Is the docker daemon running?" ]] ||
     [[ ${message} =~ "error may indicate that the docker daemon is not running" ]]; then
    mrcore_echo_error "${message}"
    mrcore_echo_sample "Run '${MRCMD_INFO_NAME} docker d-start'"
    ${EXIT_ERROR}
  fi

  DOCKER_DAEMON_IS_RUNNING=true
}
