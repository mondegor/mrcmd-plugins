
function mrcmd_plugins_docker_method_exec() {
  local currentCommand=${1:?}

  case ${currentCommand} in

    service-start)
      sudo service docker start
      ;;

    service-restart)
      sudo service docker restart
      ;;

    service-stop)
      sudo service docker stop
      ;;

    networks)
      docker network ls
      ;;

    networks-remove)
      docker network prune
      ;;

    stop-all)
      docker stop "$(docker ps -a -q)"
      ;;

    remove-all)
      docker rm "$(docker ps -a -q)"
      ;;

    remove-all-images)
      docker rmi "$(docker images -q)"
      ;;

    *)
      ${RETURN_FALSE}
      ;;

  esac
}

function mrcmd_plugins_docker_method_help() {
  echo -e "  ${CC_YELLOW}Docker${CC_END}:"
  echo -e "    ${CC_GREEN}start${CC_END}    Build or rebuild services"
  echo -e "    ${CC_GREEN}restart${CC_END}  Build or rebuild services"
  echo -e "    ${CC_GREEN}stop${CC_END}     Build or rebuild services"
  echo ""
}
