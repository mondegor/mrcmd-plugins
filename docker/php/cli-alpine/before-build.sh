
docker_php_cli_alpine_before_build() {
  local dockerImagePhive=${1:?}
  local composerVersion=${2:?}
  local phpUnitVersion=${3:?}

  echo -e "${CC_YELLOW}PHIVE IMAGE:${CC_END} ${CC_GREEN}${dockerImagePhive}${CC_END}"
  echo -e "${CC_YELLOW}COMPOSER VERSION:${CC_END} ${CC_GREEN}${composerVersion}${CC_END}"
  echo -e "${CC_YELLOW}PHPUNIT VERSION:${CC_END} ${CC_GREEN}${phpUnitVersion}${CC_END}"

  DOCKER_BUILD_PARAMS_RESULT="--build-arg DOCKER_IMAGE_PHIVE=${dockerImagePhive} \
                              --build-arg PHP_INSTALL_COMPOSER_VERSION=${composerVersion} \
                              --build-arg PHP_INSTALL_PHPUNIT_VERSION=${phpUnitVersion}"
}
