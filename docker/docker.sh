
function mrcmd_plugins_docker_method_init() {
  readonly DOCKER_CAPTION="Docker"

  readonly DOCKER_VARS=(
    "DOCKER_PACKAGE_NAME"
    "DOCKER_DEFAULT_SHELL" # sh, bash
  )

  readonly DOCKER_DEFAULT=(
    "p/"
    "sh"
  )

  mrcore_dotenv_init_var_array DOCKER_VARS[@] DOCKER_DEFAULT[@]

  DOCKER_DEFAULT_SHELL=$(mrcore_get_shell "${DOCKER_DEFAULT_SHELL}")
}

function mrcmd_plugins_docker_method_config() {
  mrcore_dotenv_echo_var_array DOCKER_VARS[@]
}

function mrcmd_plugins_docker_method_export_config() {
  mrcore_dotenv_export_var_array DOCKER_VARS[@]
}

function mrcmd_plugins_docker_method_exec() {
  local currentCommand="${1:?}"
  shift

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
  echo -e "  net-i NETWORK       docker network inspect NETWORK"
  echo -e "  net-rm              docker network prune"
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

  if [ -n "${items}" ]; then
    docker stop "${items}"
    docker rm "${items}"
  fi
}

# private
function mrcmd_plugins_docker_images_remove() {
  local force="${1:?}"
  local items

  items=$(docker images -q)

  if [ -n "${items}" ]; then
    if [[ "${force}" == true ]]; then
      docker rmi -f "${items}"
    else
      docker rmi "${items}"
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
      docker volume rm "${items}"
    fi
  else
    docker volume prune -f
  fi
}
