# Beware: only meant for use to build ruby appimages

FROM ubuntu:trusty

ARG UNAME=builduser
ARG UID=1000
ARG GID=1000

MAINTAINER "Andrey Vasilyev <andrey.vasilyev@fruct.org>"

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKER_BUILD=1

# Install all dependencies required by the ruby build
# and wget required by the gen_appimage.sh
RUN apt-get update && apt-get install -y \
    autoconf \
    bison \
    build-essential \
    libssl-dev \
    libyaml-dev \
    libreadline6-dev \
    zlib1g-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm3 \
    libgdbm-dev \
    wget \
    apt-transport-https
# Create /workspace directory to use for mounting build environment
RUN addgroup --gid $GID $UNAME
RUN adduser --uid $UID --gid $GID --shell /bin/bash --home /workspace $UNAME
COPY gen_appimage.sh /workspace
RUN install -m 0755 -o $UID -g $GID -d /workspace/application
# Allow to run sudo without password for this user
RUN echo "$NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /workspace/application