
# using example: mrcmd_plugins_call_function "nginx/build-image"
function mrcmd_func_nginx_build_image() {
  local dockerImageName="${1:?}"
  local dockerImageFrom="${2:?}"
  shift; shift

  local serviceType="${1:?}"
  local serviceDomain="${2:?}"
  local serviceHost="${3:?}"
  local servicePort="${4:?}"
  shift; shift; shift; shift

  mrcmd_plugins_call_function "docker/build-image" \
    "${NGINX_DOCKER_CONTEXT_DIR}" \
    "${NGINX_DOCKER_DOCKERFILE}" \
    "${dockerImageName}" \
    "${dockerImageFrom}" \
    --build-arg "SERVICE_TYPE=${serviceType}" \
    --build-arg "SERVICE_DOMAIN=${serviceDomain}" \
    --build-arg "SERVICE_HOST=${serviceHost}" \
    --build-arg "SERVICE_PORT=${servicePort}" \
    "$@"
}
