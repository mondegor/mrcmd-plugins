# https://hub.docker.com/_/php

function mrcmd_plugins_php_cli_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "php-alpine")
}

function mrcmd_plugins_php_cli_method_init() {
  readonly PHP_CLI_CAPTION="PHP Cli"

  readonly PHP_CLI_VARS=(
    "PHP_CLI_DOCKER_CONTEXT_DIR"
    "PHP_CLI_DOCKER_DOCKERFILE"
    "PHP_CLI_DOCKER_IMAGE"
    "PHP_CLI_DOCKER_IMAGE_FROM"
    "PHP_CLI_ALPINE_DOCKER_IMAGE_FROM"

    "PHP_CLI_APP_ENV_FILE"

    "PHP_CLI_TOOLS_INSTALL_BASE" # phive, composer, false
    "PHP_CLI_TOOLS_INSTALL_COMPOSER_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHPUNIT_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHAN_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PSALM_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHPSTAN_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHPCS_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHPCBF_VERSION"
    "PHP_CLI_TOOLS_INSTALL_PHPCSFIXER_VERSION"
  )

  readonly PHP_CLI_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""

    "${DOCKER_PACKAGE_NAME}php-cli:8.1.19"
    "${DOCKER_PACKAGE_NAME}php-cli-alpine:8.1.19"
    "php:8.1.19-cli-alpine3.18"

    "${APPX_DIR}/.env.app"

    "composer" # phive, composer, false
    "2.5.5" # !!!!!!!!!! not *
    "false" # "9.6.5"
    "false" # "5.4.2"
    "false" # "5.9.0"
    "false" # "1.10.13"
    "false" # "3.7.2"
    "false" # "3.7.2"
    "false" # "3.16.0"
  )

  mrcore_dotenv_init_var_array PHP_CLI_VARS[@] PHP_CLI_VARS_DEFAULT[@]
}

function mrcmd_plugins_php_cli_method_config() {
  mrcore_dotenv_echo_var_array PHP_ALPINE_VARS[@]
  mrcore_dotenv_echo_var_array PHP_CLI_VARS[@]
}

function mrcmd_plugins_php_cli_method_export_config() {
  mrcore_dotenv_export_var_array PHP_CLI_VARS[@]
}

function mrcmd_plugins_php_cli_method_install() {
  #mrcore_lib_mkdir "${APPX_WORK_DIR}/vendor"
  #mrcore_lib_mkdir "${APPX_WORK_DIR}/var"

  mrcmd_plugins_php_cli_alpine_docker_build --no-cache
  mrcmd_plugins_php_cli_docker_build --no-cache

  if [[ "${PHP_CLI_TOOLS_INSTALL_BASE}" != false ]]; then
    mrcmd_plugins_call_function "php-cli/docker-run" composer install --no-interaction
  fi
}

function mrcmd_plugins_php_cli_method_uninstall() {
  mrcore_lib_rmdir "${APPX_WORK_DIR}/vendor"
  mrcore_lib_rmdir "${APPX_WORK_DIR}/var"
  mrcore_lib_rm "${APPX_WORK_DIR}/.phpunit.result.cache"
}

function mrcmd_plugins_php_cli_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_php_cli_method_config
      mrcmd_plugins_php_cli_alpine_docker_build "$@"
      mrcmd_plugins_php_cli_docker_build "$@"
      ;;

    cmd)
      mrcmd_plugins_call_function "php-cli/docker-run" php "$@"
      ;;

    shell)
      mrcmd_plugins_call_function "php-cli/docker-run" "${DOCKER_DEFAULT_SHELL}" "$@"
      ;;

    install-tools)
      mrcmd_plugins_php_cli_install_tools
      ;;

    composer)
      mrcmd_plugins_call_function "php-cli/docker-run" composer "$@"
      ;;

    phan | php-cs-fixer | phpcs | phpcbf | phpstan | phpunit | psalm)
      mrcmd_plugins_call_function "php-cli/docker-run" "/opt/app/vendor/bin/${currentCommand}" "$@"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_php_cli_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${JAVA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e "  cmd [arguments]     Runs 'php [arguments]' in a container of the image"
  echo -e "  shell               Exec shell in a container of the image"
  echo -e "  install-tools       Downloads and installs the selected tools to ${CC_BLUE}${APPX_WORK_DIR}/vendor/bin${CC_END}"
  echo -e ""
  echo -e "${CC_YELLOW}PHP tools:${CC_END}"
  echo -e "  composer            Tool for dependency management in PHP"
  echo -e "  phan                Static analyzer that prefers to minimize false-positives"
  echo -e "  php-cs-fixer        Designed to automatically fix PHP coding standards issues"
  echo -e "  phpcs               Tokenizes PHP, JavaScript and CSS files to detect"
  echo -e "                      violations of a defined coding standard"
  echo -e "  phpcbf              Designed to automatically correct coding standard violations"
  echo -e "  phpstan             Static analysis tool that allows you to find bugs"
  echo -e "                      in your codebase without running the code"
  echo -e "  phpunit             Unit testing framework for the PHP"
  echo -e "  psalm               PHP Static Analysis Linting Machine"
}

# private
function mrcmd_plugins_php_cli_alpine_docker_build() {
  mrcmd_plugins_call_function "php-alpine/build-image" \
    "${PHP_CLI_DOCKER_IMAGE_FROM}" \
    "${PHP_CLI_ALPINE_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_php_cli_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${PHP_CLI_DOCKER_CONTEXT_DIR}" \
    "${PHP_CLI_DOCKER_DOCKERFILE}" \
    "${PHP_CLI_DOCKER_IMAGE}" \
    "${PHP_CLI_DOCKER_IMAGE_FROM}" \
    --build-arg "INSTALL_BASE_TOOL=${PHP_CLI_TOOLS_INSTALL_BASE}" \
    --build-arg "COMPOSER_VERSION=${PHP_CLI_TOOLS_INSTALL_COMPOSER_VERSION}" \
    "$@"
}

# private
function mrcmd_plugins_php_cli_install_tools() {
  local toolsArray=(
    "phpunit"      "phpunit/phpunit"           "${PHP_CLI_TOOLS_INSTALL_PHPUNIT_VERSION}" "4AA394086372C20A"
    "phan"         "phan/phan"                 "${PHP_CLI_TOOLS_INSTALL_PHAN_VERSION}" "8101FB57DD8130F0"
    "psalm"        "vimeo/psalm"               "${PHP_CLI_TOOLS_INSTALL_PSALM_VERSION}" "12CE0F1D262429A5"
    "phpstan"      "phpstan/phpstan"           "${PHP_CLI_TOOLS_INSTALL_PHPSTAN_VERSION}" "51C67305FFC2E5C0"
    "phpcs"        "squizlabs/php_codesniffer" "${PHP_CLI_TOOLS_INSTALL_PHPCS_VERSION}" "31C7E470E2138192"
    "phpcbf"       ""                          "${PHP_CLI_TOOLS_INSTALL_PHPCBF_VERSION}" "31C7E470E2138192"
    "php-cs-fixer" "friendsofphp/php-cs-fixer" "${PHP_CLI_TOOLS_INSTALL_PHPCSFIXER_VERSION}" "E82B2FB314E9906E"
  )

  mrcmd_plugins_call_function "php-cli/install-tools" toolsArray[@]
}
