ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG DEFAULT_SHELL
ARG REDIS_PASSWORD

# for envsubst
RUN apk add --no-cache gettext

RUN if [[ ${DEFAULT_SHELL} != "sh" ]]; then \
      apk add --no-cache ${DEFAULT_SHELL}; \
    fi;

WORKDIR /opt/redis

COPY redis.template.conf /etc/redis/redis.template.conf

RUN envsubst "\${REDIS_PASSWORD}" \
        < /etc/redis/redis.template.conf \
        > /etc/redis/redis.conf

COPY run.sh ./
RUN chmod +x ./run.sh

CMD ["sh", "-c", "./run.sh"]

#EXPOSE 6379
