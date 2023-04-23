ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG INSTALL_BASH

RUN if [[ "${INSTALL_BASH}" == true ]]; then \
      apk add --no-cache bash; \
    fi;

COPY postgresql.conf /etc/postgresql/postgresql.conf

#EXPOSE 5432
