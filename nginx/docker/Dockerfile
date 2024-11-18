ARG DOCKER_IMAGE_FROM=nginx:1.27.0-alpine3.19

FROM ${DOCKER_IMAGE_FROM}

ARG SERVICE_TYPE
ARG SERVICE_HOST
ARG SERVICE_PORT

COPY nginx.${SERVICE_TYPE}.template.conf /etc/nginx/nginx.conf.template

RUN envsubst "\${SERVICE_HOST},\${SERVICE_PORT}" \
        < /etc/nginx/nginx.conf.template \
        > /etc/nginx/nginx.conf

WORKDIR /opt/app/public

#EXPOSE 80
