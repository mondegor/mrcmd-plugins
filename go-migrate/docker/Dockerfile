# https://hub.docker.com/r/migrate/migrate

ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN addgroup -g 1000 golang && adduser -u 1000 -G golang -s /bin/sh -D golang

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} golang \
      && usermod -o -u ${HOST_USER_ID} -g golang golang; \
    fi;

WORKDIR /migrations
# RUN chown -R golang:golang /migrations

USER golang
