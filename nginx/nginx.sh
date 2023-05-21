# https://hub.docker.com/_/nginx

function mrcmd_plugins_nginx_method_init() {
  readonly NGINX_CAPTION="Nginx"

  readonly NGINX_VARS=(
    "NGINX_DOCKER_CONFIG_DOCKERFILE"
  )

  readonly NGINX_VARS_DEFAULT=(
    "${MRCMD_PLUGINS_DIR}/nginx/docker"
  )

  mrcore_dotenv_init_var_array NGINX_VARS[@] NGINX_VARS_DEFAULT[@]
}

function mrcmd_plugins_nginx_method_config() {
  mrcore_dotenv_echo_var_array NGINX_VARS[@]
}

function mrcmd_plugins_nginx_method_export_config() {
  mrcore_dotenv_export_var_array NGINX_VARS[@]
}
