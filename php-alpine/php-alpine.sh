# https://hub.docker.com/_/php

function mrcmd_plugins_php_alpine_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("docker")
}

function mrcmd_plugins_php_alpine_method_init() {
  readonly PHP_ALPINE_CAPTION="PHP Abstract Alpine"
  readonly PHP_ALPINE_DOCKER_SERVICE="php-alpine"

  readonly PHP_ALPINE_VARS=(
    "PHP_ALPINE_DOCKER_CONFIG_DOCKERFILE"

    "PHP_ALPINE_INSTALL_ZIP"
    "PHP_ALPINE_INSTALL_SOCKETS"
    "PHP_ALPINE_INSTALL_XSLT"
    "PHP_ALPINE_INSTALL_YAML"
    "PHP_ALPINE_INSTALL_GD"
    "PHP_ALPINE_INSTALL_MYSQL"
    "PHP_ALPINE_INSTALL_POSTGRES"
    "PHP_ALPINE_INSTALL_MONGODB"
    "PHP_ALPINE_INSTALL_REDIS"
    "PHP_ALPINE_INSTALL_KAFKA"
    "PHP_ALPINE_INSTALL_XDEBUG_VERSION"
  )

  readonly PHP_ALPINE_VARS_DEFAULT=(
    "${MRCMD_PLUGINS_DIR}/php-alpine/docker"

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
  )

  mrcore_dotenv_init_var_array PHP_ALPINE_VARS[@] PHP_ALPINE_VARS_DEFAULT[@]
}

function mrcmd_plugins_php_alpine_method_config() {
  mrcore_dotenv_echo_var_array PHP_ALPINE_VARS[@]
}

function mrcmd_plugins_php_alpine_method_export_config() {
  mrcore_dotenv_export_var_array PHP_ALPINE_VARS[@]
}