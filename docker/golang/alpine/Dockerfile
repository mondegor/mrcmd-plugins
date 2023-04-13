ARG DOCKER_IMAGE
FROM ${DOCKER_IMAGE}

ARG ALPINE_INSTALL_BASH
ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN apk add --no-cache git

RUN addgroup -g 1000 golang && adduser -u 1000 -G golang -s /bin/sh -D golang

RUN chown -R golang:golang /go

RUN if [[ "${ALPINE_INSTALL_BASH}" == true ]]; \
    then \
      apk add --no-cache bash; \
    fi;

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; \
    then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} golang \
      && usermod -o -u ${HOST_USER_ID} -g golang golang; \
    fi;

WORKDIR /opt/app

USER golang
