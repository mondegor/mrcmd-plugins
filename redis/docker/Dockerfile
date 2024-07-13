ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

ARG REDIS_PASSWORD

# for envsubst
RUN apk add --no-cache gettext

WORKDIR /opt/redis

COPY redis.template.conf /etc/redis/redis.conf.template

RUN envsubst "\${REDIS_PASSWORD}" \
        < /etc/redis/redis.conf.template \
        > /etc/redis/redis.conf

COPY run.sh ./
RUN chmod +x ./run.sh

CMD ["sh", "-c", "./run.sh"]

#EXPOSE 6379
