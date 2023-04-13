#!/bin/bash
set -ex

ROOT_DIR=$(dirname $0)

export DOCKER_IMAGE_PHP_CLI=php:8.1.12-alpine3.16
export DOCKER_IMAGE_PHIVE=image-test-phive-${DOCKER_IMAGE_PHP_CLI}

cd ${ROOT_DIR} && bash ./docker-build.sh
docker run -it --rm ${DOCKER_IMAGE_PHIVE} --no-progress install --copy --trust-gpg-keys CBB3D576F2A0946F composer@2.5.5
