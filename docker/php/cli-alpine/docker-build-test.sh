#!/bin/bash
#set -ex

ROOT_DIR=$PWD

export DOCKER_IMAGE_PHP_ORIGIN_ORIGIN=php:8.1.12-alpine3.16
export DOCKER_IMAGE_PHP_CUSTOM=image-test-abstract-alpine-${DOCKER_IMAGE_PHP_ORIGIN}
export DOCKER_IMAGE_PHIVE=image-test-phive-${DOCKER_IMAGE_PHP_ORIGIN}
export DOCKER_IMAGE_PHP_CLI=image-test-composer-abstract-alpine-${DOCKER_IMAGE_PHP_ORIGIN}
export PHP_INSTALL_COMPOSER_VERSION=2.5.5

cd ${ROOT_DIR}/../abstract-alpine/ && bash ./docker-build.sh
cd ${ROOT_DIR}/../phive/ && bash ./docker-build.sh
cd ${ROOT_DIR} && bash ./docker-build.sh
# docker run -it --rm ${DOCKER_IMAGE_PHP_CLI} sh
