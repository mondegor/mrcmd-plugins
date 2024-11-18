ARG DOCKER_IMAGE_FROM=ubuntu:20.04

FROM ${DOCKER_IMAGE_FROM}

ARG DEBIAN_FRONTEND=noninteractive
ARG WKHTMLTOPDF_VERSION=0.12.6-1

RUN apt-get update \
    && apt-get install -y \
    pandoc \
    texlive-lang-cyrillic \
    texlive-latex-extra \
    lmodern \
    cm-super \
    wget \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}.focal_amd64.deb \
    && apt install -y ./wkhtmltox_${WKHTMLTOPDF_VERSION}.focal_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data

CMD ["/bin/bash"]

ENTRYPOINT ["pandoc"]
