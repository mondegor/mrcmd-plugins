ARG DOCKER_IMAGE_FROM=openjdk:17-alpine3.14

FROM ${DOCKER_IMAGE_FROM}

ARG HOST_USER_ID
ARG HOST_GROUP_ID

# RUN echo "JAVA_VERSION: ${JAVA_VERSION}"
# RUN echo "JAVA_HOME: ${JAVA_HOME}"

# for envsubst
#RUN apt-get update && apt-get install -y \
#    gettext \
#    && rm -rf /var/lib/apt/lists/*

RUN addgroup -g 1000 java && adduser -u 1000 -G java -s /bin/sh -D java

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      apk add --no-cache shadow \
      && groupmod -o -g ${HOST_GROUP_ID} java \
      && usermod -o -u ${HOST_USER_ID} -g java java; \
    fi;

WORKDIR /opt/app
RUN chown -R java:java /opt

USER java
