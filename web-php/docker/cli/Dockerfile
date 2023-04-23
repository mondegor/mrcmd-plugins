ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

RUN apk add --no-cache git

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

RUN mkdir -m 0755 /usr/bin-tools
ENV PATH="${PATH}:/usr/bin-tools"

USER www-data

WORKDIR /opt/app
