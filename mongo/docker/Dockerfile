ARG DOCKER_IMAGE_FROM=mongo:6.0.11-jammy

FROM ${DOCKER_IMAGE_FROM}

COPY mongod.conf /etc/mongo/mongod.conf

CMD ["mongod", "--config", "/etc/mongo/mongod.conf"]

#EXPOSE 27017
