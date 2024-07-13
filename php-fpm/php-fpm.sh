# https://hub.docker.com/_/php

function mrcmd_plugins_php_fpm_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global" "docker" "docker-compose" "php-alpine" "nginx")
}

function mrcmd_plugins_php_fpm_method_init() {
  readonly PHP_FPM_CAPTION="PHP FPM"
  readonly PHP_FPM_DOCKER_SERVICE="web-app"
  readonly PHP_FPM_NGINX_DOCKER_SERVICE="web-app-nginx"

  readonly PHP_FPM_VARS=(
    "READONLY_PHP_FPM_DOCKER_HOST"
    "PHP_FPM_DOCKER_CONTAINER"
    "PHP_FPM_DOCKER_CONTEXT_DIR"
    "PHP_FPM_DOCKER_DOCKERFILE"
    "PHP_FPM_DOCKER_COMPOSE_CONFIG_DIR"
    "PHP_FPM_DOCKER_IMAGE"
    "PHP_FPM_DOCKER_IMAGE_FROM"
    "PHP_FPM_ALPINE_DOCKER_IMAGE_FROM"

    "READONLY_PHP_FPM_NGINX_DOCKER_HOST"
    "PHP_FPM_NGINX_DOCKER_CONTAINER"
    "PHP_FPM_NGINX_DOCKER_IMAGE"
    "PHP_FPM_NGINX_DOCKER_IMAGE_FROM"

    "PHP_FPM_WEBAPP_PUBLIC_PORT"
    "PHP_FPM_WEBAPP_DOMAIN"

    "PHP_FPM_APP_ENV_FILE"

#    "WEB_PHP_DB_HOST"
#    "WEB_PHP_DB_PORT"
#    "WEB_PHP_DB_NAME"
#    "WEB_PHP_DB_USER"
#    "WEB_PHP_DB_PASSWORD"
#
#    "WEB_PHP_REDIS_HOST"
#    "WEB_PHP_REDIS_PORT"
#    "WEB_PHP_REDIS_PASSWORD"
  )

  readonly PHP_FPM_VARS_DEFAULT=(
    "${PHP_FPM_DOCKER_SERVICE}"
    "${APPX_ID}-${PHP_FPM_DOCKER_SERVICE}"
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker-compose"
    "${DOCKER_PACKAGE_NAME}php-fpm:8.2.11"
    "${DOCKER_PACKAGE_NAME}php-fpm-alpine:8.2.11"
    "php:8.2.11-fpm-alpine3.18"

    "${PHP_FPM_NGINX_DOCKER_SERVICE}"
    "${APPX_ID}-${PHP_FPM_NGINX_DOCKER_SERVICE}"
    "${DOCKER_PACKAGE_NAME}nginx-php-fpm:1.27.0"
    "nginx:1.27.0-alpine3.19"

    "127.0.0.1:8080"
    "web-app.local"

    "${APPX_DIR}/.env.app"

#    "${APPX_DB_HOST:-db-postgres}"
#    "${APPX_DB_PORT:-5432}"
#    "${APPX_DB_NAME:-db_app}"
#    "${APPX_DB_USER:-user_app}"
#    "${APPX_DB_PASSWORD:-12345}"
#
#    "${APPX_REDIS_HOST:-db-redis}"
#    "${APPX_REDIS_PORT:-6379}"
#    "${APPX_REDIS_PASSWORD:-12345}"
  )

  mrcore_dotenv_init_var_array PHP_FPM_VARS[@] PHP_FPM_VARS_DEFAULT[@]

  mrcmd_plugins_call_function "docker-compose/register" \
    "${PHP_FPM_DOCKER_COMPOSE_CONFIG_DIR}/web-app.yaml" \
    "${PHP_FPM_APP_ENV_FILE}" \
    "${PHP_FPM_DOCKER_COMPOSE_CONFIG_DIR}/env-file.yaml"

  if [[ "${DOCKER_IS_ENABLED}" == false ]]; then
    mrcore_echo_warning "Command 'docker' not installed, so plugin '${PHP_FPM_CAPTION}' was deactivated"
  fi
}

function mrcmd_plugins_php_fpm_method_canexec() {
  mrcmd_plugins_docker_method_canexec "${1:?}"
}

function mrcmd_plugins_php_fpm_method_config() {
  mrcore_dotenv_echo_var_array PHP_ALPINE_VARS[@]
  mrcore_dotenv_echo_var_array PHP_FPM_VARS[@]
}

function mrcmd_plugins_php_fpm_method_export_config() {
  mrcore_dotenv_export_var_array PHP_FPM_VARS[@]
}

function mrcmd_plugins_php_fpm_method_install() {
  mrcmd_plugins_php_fpm_alpine_docker_build --no-cache
  mrcmd_plugins_php_fpm_docker_build --no-cache
  mrcmd_plugins_php_fpm_nginx_docker_build --no-cache
}

function mrcmd_plugins_php_fpm_method_exec() {
  local currentCommand="${1:?}"
  shift

  case "${currentCommand}" in

    docker-build)
      mrcmd_plugins_php_fpm_method_config
      mrcmd_plugins_php_fpm_alpine_docker_build "$@"
      mrcmd_plugins_php_fpm_docker_build "$@"
      mrcmd_plugins_php_fpm_nginx_docker_build "$@"
      ;;

    into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${PHP_FPM_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${PHP_FPM_DOCKER_SERVICE}"
      ;;

    restart)
      mrcmd_plugins_call_function "docker-compose/command-restart" \
        "${PHP_FPM_DOCKER_CONTAINER}" \
        "${PHP_FPM_DOCKER_SERVICE}"
      ;;

    ng-into)
      mrcmd_plugins_call_function "docker-compose/command-exec-shell" \
        "${PHP_FPM_NGINX_DOCKER_SERVICE}" \
        sh # shell name
      ;;

    ng-logs)
      mrcmd_plugins_call_function "docker-compose/command" logs --no-log-prefix --follow "${PHP_FPM_NGINX_DOCKER_SERVICE}"
      ;;

    *)
      ${RETURN_UNKNOWN_COMMAND}
      ;;

  esac
}

function mrcmd_plugins_php_fpm_method_help() {
  #markup:"|-|-|---------|-------|-------|---------------------------------------|"
  echo -e "${CC_YELLOW}Docker commands for ${CC_GREEN}${JAVA_DOCKER_IMAGE}${CC_YELLOW}:${CC_END}"
  echo -e "  docker-build        Builds or rebuilds the image"
  echo -e ""
  echo -e "${CC_YELLOW}Docker compose commands for ${CC_GREEN}${JAVA_DOCKER_CONTAINER}${CC_YELLOW}:${CC_END}"
  echo -e "  into        Enters to shell in the running container"
  echo -e "  logs        View output from the running container"
  echo -e "  restart     Restarts the container"
  echo -e "  ng-into     Enters to shell in the running nginx container"
  echo -e "  ng-logs     View output from the running nginx container"
}

# private
function mrcmd_plugins_php_fpm_alpine_docker_build() {
  mrcmd_plugins_call_function "php-alpine/build-image" \
    "${PHP_FPM_DOCKER_IMAGE_FROM}" \
    "${PHP_FPM_ALPINE_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
function mrcmd_plugins_php_fpm_docker_build() {
  mrcmd_plugins_call_function "docker/build-image" \
    "${PHP_FPM_DOCKER_CONTEXT_DIR}" \
    "${PHP_FPM_DOCKER_DOCKERFILE}" \
    "${PHP_FPM_DOCKER_IMAGE}" \
    "${PHP_FPM_DOCKER_IMAGE_FROM}" \
    "$@"
}

# private
# web-php - nginx SERVICE_TYPE
function mrcmd_plugins_php_fpm_nginx_docker_build() {
  mrcmd_plugins_call_function "nginx/build-image" \
    "${PHP_FPM_NGINX_DOCKER_IMAGE}" \
    "${PHP_FPM_NGINX_DOCKER_IMAGE_FROM}" \
    "web-php" \
    "${PHP_FPM_DOCKER_SERVICE}" \
    "9000" \
    "$@"
}
