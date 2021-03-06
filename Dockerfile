#####################################
## Base fluentbit image            ##
#####################################

# Sourced from https://github.com/fluent/fluent-bit-docker-image/blob/1.3.2/Dockerfile.x86_64

FROM amd64/debian:stretch-slim

# Fluent Bit version
ENV FLB_MAJOR 1
ENV FLB_MINOR 3
ENV FLB_PATCH 2
ENV FLB_VERSION 1.3.2

ENV DEBIAN_FRONTEND noninteractive

ENV FLB_TARBALL http://github.com/fluent/fluent-bit/archive/v$FLB_VERSION.zip
RUN mkdir -p /fluent-bit/bin /fluent-bit/etc /fluent-bit/log /tmp/fluent-bit-master/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      make \
      wget \
      unzip \
      libssl-dev \
      libasl-dev \
      libsasl2-dev \
      pkg-config \
      libsystemd-dev \
      zlib1g-dev \
      ca-certificates \
      flex \
      bison \
    && wget -O "/tmp/fluent-bit-${FLB_VERSION}.zip" ${FLB_TARBALL} \
    && cd /tmp && unzip "fluent-bit-$FLB_VERSION.zip" \
    && cd "fluent-bit-$FLB_VERSION"/build/ \
    && rm -rf /tmp/fluent-bit-$FLB_VERSION/build/*

WORKDIR /tmp/fluent-bit-$FLB_VERSION/build/
RUN cmake -DFLB_DEBUG=On \
          -DFLB_TRACE=Off \
          -DFLB_JEMALLOC=On \
          -DFLB_TLS=On \
          -DFLB_SHARED_LIB=Off \
          -DFLB_EXAMPLES=Off \
          -DFLB_HTTP_SERVER=On \
          -DFLB_IN_SYSTEMD=On \
          -DFLB_OUT_KAFKA=On ..

RUN make -j $(getconf _NPROCESSORS_ONLN)
RUN install bin/fluent-bit /fluent-bit/bin/

# Configuration files
COPY fluent-bit.conf \
     parsers.conf \
     parsers_java.conf \
     parsers_extra.conf \
     parsers_openstack.conf \
     parsers_cinder.conf \
     plugins.conf \
     /fluent-bit/etc/

#####################################
## Additional custom changes below ##
#####################################

ENV DOCKER_VERSION "18.09.1"

RUN apt-get update \
    && apt-get install --no-install-recommends curl netcat jq -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

RUN curl -o /tmp/docker-$DOCKER_VERSION.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz \
    && tar -xz -C /tmp -f /tmp/docker-$DOCKER_VERSION.tgz \
    && mv /tmp/docker/docker /usr/bin \
    && rm -rf /tmp/docker /tmp/docker-$DOCKER_VERSION.tgz

RUN curl -L -o /usr/bin/mlr https://github.com/johnkerl/miller/releases/download/v5.6.2/mlr.linux.x86_64 \
    && chmod +x /usr/bin/mlr

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]