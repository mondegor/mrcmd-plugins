# https://hub.docker.com/_/php

function mrcmd_plugins_web_php_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "nginx" "phive")
}

function mrcmd_plugins_web_php_method_init() {
  readonly WEB_PHP_NAME="PHP Web App"

  readonly WEB_PHP_VARS=(
    "WEB_PHP_DOCKER_CONTAINER"
    "WEB_PHP_DOCKER_SERVICE"
    "WEB_PHP_ALPINE_DOCKER_CONFIG_DOCKERFILE"
    "WEB_PHP_DOCKER_CONFIG_DOCKERFILE"
    "WEB_PHP_CLI_DOCKER_CONFIG_DOCKERFILE"
    "WEB_PHP_DOCKER_COMPOSE_CONFIG_DIR"
    "WEB_PHP_ALPINE_DOCKER_IMAGE_FROM"
    "WEB_PHP_DOCKER_IMAGE_FROM"
    "WEB_PHP_DOCKER_IMAGE"
    "WEB_PHP_CLI_DOCKER_IMAGE"

    "WEB_PHP_INSTALL_ZIP"
    "WEB_PHP_INSTALL_SOCKETS"
    "WEB_PHP_INSTALL_XSLT"
    "WEB_PHP_INSTALL_YAML"
    "WEB_PHP_INSTALL_GD"
    "WEB_PHP_INSTALL_MYSQL"
    "WEB_PHP_INSTALL_POSTGRES"
    "WEB_PHP_INSTALL_MONGODB"
    "WEB_PHP_INSTALL_REDIS"
    "WEB_PHP_INSTALL_KAFKA"
    "WEB_PHP_INSTALL_XDEBUG_VERSION"

    "WEB_PHP_NGINX_DOCKER_CONTAINER"
    "WEB_PHP_NGINX_DOCKER_IMAGE"
    "WEB_PHP_APPX_PUBLIC_PORT"
    "WEB_PHP_APPX_DOMAIN"

    "WEB_PHP_WORK_DIR"
    "WEB_PHP_APPX_TOOLS_DIR"

    "WEB_PHP_DB_HOST"
    "WEB_PHP_DB_PORT"
    "WEB_PHP_DB_NAME"
    "WEB_PHP_DB_USER"
    "WEB_PHP_DB_PASSWORD"

    "WEB_PHP_REDIS_HOST"
    "WEB_PHP_REDIS_PORT"
    "WEB_PHP_REDIS_PASSWORD"
  )

  readonly WEB_PHP_VARS_DEFAULT=(
    "${APPX_ID}-web-app"
    "web-app"
    "${MRCMD_DIR}/plugins/web-php/docker/alpine"
    "${MRCMD_DIR}/plugins/web-php/docker/fpm"
    "${MRCMD_DIR}/plugins/web-php/docker/cli"
    "${MRCMD_DIR}/plugins/web-php/docker-compose"
    "php:8.1.18-fpm-alpine3.17"
    "${APPX_ID}-php"
    "${APPX_ID}-web-php"
    "${APPX_ID}-web-php-cli"

    "false"
    "false"
    "false"
    "false"
    "false"
    "false"
    "false"
    "false"
    "false"
    "false"
    "false"

    "${APPX_ID}-web-app-nginx"
    "${APPX_ID}-php-nginx"
    "127.0.0.1:8080"
    "web-app.local"

    "$(realpath "${APPX_DIR}")/app"
    "${PHIVE_TOOLS_DIR}"

    "${APPX_DB_HOST:-db-postgres}"
    "${APPX_DB_PORT:-5432}"
    "${APPX_DB_NAME:-db_app}"
    "${APPX_DB_USER:-user_app}"
    "${APPX_DB_PASSWORD:-12345}"

    "${APPX_REDIS_HOST:-db-redis}"
    "${APPX_REDIS_PORT:-6379}"
    "${APPX_REDIS_PASSWORD:-12345}"
  )

  mrcore_dotenv_init_var_array WEB_PHP_VARS[@] WEB_PHP_VARS_DEFAULT[@]

  DOCKER_COMPOSE_CONFIG_FILES_ARRAY+=("${WEB_PHP_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml")
}

function mrcmd_plugins_web_php_method_config() {
  mrcore_dotenv_echo_var_array WEB_PHP_VARS[@]
}

function mrcmd_plugins_web_php_method_export_config() {
  mrcore_dotenv_export_var_array WEB_PHP_VARS[@]
}

function mrcmd_plugins_web_php_method_install() {
  mrcore_lib_mkdir "${WEB_PHP_WORK_DIR}/vendor"
  mrcore_lib_mkdir "${WEB_PHP_APPX_TOOLS_DIR}"
  mrcore_lib_mkdir "${WEB_PHP_WORK_DIR}/var"

  mrcmd_plugins_web_php_alpine_docker_build --no-cache
  mrcmd_plugins_web_php_docker_build --no-cache
  mrcmd_plugins_web_php_cli_docker_build --no-cache
  mrcmd_plugins_web_php_nginx_docker_build --no-cache
  mrcmd_plugins_call_function "web-php/docker-cli" composer install --no-interaction
}

function mrcmd_plugins_web_php_method_uninstall() {
  mrcore_lib_mkdir "${WEB_PHP_APPX_TOOLS_DIR}"
  mrcore_lib_rmdir "${WEB_PHP_WORK_DIR}/vendor"
  mrcore_lib_rmdir "${WEB_PHP_WORK_DIR}/var"
  mrcore_lib_rm "${WEB_PHP_WORK_DIR}/.phpunit.result.cache"
}

function mrcmd_plugins_web_php_method_exec() {
  local currentCommand="${1:?}"
  shift

  case ${currentCommand} in

    docker-build)
      mrcore_dotenv_echo_var_array WEB_PHP_VARS[@]
      mrcmd_plugins_web_php_alpine_docker_build "$@"
      mrcmd_plugins_web_php_docker_build "$@"
      mrcmd_plugins_web_php_cli_docker_build "$@"
      mrcmd_plugins_web_php_nginx_docker_build "$@"
      ;;

    cli)
      mrcmd_plugins_call_function "web-php/docker-cli" php "$@"
      ;;

    composer | phan | php-cs-fixer | phpcbf | phpcs | phpstan | phpunit | psalm)
      mrcmd_plugins_call_function "web-php/docker-cli" "${currentCommand}" "$@"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${WEB_PHP_DOCKER_CONTAINER}" \
        "${WEB_PHP_DOCKER_SERVICE}"
      ;;

    shell)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${WEB_PHP_DOCKER_SERVICE}" \
        "${ALPINE_INSTALL_BASH}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_web_php_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Commands:${CC_END}"
  echo -e "  cli                         Build"
  echo -e "  cli -m                      PHP modules"

  echo -e "  composer                    Build"
  echo -e "  phan                        Build"
  echo -e "  php-cs-fixer                Build"
  echo -e "  phpcbf                      Build"
  echo -e "  phpcs                       Build"
  echo -e "  phpstan                     Build"
  echo -e "  phpunit                     Build"
  echo -e "  psalm                       Build"

  echo -e "    down                      Rollback migrations against non test DB"
  echo -e "    create                    Create a DB migration files e.g 'make migrate-create name=migration-name'"
}

# private
function mrcmd_plugins_web_php_alpine_docker_build() {
  mrcmd_plugins_call_function "web-php/build-image-alpine" \
    "${WEB_PHP_ALPINE_DOCKER_CONFIG_DOCKERFILE}" \
    "${WEB_PHP_DOCKER_IMAGE_FROM}" \
    "${WEB_PHP_ALPINE_DOCKER_IMAGE_FROM}" \
    "${WEB_PHP_INSTALL_ZIP}" \
    "${WEB_PHP_INSTALL_SOCKETS}" \
    "${WEB_PHP_INSTALL_XSLT}" \
    "${WEB_PHP_INSTALL_YAML}" \
    "${WEB_PHP_INSTALL_GD}" \
    "${WEB_PHP_INSTALL_MYSQL}" \
    "${WEB_PHP_INSTALL_POSTGRES}" \
    "${WEB_PHP_INSTALL_MONGODB}" \
    "${WEB_PHP_INSTALL_REDIS}" \
    "${WEB_PHP_INSTALL_KAFKA}" \
    "${WEB_PHP_INSTALL_XDEBUG_VERSION}" \
    "$@"
}

# private
function mrcmd_plugins_web_php_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${WEB_PHP_DOCKER_CONFIG_DOCKERFILE}" \
    "${WEB_PHP_DOCKER_IMAGE}" \
    "${WEB_PHP_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_web_php_cli_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${WEB_PHP_CLI_DOCKER_CONFIG_DOCKERFILE}" \
    "${WEB_PHP_CLI_DOCKER_IMAGE}" \
    "${WEB_PHP_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_web_php_nginx_docker_build() {
  mrcmd_plugins_call_function "nginx/docker-build-image" \
    "${NGINX_DOCKER_CONFIG_DOCKERFILE}" \
    "${WEB_PHP_NGINX_DOCKER_IMAGE}" \
    "${NGINX_DOCKER_IMAGE_FROM}" \
    "php" \
    "${WEB_PHP_APPX_DOMAIN}" \
    "${WEB_PHP_DOCKER_SERVICE}" \
    "9000" \
    "$@"
}
