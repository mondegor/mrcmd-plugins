ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG HOST_USER_ID
ARG HOST_GROUP_ID
ARG WEBAPP_INTERNAL_PORT=8080

# RUN echo "GOPATH: ${GOPATH}"
# RUN echo "GOBIN: ${GOBIN}"
# RUN echo "GOROOT: ${GOROOT}"

RUN apk add --no-cache git

RUN addgroup -g 1000 golang && adduser -u 1000 -G golang -s /bin/sh -D golang

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} golang \
      && usermod -o -u ${HOST_USER_ID} -g golang golang; \
    fi;

WORKDIR /opt/app
RUN chown -R golang:golang /go /opt

USER golang

EXPOSE ${WEBAPP_INTERNAL_PORT}
