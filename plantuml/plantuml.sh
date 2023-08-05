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
    "PLANTUML_DEST_DIR"
  )

  readonly PLANTUML_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${DOCKER_PACKAGE_NAME}plantuml:1.2023.10"
    "ghcr.io/plantuml/plantuml:1.2023.10"

    "${APPX_DIR}"
    ""
  )

  mrcore_dotenv_init_var_array PLANTUML_VARS[@] PLANTUML_VARS_DEFAULT[@]
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

    gen-all)
      local dirs
      dirs=($(cd "${PLANTUML_SOURCE_DIR}" && find . -type d))
      mrcore_debug_echo ${DEBUG_LEVEL_1} "${DEBUG_BLUE}" "PLANTUML_SOURCE_DIR(S)=$(mrcmd_lib_implode ", " dirs[@])"
      mrcmd_plugins_call_function "plantuml/docker-run" "${dirs[@]}"
      mrcmd_plugins_plantuml_move_completed
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
  echo -e "  gen-all             Runs 'plantuml ./' in a container of the image"
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

# private
function mrcmd_plugins_plantuml_move_completed() {
  if [ -n "${PLANTUML_DEST_DIR}" ] &&
    [[ "$(realpath "${PLANTUML_SOURCE_DIR}")" != "$(realpath "${PLANTUML_DEST_DIR}")" ]]; then
    find "${PLANTUML_SOURCE_DIR}" -type f -name "*.png" -exec mv -f {} "${PLANTUML_DEST_DIR}" \;
  fi
}
