
REPLACER_LIB_COPY_FILES_COUNT=0
REPLACER_LIB_REPLACE_FILES_CONTENT_COUNT=0

function replacer_lib_run_copy_and_replace_files() {
  local replaceNameFunc="${1:?}"
  local replaceContentFunc="${2:?}"
  local sourceDir="${3:?}"
  local destDir="${4:?}"
  local excludes=("${!5-}")

  mrcore_validate_dir_required "Source dir" "${sourceDir}"

  local realSourceDir="$(realpath "${sourceDir}")"
  local realDirDest="$(realpath "${destDir}")"

  if [[ "${realDirDest}/" == "${realSourceDir}/"* ]]; then
    mrcore_echo_error "the dest dir should not be a subdirectory of the source dir"
    ${EXIT_ERROR}
  fi

  mrcore_lib_rmdir "${destDir}"
  mrcore_lib_mkdir "${destDir}"

  mrcore_echo_notice "Copy source files to '${destDir}'"
  replacer_lib_copy_files "${replaceNameFunc}" "${sourceDir}" "${destDir}" excludes[@]

  mrcore_echo_notice "Replace file's content in '${destDir}'"
  replacer_lib_replace_files_content "${replaceContentFunc}" "${destDir}"

  REPLACER_LIB_COPY_FILES_COUNT=0
  REPLACER_LIB_REPLACE_FILES_CONTENT_COUNT=0
}

function replacer_lib_copy_files() {
  local replaceFunc="${1:?}"
  local sourceDir="${2:?}"
  local destDir="${3:?}"
  local excludes=("${!4-}")

  for path in "${sourceDir}"/*
  do
    # excludes path=*
    if [ ! -e "${path}" ] ; then
      continue
    fi

    local fileName="$(basename "${path}")"

    if mrcore_lib_in_array "${fileName}" excludes[@] ; then
      mrcore_echo_notice ".../${fileName} SKIP"
      continue
    fi

    fileName=$("${replaceFunc}" "${fileName}")

    if [ -d "${path}" ]; then
      echo -e "[DIR] ${CC_BLUE}.../$(basename "${path}")${CC_END} ${CC_GRAY}->${CC_END} ${CC_BLUE}${fileName}${CC_END}"
      mkdir -m 0755 "${destDir}/${fileName}"
      replacer_lib_copy_files "${replaceFunc}" "${path}" "${destDir}/${fileName}"
      continue
    fi

    REPLACER_LIB_COPY_FILES_COUNT=$((REPLACER_LIB_COPY_FILES_COUNT + 1))
    echo -e "${CC_GRAY}${REPLACER_LIB_COPY_FILES_COUNT}.${CC_END} .../$(basename "${path}") ${CC_GRAY}->${CC_END} ${fileName}"

    cp "${path}" "${destDir}/${fileName}"
  done
}

function replacer_lib_replace_files_content() {
  local replaceFunc="${1:?}"
  local sourceDir="${2:?}"

  for path in "${sourceDir}"/*
  do
    if [ -d "${path}" ]; then
      replacer_lib_replace_files_content "${replaceFunc}" "${path}"
      continue
    fi

    # excludes path=*
    if [ ! -f "${path}" ]; then
      continue
    fi

    REPLACER_LIB_REPLACE_FILES_CONTENT_COUNT=$((REPLACER_LIB_REPLACE_FILES_CONTENT_COUNT + 1))
    echo -e "${CC_GRAY}${REPLACER_LIB_REPLACE_FILES_CONTENT_COUNT}.${CC_END} .../$(basename "${path}")"

    ${replaceFunc} "${path}"
  done
}
