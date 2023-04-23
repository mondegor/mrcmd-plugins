ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN apk add --no-cache gnupg wget

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} www-data \
      && usermod -o -u ${HOST_USER_ID} -g www-data www-data; \
    fi;

WORKDIR /opt
RUN mkdir -m 0755 /opt/tools
RUN chown -R www-data:www-data /opt /usr/local/bin

USER www-data

RUN wget -O phive.phar https://phar.io/releases/phive.phar \
    && wget -O phive.phar.asc https://phar.io/releases/phive.phar.asc

RUN gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x9D8A98B29B2D5D79 \
    && gpg --verify phive.phar.asc phive.phar

RUN chmod +x phive.phar \
    && mv phive.phar /usr/local/bin/phive

ENTRYPOINT ["phive"]
