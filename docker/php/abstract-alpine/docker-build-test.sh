#!/bin/bash


export DOCKER_IMAGE_FROM=php:8.1.12-alpine3.16
export DOCKER_IMAGE_NAME=image-test-abstract-alpine-${DOCKER_IMAGE_FROM}

export PHP_ABSTRACT_INSTALL_XDEBUG_VERSION=3.1.5
export HOST_USER_ID=1000
export HOST_GROUP_ID=1000

bash ./docker-build.sh
# docker run -it --rm ${DOCKER_IMAGE_PHP_CUSTOM} sh
