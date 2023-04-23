
# run: mrcmd_plugins_call_function "web-php/build-image-alpine"
function mrcmd_func_web_php_build_image_alpine() {
  local dockerFilePath="${1:?}"
  local dockerImage="${2:?}"
  local dockerImageFrom="${3:?}"
  shift; shift; shift

  local installZip="${1:?}"
  local installSockets="${2:?}"
  local installXslt="${3:?}"
  shift; shift; shift

  local installYaml="${1:?}"
  local installGd="${2:?}"
  local installMysql="${3:?}"
  shift; shift; shift

  local installPostgres="${1:?}"
  local installMongodb="${2:?}"
  local installRedis="${3:?}"
  shift; shift; shift

  local installKafka="${1:?}"
  local installXdebugVersion="${2:?}"
  shift; shift

  mrcmd_plugins_call_function "docker/build-image-user" \
    "${dockerFilePath}" \
    "${dockerImage}" \
    "${dockerImageFrom}" \
    --build-arg "INSTALL_ZIP=${installZip}" \
    --build-arg "INSTALL_SOCKETS=${installSockets}" \
    --build-arg "INSTALL_XSLT=${installXslt}" \
    --build-arg "INSTALL_YAML=${installYaml}" \
    --build-arg "INSTALL_GD=${installGd}" \
    --build-arg "INSTALL_MYSQL=${installMysql}" \
    --build-arg "INSTALL_POSTGRES=${installPostgres}" \
    --build-arg "INSTALL_MONGODB=${installMongodb}" \
    --build-arg "INSTALL_REDIS=${installRedis}" \
    --build-arg "INSTALL_KAFKA=${installKafka}" \
    --build-arg "INSTALL_XDEBUG_VERSION=${installXdebugVersion}" \
    "$@"
}
