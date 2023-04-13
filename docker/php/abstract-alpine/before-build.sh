
docker_php_abstract_alpine_before_build() {
  local phpInstallZip=${1:-false}
  local phpInstallSockets=${2:-false}
  local phpInstallXslt=${3:-false}
  local phpInstallYaml=${4:-false}
  local phpInstallGD=${5:-false}
  local phpInstallMysql=${6:-false}
  local phpInstallPostgres=${7:-false}
  local phpInstallMongodb=${8:-false}
  local phpInstallRedis=${9:-false}
  local phpInstallKafka=${10:-false}
  local phpInstallXdebugVersion=${11:-false}

  mrcore_dotenv_echo_var HOST_USER_ID
  mrcore_dotenv_echo_var HOST_GROUP_ID
  mrcore_echo_var "PHP_INSTALL_ZIP" ${phpInstallZip}
  mrcore_echo_var "PHP_INSTALL_SOCKETS" ${phpInstallSockets}
  mrcore_echo_var "PHP_INSTALL_XSLT" ${phpInstallXslt}
  mrcore_echo_var "PHP_INSTALL_YAML" ${phpInstallYaml}
  mrcore_echo_var "PHP_INSTALL_GD" ${phpInstallGD}
  mrcore_echo_var "PHP_INSTALL_MYSQL" ${phpInstallMysql}
  mrcore_echo_var "PHP_INSTALL_POSTGRES" ${phpInstallPostgres}
  mrcore_echo_var "PHP_INSTALL_MONGODB" ${phpInstallMongodb}
  mrcore_echo_var "PHP_INSTALL_REDIS" ${phpInstallRedis}
  mrcore_echo_var "PHP_INSTALL_KAFKA" ${phpInstallKafka}
  mrcore_echo_var "PHP_INSTALL_XDEBUG_VERSION" ${phpInstallXdebugVersion}

  DOCKER_BUILD_PARAMS_RESULT="--build-arg ALPINE_INSTALL_BASH=${ALPINE_INSTALL_BASH:-false} \
                              --build-arg PHP_INSTALL_ZIP=${phpInstallZip} \
                              --build-arg PHP_INSTALL_SOCKETS=${phpInstallSockets} \
                              --build-arg PHP_INSTALL_XSLT=${phpInstallXslt} \
                              --build-arg PHP_INSTALL_YAML=${phpInstallYaml} \
                              --build-arg PHP_INSTALL_GD=${phpInstallGD} \
                              --build-arg PHP_INSTALL_MYSQL=${phpInstallMysql} \
                              --build-arg PHP_INSTALL_POSTGRES=${phpInstallPostgres} \
                              --build-arg PHP_INSTALL_MONGODB=${phpInstallMongodb} \
                              --build-arg PHP_INSTALL_REDIS=${phpInstallRedis} \
                              --build-arg PHP_INSTALL_KAFKA=${phpInstallKafka} \
                              --build-arg PHP_INSTALL_XDEBUG_VERSION=${phpInstallXdebugVersion} \
                              --build-arg HOST_USER_ID=${HOST_USER_ID:-0} \
                              --build-arg HOST_GROUP_ID=${HOST_GROUP_ID:-0}"
}
