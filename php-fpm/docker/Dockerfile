ARG DOCKER_IMAGE_FROM=php:8.2.11-fpm-alpine3.18

FROM ${DOCKER_IMAGE_FROM}

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

USER www-data

WORKDIR /opt/app

#EXPOSE 9000
#EXPOSE 9003
