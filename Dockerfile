# Beware: only meant for use to build ruby appimages

FROM ubuntu:14.04

MAINTAINER "Andrey Vasilyev <andrey.vasilyev@fruct.org>"

ARG RUBY_VERSION=2.6.4
ARG RUBY_INSTALL_VERSION=0.7.0

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKER_BUILD=1

RUN apt-get update && \
        apt-get install -y apt-transport-https software-properties-common

# Install and configure GCC 9 to build ruby and packages
# Inspiried by https://gist.github.com/application2000/73fd6f4bf1be6600a2cf9f56315a2d91
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
        apt-get update && \
        apt-get install -y \
        build-essential \
        g++-9 \
        g++-9 \
        wget \
        sudo \
        vim && \
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 100 --slave /usr/bin/g++ g++ /usr/bin/g++-9 && \
        wget -O ruby-install-$RUBY_INSTALL_VERSION.tar.gz https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz && \
        tar -xzvf ruby-install-$RUBY_INSTALL_VERSION.tar.gz && \
        cd ruby-install-$RUBY_INSTALL_VERSION && \
        make install && \
        install -m 0755 -d /workspace/application && \
        ruby-install ruby $RUBY_VERSION -i /workspace/ruby-root -- --disable-install-doc --disable-debug --disable-dependency-tracking --enable-shared --enable-load-relative

# Put gen_appimage.sh script into the root
COPY gen_appimage.sh /

# Allow to run sudo without password for this user
RUN echo "ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /workspace
