FROM debian:trixie-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    ssh \
    git \
    xz-utils \
    unzip \
    gdb \
    pkg-config \
    curl \
    python3 \
    tox-uv
RUN rm -rf /var/lib/apt/lists/*

ADD alr-2.1.1-bin-x86_64-linux.tar.xz /opt/
ENV PATH="/opt/alr-2.1.1-bin-x86_64-linux/bin:${PATH}"
ENV PATH="/root/.alire/bin:/opt/alire/bin:${PATH}"

RUN alr install gnat_native
RUN alr install gprbuild

ENV DEBIAN_FRONTEND=

WORKDIR /workspace