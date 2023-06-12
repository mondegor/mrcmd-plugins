
# run: mrcmd_plugins_call_function "php-alpine/build-image"
function mrcmd_func_php_alpine_build_image() {
  local dockerImage="${1:?}"
  local dockerImageFrom="${2:?}"
  shift; shift

  mrcmd_plugins_call_function "docker/build-image-user" \
    "${PHP_ALPINE_DOCKER_CONTEXT_DIR}" \
    "${PHP_ALPINE_DOCKER_DOCKERFILE}" \
    "${dockerImage}" \
    "${dockerImageFrom}" \
    --build-arg "INSTALL_ZIP=${PHP_ALPINE_INSTALL_ZIP}" \
    --build-arg "INSTALL_SOCKETS=${PHP_ALPINE_INSTALL_SOCKETS}" \
    --build-arg "INSTALL_XSLT=${PHP_ALPINE_INSTALL_XSLT}" \
    --build-arg "INSTALL_YAML=${PHP_ALPINE_INSTALL_YAML}" \
    --build-arg "INSTALL_GD=${PHP_ALPINE_INSTALL_GD}" \
    --build-arg "INSTALL_MYSQL=${PHP_ALPINE_INSTALL_MYSQL}" \
    --build-arg "INSTALL_POSTGRES=${PHP_ALPINE_INSTALL_POSTGRES}" \
    --build-arg "INSTALL_MONGODB=${PHP_ALPINE_INSTALL_MONGODB}" \
    --build-arg "INSTALL_REDIS=${PHP_ALPINE_INSTALL_REDIS}" \
    --build-arg "INSTALL_KAFKA=${PHP_ALPINE_INSTALL_KAFKA}" \
    --build-arg "INSTALL_XDEBUG_VERSION=${PHP_ALPINE_INSTALL_XDEBUG_VERSION}" \
    "$@"
}
