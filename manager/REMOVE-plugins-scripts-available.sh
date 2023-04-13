#!/bin/bash

function mrcmd_scripts_help_available_exec() {
  mrcore_debug_echo_call_function "${FUNCNAME[0]}" "$@"

  mrcmd_scripts_load
  mrcmd_main_help_head
  mrcmd_scripts_available_list
}

# private
function mrcmd_scripts_available_list() {
  echo -e "${CC_YELLOW}Available core scripts:${CC_END}"
  echo ""

  local SCRIPT_NAME
  local dirIndex
  local dirIndexLast=0
  local pluginsDir
  local i=0

  for SCRIPT_NAME in "${MRCMD_SCRIPTS_LOADED_ARRAY[@]}"
  do
    dirIndex=${MRCMD_SCRIPTS_LOADED_DIRS_ARRAY[${i}]}
    pluginsDir="${MRCMD_PLUGINS_DIR_ARRAY[${dirIndex}]}"

    if [[ ${dirIndex} -ne ${dirIndexLast} ]]; then
      dirIndexLast=${dirIndex}

      echo -e "${CC_YELLOW}Available project scripts:${CC_END}"
      echo ""
    fi

    mrcmd_scripts_available_echo_function "${SCRIPT_NAME}" "${pluginsDir}/${SCRIPT_NAME}.sh"

    i=$((i + 1))
  done
}

# private
function mrcmd_scripts_available_echo_function() {
  local SCRIPT_NAME=${1:?}
  local scriptPath=${2:?}

  scriptFunc="mrcmd_scripts_${SCRIPT_NAME//[\/-]/_}"


  echo -e "  ${CC_GREEN}${SCRIPT_NAME}${CC_END} in ${CC_BLUE}${scriptPath}${CC_END}"

  if mrcore_lib_function_exists "${scriptFunc}" ; then
    echo -e "    ${scriptFunc}() [${CC_LIGHT_GREEN}enabled${CC_END}]"
  else
    echo -e "    ${CC_GRAY}${scriptFunc}${CC_END}() [${CC_RED}not found${CC_END}]"
  fi

  echo ""
}

function mrcmd_scripts_help_exec() {
  mrcore_debug_echo_call_function "${FUNCNAME[0]}" "$@"
  mrcmd_scripts_load

  local SCRIPT_NAME
  local dirIndex
  local dirIndexLast=0
  local i=0

  echo -e "${CC_YELLOW}Call core script functions in code:${CC_END}"

  for SCRIPT_NAME in "${MRCMD_SCRIPTS_LOADED_ARRAY[@]}"
  do
    dirIndex=${MRCMD_SCRIPTS_LOADED_DIRS_ARRAY[${i}]}

    if [[ ${dirIndex} -ne ${dirIndexLast} ]]; then
      dirIndexLast=${dirIndex}

      echo ""
      echo -e "${CC_YELLOW}Call project script functions in code:${CC_END}"
    fi

    mrcmd_scripts_help_echo_function "${SCRIPT_NAME}"

    i=$((i + 1))
  done

  echo ""
}

# private
function mrcmd_scripts_help_echo_function() {
  local SCRIPT_NAME=${1:?}

  scriptFunc="mrcmd_scripts_${SCRIPT_NAME//[\/-]/_}"

  if mrcore_lib_function_exists "${scriptFunc}" ; then
    echo -e "  ${CC_GREEN}mrcmd_plugins_call_function${CC_END} ${SCRIPT_NAME} [arguments]"
  fi
}
