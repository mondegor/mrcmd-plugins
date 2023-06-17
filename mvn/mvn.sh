# https://hub.docker.com/_/maven

function mrcmd_plugins_mvn_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_mvn_method_init() {
  readonly MVN_CAPTION="Maven openjdk 17"
  readonly MVN_DOCKER_SERVICE="web-app"

  readonly MVN_VARS=(
    "MVN_DOCKER_CONTEXT_DIR"
    "MVN_DOCKER_DOCKERFILE"
    "MVN_DOCKER_IMAGE"
    "MVN_DOCKER_IMAGE_FROM"

    "MVN_CONFIG_DIR"
    "MVN_CONFIG_IN_DOCKER_DIR"
    "MVN_SETTINGS_PATH"

    "MVN_PRIVATE_TOKEN" # sample: gitlab Personal Access Tokens
  )

  readonly MVN_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}mvn:3.8.5-openjdk-17-slim"
    "maven:3.8.5-openjdk-17-slim"

    "${APPX_DIR}/.m2"
    "/home/maven/.m2"
    "${APPX_DIR}/mvn.settings.xml"

    ""
  )

  mrcore_dotenv_init_var_array MVN_VARS[@] MVN_VARS_DEFAULT[@]
}

function mrcmd_plugins_mvn_method_config() {
  mrcore_dotenv_echo_var_array MVN_VARS[@]
}

function mrcmd_plugins_mvn_method_export_config() {
  mrcore_dotenv_export_var_array MVN_VARS[@]
}

function mrcmd_plugins_mvn_method_install() {
  if [ ! -f "${APPX_WORK_DIR}/pom.xml" ]; then
    mrcore_validate_file_required "File" "${APPX_WORK_DIR}/pom.xml"
  fi

  if [ ! -e "${MVN_CONFIG_DIR}" ] && [ -f "${MVN_SETTINGS_PATH}" ]; then
    mrcore_lib_mkdir "${MVN_CONFIG_DIR}"
    cp "${MVN_SETTINGS_PATH}" "${MVN_CONFIG_DIR}/settings.xml"
    sed -i "s/\${PRIVATE_TOKEN}/${MVN_PRIVATE_TOKEN}/" "${MVN_CONFIG_DIR}/settings.xml"
  fi

  mrcmd_plugins_call_function "mvn/docker-build" --no-cache
  mrcmd_plugins_call_function "mvn/docker-run" mvn package
}

function mrcmd_plugins_mvn_method_uninstall() {
  if [ -f "${MVN_SETTINGS_PATH}" ] && [[ "${MVN_CONFIG_DIR}" == "${APPX_DIR}/.m2" ]] ; then
    mrcore_lib_rmdir "${MVN_CONFIG_DIR}"
  fi

  mrcore_lib_rmdir "${APPX_DIR}/target"
}

function mrcmd_plugins_mvn_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_mvn_method_config
      mrcmd_plugins_call_function "mvn/docker-build" "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "mvn/docker-run" mvn "$@"
      ;;

    shell)
      mrcmd_plugins_call_function "mvn/docker-run" "bash" "$@"
      ;;

    package)
      mrcmd_plugins_call_function "mvn/docker-run" mvn package
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_mvn_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${MVN_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'mvn [arguments]' in a container of the image"
  echo -e "  shell               Exec shell in a container of the image"
  echo -e "  package             Build the project"
}
