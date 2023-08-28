ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG DEFAULT_SHELL
ARG SERVICE_TYPE
ARG SERVICE_DOMAIN
ARG SERVICE_HOST
ARG SERVICE_PORT

RUN if [[ ${DEFAULT_SHELL} != "sh" ]]; then \
      apk add --no-cache ${DEFAULT_SHELL}; \
    fi;

COPY nginx.${SERVICE_TYPE}.template.conf /etc/nginx/nginx.conf.template

RUN envsubst "\${SERVICE_DOMAIN},\${SERVICE_HOST},\${SERVICE_PORT}" \
        < /etc/nginx/nginx.conf.template \
        > /etc/nginx/nginx.conf

WORKDIR /opt/app/public

#EXPOSE 80
