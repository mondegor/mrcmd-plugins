# https://hub.docker.com/_/nginx

ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ARG INSTALL_BASH
ARG SERVICE_TYPE
ARG SERVICE_DOMAIN
ARG SERVICE_HOST
ARG SERVICE_PORT

RUN if [[ "${INSTALL_BASH}" == true ]]; then \
      apk add --no-cache bash; \
    fi;

COPY nginx.${SERVICE_TYPE}.template.conf /etc/nginx/nginx.template.conf

RUN envsubst "\${SERVICE_DOMAIN},\${SERVICE_HOST},\${SERVICE_PORT}" \
        < /etc/nginx/nginx.template.conf \
        > /etc/nginx/nginx.conf

WORKDIR /opt/app/public

#EXPOSE 80
