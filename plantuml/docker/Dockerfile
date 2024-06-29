ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG HOST_USER_ID
ARG HOST_GROUP_ID

RUN groupadd --gid 1000 plantuml && useradd --uid 1000 --gid 1000 -s /bin/sh -m plantuml
RUN chown -R plantuml:plantuml /data

RUN if [[ ${HOST_USER_ID} -gt 0 ]] && [[ ${HOST_GROUP_ID} -gt 0 ]]; then \
      groupmod -o -g ${HOST_GROUP_ID} plantuml \
      && usermod -o -u ${HOST_USER_ID} -g plantuml plantuml; \
    fi;

USER plantuml

# add base path for "!include" in *.puml, *.iuml files
ENTRYPOINT ["java", "-Dplantuml.include.path=/data", "-jar", "/opt/plantuml.jar"]
