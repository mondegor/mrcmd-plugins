# phive образ из которого извлекается phar файлы утилит
ARG DOCKER_IMAGE_PHIVE

# наследуется от php alpine того сервиса, в котором данные утилиты будут использоваться
ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE_PHIVE} as utilities-source-image

# загружаемые версии утилит
ARG PHP_INSTALL_COMPOSER_VERSION
ARG PHP_INSTALL_PHPUNIT_VERSION

RUN if [[ "${PHP_INSTALL_COMPOSER_VERSION}" != false ]]; \
    then \
      phive --no-progress install --copy --trust-gpg-keys CBB3D576F2A0946F composer@${PHP_INSTALL_COMPOSER_VERSION}; \
    fi;

RUN if [[ "${PHP_INSTALL_PHPUNIT_VERSION}" != false ]]; \
    then \
      phive --no-progress install --copy --trust-gpg-keys 4AA394086372C20A phpunit@${PHP_INSTALL_PHPUNIT_VERSION}; \
    fi;

FROM ${DOCKER_IMAGE}

RUN apk add --no-cache git

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /opt/app

USER www-data

COPY --from=utilities-source-image /opt/tools/* /usr/bin/
