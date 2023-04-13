# https://hub.docker.com/_/node

ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ARG INSTALL_BASH
ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN if [[ "${INSTALL_BASH}" == true ]]; then \
      apk add --no-cache bash; \
    fi;

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} node \
      && usermod -o -u ${HOST_USER_ID} -g node node; \
    fi;

WORKDIR /opt/app
# RUN chown -R node:node /opt/app

USER node
