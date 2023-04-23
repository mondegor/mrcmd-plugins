
# run: mrcmd_plugins_call_function "nginx/docker-build-image"
function mrcmd_func_nginx_docker_build_image() {
  local dockerFilePath="${1:?}"
  local dockerImageName="${2:?}"
  local dockerImageFrom="${3:?}"
  shift; shift; shift

  local serviceType="${1:?}"
  local serviceDomain="${2:?}"
  local serviceHost="${3:?}"
  local servicePort="${4:?}"
  shift; shift; shift; shift

  mrcmd_plugins_call_function "docker/build-image" \
    "${dockerFilePath}" \
    "${dockerImageName}" \
    "${dockerImageFrom}" \
    --build-arg "SERVICE_TYPE=${serviceType}" \
    --build-arg "SERVICE_DOMAIN=${serviceDomain}" \
    --build-arg "SERVICE_HOST=${serviceHost}" \
    --build-arg "SERVICE_PORT=${servicePort}" \
    "$@"
}
