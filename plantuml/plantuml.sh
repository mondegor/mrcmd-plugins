# https://hub.docker.com/r/plantuml/plantuml
# https://plantuml.com/command-line
# https://github.com/plantuml/plantuml/pkgs/container/plantuml

function mrcmd_plugins_plantuml_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_plantuml_method_init() {
  readonly PLANTUML_CAPTION="Plantuml"

  readonly PLANTUML_VARS=(
    "PLANTUML_DOCKER_CONTEXT_DIR"
    "PLANTUML_DOCKER_DOCKERFILE"
    "PLANTUML_DOCKER_IMAGE"
    "PLANTUML_DOCKER_IMAGE_FROM"

    "PLANTUML_SOURCE_DIR"
    "PLANTUML_OUTPUT_IN_DOCKER_DIR" # relative path from /data in docker and ${PLANTUML_SOURCE_DIR}
    "PLANTUML_OUTPUT_FORMAT"
  )

  readonly PLANTUML_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}plantuml:1.2024.5"
    "plantuml/plantuml:1.2024.5"

    "${APPX_DIR}"
    "./resources"
    "png" # svg
  )

  mrcore_dotenv_init_var_array PLANTUML_VARS[@] PLANTUML_VARS_DEFAULT[@]

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${PLANTUML_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_plantuml_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_plantuml_method_config() {
  mrcore_dotenv_echo_var_array PLANTUML_VARS[@]
}

function mrcmd_plugins_plantuml_method_export_config() {
  mrcore_dotenv_export_var_array PLANTUML_VARS[@]
}

function mrcmd_plugins_plantuml_method_install() {
  mrcmd_plugins_plantuml_docker_build --no-cache
}

function mrcmd_plugins_plantuml_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_plantuml_method_config
      mrcmd_plugins_plantuml_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "plantuml/docker-run" "$@"
      ;;

    cmd-help)
      mrcmd_plugins_call_function "plantuml/docker-run" "-help"
      ;;

    build-all)
      mrcore_validate_dir_required "Output dir" "${PLANTUML_SOURCE_DIR}/${PLANTUML_OUTPUT_IN_DOCKER_DIR}"
      mrcmd_plugins_call_function "plantuml/docker-run" \
        "-x" "${PLANTUML_OUTPUT_IN_DOCKER_DIR}/**" \
        "-o" "${PLANTUML_OUTPUT_IN_DOCKER_DIR}/$" \
        "-t${PLANTUML_OUTPUT_FORMAT}" \
        "./**.puml"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_plantuml_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${PLANTUML_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [files]         Runs 'plantuml [files]' in a container of the image"
  echo -e "  cmd-help            Display plantuml help text"
  echo -e "  build-all           Builds all files with *.puml in the source dir"
}

# private
function mrcmd_plugins_plantuml_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${PLANTUML_DOCKER_CONTEXT_DIR}" \
    "${PLANTUML_DOCKER_DOCKERFILE}" \
    "${PLANTUML_DOCKER_IMAGE}" \
    "${PLANTUML_DOCKER_IMAGE_FROM}" \
    "$@"
}
