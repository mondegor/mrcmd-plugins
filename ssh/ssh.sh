# https://www.ssh.com/academy/ssh/keygen
# https://www.ssh.com/academy/ssh/config

# Sample host in ~/.ssh/config:
# Host github
#   Hostname github.com
#   User git
#   PasswordAuthentication no
#   IdentityFile ~/.ssh/ecdsa_id

function mrcmd_plugins_ssh_method_init() {
  readonly SSH_CAPTION="SSH"

  readonly SSH_VARS=(
    "SSH_KEYS_DIR"
  )

  readonly SSH_DEFAULT=(
    "${HOME}/.ssh"
  )

  mrcore_dotenv_init_var_array SSH_VARS[@] SSH_DEFAULT[@]
}

function mrcmd_plugins_ssh_method_config() {
  mrcore_dotenv_echo_var_array SSH_VARS[@]
}

function mrcmd_plugins_ssh_method_export_config() {
  mrcore_dotenv_export_var_array SSH_VARS[@]
}

function mrcmd_plugins_ssh_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    openssh-install)
      sudo apt update
      sudo apt-get install openssh-server
      ;;

    agent-start)
      mrcore_echo_sample "Run 'eval \$(ssh-agent)' for start"
      ;;

    agent-kill)
      ssh-agent -k
      ;;

    add)
      keys=$(find "${SSH_KEYS_DIR}" -type f \( -name "*_id*" ! -name "*.pub" \))
      if [ -n "${keys}" ]; then
        ssh-add ${keys}
      else
        mrcore_echo_error "SSH keys not found in ${CC_BLUE}${SSH_KEYS_DIR}${CC_END}"
      fi
      ;;

    check)
      local userAndHost="${1-}"
      mrcore_validate_value_required "IP or User@Host" "${userAndHost}"
      ssh -T "${userAndHost}"
      ;;

    keygen-rsa)
      mrcmd_plugins_ssh_keygen rsa 4096 "$@"
      ;;

    keygen-ecdsa)
      mrcmd_plugins_ssh_keygen ecdsa 521 "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_ssh_method_help() {
  #markup:"--|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  openssh-install             apt-get install openssh-server"
  echo -e "  agent-start                 Start SSH Agent daemon"
  echo -e "  agent-kill                  Kill SSH Agent daemon"
  echo -e "  add                         Add ssh keys from ${CC_BLUE}${SSH_KEYS_DIR}${CC_END}"
  echo -e "  check ${CC_CYAN}DESTINATION${CC_END}           Check SSH connection"
  echo -e "  keygen-rsa ${CC_CYAN}SERVER${CC_END} ${CC_CYAN}USER${CC_END}      Generate rsa key"
  echo -e "  keygen-ecdsa ${CC_CYAN}SERVER${CC_END} ${CC_CYAN}USER${CC_END}    Generate ecdsa key"
}

function mrcmd_plugins_ssh_keygen() {
  local keyAlgo="${1:?}"
  local keyAlgoBits=${2:?}
  local serverName="${3-}"
  local userName="${4-}"

  mrcore_validate_value_required "Server name (github, gitlab, ...)" "${serverName}"
  mrcore_validate_value "Server name (github, gitlab, ...)" "${REGEXP_PATTERN_NAME}" "${serverName}"
  mrcore_validate_value_required "User name or login" "${userName}"
  mrcore_validate_value "User name or login" "${REGEXP_PATTERN_NAME}" "${userName}"

  ssh-keygen -t "${keyAlgo}" -b ${keyAlgoBits} -C "${serverName}-${userName}" -f "$(mrcmd_os_realpath "${SSH_KEYS_DIR}")/${serverName}-${userName}_id_${keyAlgo}"
}
