ARG DOCKER_IMAGE_FROM=php:8.2.11-cli-alpine3.18

FROM ${DOCKER_IMAGE_FROM}

ARG INSTALL_BASE_TOOL
ARG COMPOSER_SETUP_HASH
ARG COMPOSER_VERSION

RUN apk add --no-cache git

RUN if [[ "${INSTALL_BASE_TOOL}" == "phive" ]]; then \
      apk add --no-cache gnupg wget \
      && wget -O phive.phar https://phar.io/releases/phive.phar \
      && wget -O phive.phar.asc https://phar.io/releases/phive.phar.asc \
      && gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x9D8A98B29B2D5D79 \
      && gpg --verify phive.phar.asc phive.phar \
      && chmod +x phive.phar \
      && mv phive.phar /usr/local/bin/phive \
      && rm phive.phar.asc \
      && phive install --copy --target /usr/local/bin --trust-gpg-keys "CBB3D576F2A0946F" "composer@${COMPOSER_VERSION}" \
      && rm -R .phive; \
    elif [[ "${INSTALL_BASE_TOOL}" == "composer" ]]; then \
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
      && php -r "if (hash_file('sha384', 'composer-setup.php') === '${COMPOSER_SETUP_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
      && php composer-setup.php --version=${COMPOSER_VERSION} \
      && php -r "unlink('composer-setup.php');" \
      && chmod +x composer.phar \
      && mv composer.phar /usr/local/bin/composer; \
    fi;

COPY php.ini /usr/local/etc/php/php.ini
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

USER www-data

WORKDIR /opt/app
