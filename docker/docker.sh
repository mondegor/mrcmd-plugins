
function mrcmd_plugins_docker_method_init() {
  readonly DOCKER_NAME="Docker"
}

function mrcmd_plugins_docker_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    ps)
      docker ps -a
      ;;

    ps-stop)
      docker stop $(docker ps -a -q)
      ;;

    ps-rm)
      docker rm $(docker ps -a -q)
      ;;

    im)
      docker images -a
      ;;

    im-rm)
      docker rmi $(docker images -q)
      ;;

    im-rm-f)
      docker rmi -f $(docker images -q)
      ;;

    net)
      docker network ls
      ;;

    net-rm)
      docker network prune
      ;;

    vol)
      docker volume ls
      ;;

    vol-rm)
      docker volume prune
      ;;

    vol-rm-f)
      docker volume rm $(docker volume ls -q)
      ;;

    clean)
      docker stop $(docker ps -a -q)
      docker rm $(docker ps -a -q)
      docker rmi $(docker images -q)
      docker network prune -f
      docker volume prune -f
      ;;

    cli)
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
  echo -e "  ps          docker ps -a"
  echo -e "  ps-stop     docker stop \$(docker ps -a -q)"
  echo -e "  ps-rm       docker rm \$(docker ps -a -q)"
  echo -e "  im          docker images -a"
  echo -e "  im-rm       docker rmi \$(docker images -q)"
  echo -e "  im-rm-f     docker rmi -f \$(docker images -q)"
  echo -e "  net         docker network ls"
  echo -e "  net-rm      docker network prune"
  echo -e "  vol         docker volume ls"
  echo -e "  vol-rm      docker volume prune"
  echo -e "  vol-rm-f    docker volume rm \$(docker volume ls -q)"
  echo -e "  clean       Clear unused docker resources"
  echo ""
  echo -e "${CC_YELLOW}Docker tool command:${CC_END}"
  echo -e "  cli [arguments]     Run original tool 'docker'"
  echo -e "  cli ${CC_BLUE}--help${CC_END}          More information about 'docker' commands"
  echo ""
  echo -e "${CC_YELLOW}Service commands:${CC_END}"
  echo -e "  d-start     sudo service docker start"
  echo -e "  d-restart   sudo service docker restart"
  echo -e "  d-stop      sudo service docker stop"
}
