# https://symfony.com/

function mrcmd_plugins_php_symfony_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "php-cli")
}

function mrcmd_plugins_php_symfony_method_init() {
  readonly PHP_SYMFONY_CAPTION="PHP Symfony"

  readonly PHP_SYMFONY_VARS=(
    "PHP_SYMFONY_VERSION"
    "PHP_SYMFONY_TEST_PACK_VERSION"
  )

  readonly PHP_SYMFONY_DEFAULT=(
    "6.2.*"
    "1.1.*"
  )

  mrcore_dotenv_init_var_array PHP_SYMFONY_VARS[@] PHP_SYMFONY_DEFAULT[@]
}

function mrcmd_plugins_php_symfony_method_config() {
  mrcore_dotenv_echo_var_array PHP_SYMFONY_VARS[@]
}

function mrcmd_plugins_php_symfony_method_export_config() {
  mrcore_dotenv_export_var_array PHP_SYMFONY_VARS[@]
}

function mrcmd_plugins_php_symfony_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    skeleton-install)
      mrcore_validate_resource_exists "Work dir" "${APPX_WORK_DIR}"
      mrcore_lib_mkdir "${APPX_WORK_DIR}"
      mrcmd_plugins_call_function "php-cli/docker-run" composer \
        create-project \
        "symfony/skeleton:${PHP_SYMFONY_VERSION}" \
        "${APPX_WORK_DIR}"
      find "${APPX_WORK_DIR}/app" -mindepth 1 -maxdepth 1 -print0 | xargs -0 mv -t "${APPX_WORK_DIR}"
      rmdir "${APPX_WORK_DIR}/app"
      cp -aT "${MRCMD_PLUGINS_DIR}/php-symfony/v6" "${APPX_WORK_DIR}"
      ;;

    test-pack)
      mrcmd_plugins_call_function "php-cli/docker-run" composer \
        require \
        --dev \
        "symfony/test-pack:${PHP_SYMFONY_TEST_PACK_VERSION}"
      cp "${APPX_WORK_DIR}/phpunit.xml.dist" "${APPX_WORK_DIR}/phpunit.xml"
      ;;

    orm-install)
      # Do you want to include Docker configuration from recipes? n
      mrcmd_plugins_call_function "php-cli/docker-run" composer \
        require \
        symfony/orm-pack
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_php_symfony_method_help() {
  #markup:"--|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  skeleton-install    docker ps -a"
}