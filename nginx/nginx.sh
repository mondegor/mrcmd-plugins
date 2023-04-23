# https://hub.docker.com/_/nginx

function mrcmd_plugins_nginx_method_depends() {
  MRCMD_PLUGIN_DEPENDS_ARRAY=("global")
}

function mrcmd_plugins_nginx_method_init() {
  readonly NGINX_NAME="Nginx"

  readonly NGINX_VARS=(
    "NGINX_DOCKER_CONFIG_DOCKERFILE"
    "NGINX_DOCKER_IMAGE_FROM"
  )

  readonly NGINX_VARS_DEFAULT=(
    "${MRCMD_DIR}/plugins/nginx/docker"
    "nginx:1.23.4-alpine3.17"
  )

  mrcore_dotenv_init_var_array NGINX_VARS[@] NGINX_VARS_DEFAULT[@]
}

function mrcmd_plugins_nginx_method_config() {
  mrcore_dotenv_echo_var_array NGINX_VARS[@]
}

function mrcmd_plugins_nginx_method_export_config() {
  mrcore_dotenv_export_var_array NGINX_VARS[@]
}
