# https://hub.docker.com/_/php

function mrcmd_plugins_phive_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker")
}

function mrcmd_plugins_phive_method_init() {
  readonly PHIVE_NAME="Phive - PHP tool for phar archives"

  readonly PHIVE_VARS=(
    "PHIVE_DOCKER_CONFIG_DOCKERFILE"
    "PHIVE_DOCKER_IMAGE"
    "PHIVE_DOCKER_IMAGE_FROM"

    "PHIVE_TOOLS_DIR"

    "PHIVE_TOOL_INSTALL_COMPOSER_VERSION"
    "PHIVE_TOOL_INSTALL_PHPUNIT_VERSION"
    "PHIVE_TOOL_INSTALL_PHAN_VERSION"
    "PHIVE_TOOL_INSTALL_PSALM_VERSION"
    "PHIVE_TOOL_INSTALL_PHPSTAN_VERSION"
    "PHIVE_TOOL_INSTALL_PHPCS_VERSION"
    "PHIVE_TOOL_INSTALL_PHPCBF_VERSION"
    "PHIVE_TOOL_INSTALL_PHPCSFIXER_VERSION"
  )

  readonly PHIVE_VARS_DEFAULT=(
    "${MRCMD_DIR}/plugins/phive/docker"
    "phive-php:8.1.18-alpine3.17"
    "php:8.1.18-alpine3.17"

    "${APPX_APP_DIR}/bin-tools"

    "2.5.5"
    "9.6.5"
    "5.4.2"
    "5.9.0"
    "1.10.13"
    "3.7.2"
    "3.7.2"
    "3.16.0"
  )

  mrcore_dotenv_init_var_array PHIVE_VARS[@] PHIVE_VARS_DEFAULT[@]
}

function mrcmd_plugins_phive_method_config() {
  mrcore_dotenv_echo_var_array PHIVE_VARS[@]
}

function mrcmd_plugins_phive_method_export_config() {
  mrcore_dotenv_export_var_array PHIVE_VARS[@]
}

function mrcmd_plugins_phive_method_install() {
  mrcore_lib_mkdir "${PHIVE_TOOLS_DIR}"
  mrcmd_plugins_phive_docker_build --no-cache
  mrcmd_plugins_phive_download_tools
}

function mrcmd_plugins_phive_method_uninstall() {
  mrcore_lib_rmdir "${PHIVE_TOOLS_DIR}"
}

function mrcmd_plugins_phive_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array PHIVE_VARS[@]
      mrcmd_plugins_phive_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "phive/docker-cli" "$@"
      ;;

    download)
      mrcmd_plugins_phive_download_tools
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_phive_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  docker-build                Builds or rebuilds the image ${PHIVE_DOCKER_IMAGE}"
  echo -e "  cli                         Enters to phive cli in a container of image ${CC_GREEN}${PHIVE_DOCKER_IMAGE}${CC_END}"
  echo -e "  download                    Download the checked tools to ${CC_BLUE}${PHIVE_TOOLS_DIR}${CC_END}"
}

# private
function mrcmd_plugins_phive_docker_build() {
  mrcmd_plugins_call_function "docker/build-image-user" \
    "${PHIVE_DOCKER_CONFIG_DOCKERFILE}" \
    "${PHIVE_DOCKER_IMAGE}" \
    "${PHIVE_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_phive_download_tools() {
  local toolsArray=(
    "composer" "${PHIVE_TOOL_INSTALL_COMPOSER_VERSION}" "CBB3D576F2A0946F"
    "phpunit" "${PHIVE_TOOL_INSTALL_PHPUNIT_VERSION}" "4AA394086372C20A"
    "phan" "${PHIVE_TOOL_INSTALL_PHAN_VERSION}" "8101FB57DD8130F0"
    "psalm" "${PHIVE_TOOL_INSTALL_PSALM_VERSION}" "12CE0F1D262429A5"
    "phpstan" "${PHIVE_TOOL_INSTALL_PHPSTAN_VERSION}" "51C67305FFC2E5C0"
    "phpcs" "${PHIVE_TOOL_INSTALL_PHPCS_VERSION}" "31C7E470E2138192"
    "phpcbf" "${PHIVE_TOOL_INSTALL_PHPCBF_VERSION}" "31C7E470E2138192"
    "php-cs-fixer" "${PHIVE_TOOL_INSTALL_PHPCSFIXER_VERSION}" "E82B2FB314E9906E"
  )

  mrcmd_plugins_call_function "phive/download-tools" toolsArray[@]
}
