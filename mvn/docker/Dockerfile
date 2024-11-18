ARG DOCKER_IMAGE_FROM=maven:3.8.5-openjdk-17-slim

FROM ${DOCKER_IMAGE_FROM}

ARG HOST_USER_ID
ARG HOST_GROUP_ID
ARG CONFIG_DIR

# RUN echo "MAVEN_VERSION: ${MAVEN_VERSION}"
# RUN echo "MAVEN_HOME: ${MAVEN_HOME}"
# RUN echo "MAVEN_CONFIG: ${MAVEN_CONFIG}"

RUN groupadd --gid 1000 maven && useradd --uid 1000 --gid 1000 -s /bin/sh -m maven
RUN mkdir ${CONFIG_DIR} && chown -R maven:maven ${CONFIG_DIR}

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      groupmod -o -g ${HOST_GROUP_ID} maven \
      && usermod -o -u ${HOST_USER_ID} -g maven maven; \
    fi;

WORKDIR /opt/app

USER maven
