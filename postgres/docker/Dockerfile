# https://hub.docker.com/_/postgres

ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ARG INSTALL_BASH

RUN if [[ "${INSTALL_BASH}" == true ]]; then \
      apk add --no-cache bash; \
    fi;

COPY postgresql.conf /etc/postgresql/postgresql.conf

#EXPOSE 5432
