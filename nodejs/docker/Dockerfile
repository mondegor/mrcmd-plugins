ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG DEFAULT_SHELL
ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN if [[ ${DEFAULT_SHELL} != "sh" ]]; then \
      apk add --no-cache ${DEFAULT_SHELL}; \
    fi;

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} node \
      && usermod -o -u ${HOST_USER_ID} -g node node; \
    fi;

WORKDIR /opt/app
RUN chown -R node:node /opt/app

#USER node

CMD ["/bin/${DEFAULT_SHELL}"]