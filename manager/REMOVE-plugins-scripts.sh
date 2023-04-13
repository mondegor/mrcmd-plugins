#!/bin/bash

export MRCMD_SCRIPTS_LOADED_ARRAY
export MRCMD_SCRIPTS_LOADED_DIRS_ARRAY

function mrcmd_scripts_load() {
  mrcore_debug_echo_call_function "${FUNCNAME[0]}"

  local pluginsDir
  local PATH_LENGTH
  local scriptPath
  local SCRIPT_NAME
  local i=0
  local JJ=0

  MRCMD_SCRIPTS_LOADED_ARRAY=()
  MRCMD_SCRIPTS_LOADED_DIRS_ARRAY=()

  for pluginsDir in "${MRCMD_PLUGINS_DIR_ARRAY[@]}"
  do
    # if project scripts dir not included
    if [[ -z "${pluginsDir}" ]]; then
      continue
    fi

    for scriptPath in "${pluginsDir}"/*
    do
      if [ -d "${scriptPath}" ]; then
        mrcore_debug_echo ${DEBUG_LEVEL_3} "${DEBUG_BLUE}" "Dir ${scriptPath} ignored"
        continue
      fi

      if ! mrcore_lib_check_string_suffix "${scriptPath}" ".sh" ; then
        mrcore_debug_echo ${DEBUG_LEVEL_3} "${DEBUG_BLUE}" "File ${scriptPath} ignored"
        continue
      fi

      PATH_LENGTH=$((${#pluginsDir} + 1))
      SCRIPT_NAME=${scriptPath:${PATH_LENGTH}:-3}

      # shellcheck source=${scriptPath}
      source "${scriptPath}"

      mrcore_debug_echo ${DEBUG_LEVEL_2} "${DEBUG_GREEN}" "Loaded ${SCRIPT_NAME} from ${scriptPath}"

      if mrcore_lib_in_array "${SCRIPT_NAME}" MRCMD_SCRIPTS_LOADED_ARRAY[@] ; then
        mrcore_echo_error "Conflict: script ${SCRIPT_NAME} in ${scriptPath} already registered in mrcmd core [skipped]"
        continue
      fi

      MRCMD_SCRIPTS_LOADED_ARRAY[${JJ}]=${SCRIPT_NAME}
      MRCMD_SCRIPTS_LOADED_DIRS_ARRAY[${JJ}]=${i}

      JJ=$((JJ + 1))
    done

    i=$((i + 1))
  done
}
