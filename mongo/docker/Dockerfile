ARG DOCKER_IMAGE_FROM

FROM ${DOCKER_IMAGE_FROM}

COPY mongod.conf /etc/mongo/mongod.conf

CMD ["mongod", "--config", "/etc/mongo/mongod.conf"]

#EXPOSE 27017
