# https://hub.docker.com/_/nginx
# https://nginx.org/en/docs/ngx_core_module.html
# https://docs.nginx.com/nginx/admin-guide/web-server/web-server

function mrcmd_plugins_nginx_method_init() {
  readonly NGINX_CAPTION="Nginx"

  readonly NGINX_VARS=(
    "NGINX_DOCKER_CONTEXT_DIR"
    "NGINX_DOCKER_DOCKERFILE"
  )

  readonly NGINX_VARS_DEFAULT=(
    "${MRCMD_CURRENT_PLUGIN_DIR}/docker"
    ""
  )

  mrcore_dotenv_init_var_array NGINX_VARS[@] NGINX_VARS_DEFAULT[@]
}

function mrcmd_plugins_nginx_method_config() {
  mrcore_dotenv_echo_var_array NGINX_VARS[@]
}

function mrcmd_plugins_nginx_method_export_config() {
  mrcore_dotenv_export_var_array NGINX_VARS[@]
}
