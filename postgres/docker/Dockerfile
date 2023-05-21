ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG DEFAULT_SHELL

RUN if [[ ${DEFAULT_SHELL} != "sh" ]]; then \
      apk add --no-cache ${DEFAULT_SHELL}; \
    fi;

COPY postgresql.conf /etc/postgresql/postgresql.conf

#EXPOSE 5432
