# наследуется от php alpine образа, пример: DOCKER_IMAGE=php:8.1.12-alpine3.16
ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ARG ALPINE_INSTALL_BASH
ARG PHP_INSTALL_ZIP
ARG PHP_INSTALL_SOCKETS
ARG PHP_INSTALL_XSLT
ARG PHP_INSTALL_YAML
ARG PHP_INSTALL_GD
#ARG PHP_INSTALL_IMAGICK
ARG PHP_INSTALL_MYSQL
ARG PHP_INSTALL_POSTGRES
ARG PHP_INSTALL_MONGODB
ARG PHP_INSTALL_REDIS
ARG PHP_INSTALL_KAFKA
ARG PHP_INSTALL_XDEBUG_VERSION

ARG HOST_USER_ID
ARG HOST_GROUP_ID

# install base packages
RUN apk add --no-cache oniguruma-dev curl

# :TODO: curl уже есть в базовом имидже!!

## oniguruma-dev ??????????

RUN if [[ "${ALPINE_INSTALL_BASH}" == true ]]; \
    then \
      apk add --no-cache bash; \
    fi;

# install Zip, Bz2 libs
RUN if [[ "${PHP_INSTALL_ZIP}" == true ]]; \
    then \
      apk add --no-cache bzip2-dev libzip-dev \
      && docker-php-ext-install bz2 zip; \
    fi;

# install Sockets lib (for rabbitmq)
RUN if [[ "${PHP_INSTALL_SOCKETS}" == true ]]; \
    then \
      docker-php-ext-install sockets; \
    fi;

# install XSLT lib
RUN if [[ "${PHP_INSTALL_XSLT}" == true ]]; \
    then \
      apk add --no-cache libxslt-dev \
      && docker-php-ext-install xsl; \
    fi;

# install Yaml lib
RUN if [[ "${PHP_INSTALL_YAML}" == true ]]; \
    then \
      apk add --no-cache ${PHPIZE_DEPS} yaml-dev \
      && pecl install yaml \
      && docker-php-ext-enable yaml \
      && apk del --no-cache ${PHPIZE_DEPS} \
      && rm -rf /tmp/pear; \
    fi;

# install GD lib
RUN if [[ "${PHP_INSTALL_GD}" == true ]]; \
    then \
      apk add --no-cache freetype-dev libpng-dev libpng libjpeg-turbo-dev libjpeg-turbo \
      && docker-php-ext-configure gd --with-freetype --with-jpeg \
      && docker-php-ext-install -j$(nproc) gd; \
    fi;

# install imagick lib
#RUN if [ ${PHP_INSTALL_IMAGICK} = true ]; \
#    then \
#      apk add --no-cache ${PHPIZE_DEPS} imagemagick-dev imagemagick \
#      && pecl install imagick \
#      && docker-php-ext-enable imagick \
#      && apk del --no-cache ${PHPIZE_DEPS} \
#       && rm -rf /tmp/pear; \
#    fi;

# install Mysql lib
RUN if [[ "${PHP_INSTALL_MYSQL}" == true ]]; \
    then \
      docker-php-ext-install pdo_mysql mysqli; \
    fi;

# install Postgres lib
RUN if [[ "${PHP_INSTALL_POSTGRES}" == true ]]; \
    then \
      apk add --no-cache libpq-dev \
      && docker-php-ext-install pdo_pgsql pgsql; \
    fi;

# install Mongodb lib
RUN if [[ "${PHP_INSTALL_MONGODB}" == true ]]; \
    then \
      apk add --no-cache ${PHPIZE_DEPS} openssl-dev \
      && pecl install mongodb \
      && docker-php-ext-enable mongodb \
      && apk del --no-cache ${PHPIZE_DEPS} openssl-dev \
      && rm -rf /tmp/pear; \
    fi;

# install Redis lib
RUN if [[ "${PHP_INSTALL_REDIS}" == true ]]; \
    then \
      apk add --no-cache ${PHPIZE_DEPS} pcre-dev \
      && pecl install redis \
      && docker-php-ext-enable redis \
      && apk del --no-cache ${PHPIZE_DEPS} pcre-dev \
      && rm -rf /tmp/pear; \
    fi;

# install Kafka lib
RUN if [[ "${PHP_INSTALL_KAFKA}" == true ]]; \
    then \
      apk add --no-cache ${PHPIZE_DEPS} librdkafka-dev \
      && pecl install rdkafka \
      && docker-php-ext-enable rdkafka \
      && apk del --no-cache ${PHPIZE_DEPS} \
      && rm -rf /tmp/pear; \
    fi;

# install Xdebug lib
RUN if [[ "${PHP_INSTALL_XDEBUG_VERSION}" != false ]]; \
    then \
      apk add --no-cache ${PHPIZE_DEPS} \
      && pecl install xdebug-${PHP_INSTALL_XDEBUG_VERSION} \
      && docker-php-ext-enable xdebug \
      && apk del --no-cache ${PHPIZE_DEPS} \
      && rm -rf /tmp/pear; \
    fi;

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; \
    then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} www-data \
      && usermod -o -u ${HOST_USER_ID} -g www-data www-data; \
    fi;

#EXPOSE 9000
