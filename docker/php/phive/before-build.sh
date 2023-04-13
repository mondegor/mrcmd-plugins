
docker_php_phive_before_build() {
  mrcore_dotenv_echo_var HOST_USER_ID
  mrcore_dotenv_echo_var HOST_GROUP_ID

  DOCKER_BUILD_PARAMS_RESULT="--build-arg HOST_USER_ID=${HOST_USER_ID:-0}
                              --build-arg HOST_GROUP_ID=${HOST_GROUP_ID:-0}"
}
