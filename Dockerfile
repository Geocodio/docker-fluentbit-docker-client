#####################################
## Base fluentbit image            ##
#####################################

# Sourced from https://github.com/fluent/fluent-bit-docker-image/blob/master/Dockerfile.x86_64

FROM amd64/debian:bullseye-slim

# Fluent Bit version
ENV FLB_MAJOR 1
ENV FLB_MINOR 8
ENV FLB_PATCH 4
ENV FLB_VERSION 1.8.4

ARG FLB_TARBALL=https://github.com/fluent/fluent-bit/archive/v$FLB_VERSION.tar.gz
ENV FLB_SOURCE $FLB_TARBALL
RUN mkdir -p /fluent-bit/bin /fluent-bit/etc /fluent-bit/log /tmp/fluent-bit/

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp/fluent-bit/
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    cmake \
    make \
    tar \
    libssl-dev \
    libsasl2-dev \
    pkg-config \
    libsystemd-dev \
    zlib1g-dev \
    libpq-dev \
    postgresql-server-dev-all \
    flex \
    bison \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o "/tmp/fluent-bit.tar.gz" ${FLB_SOURCE} \
    && tar zxfv /tmp/fluent-bit.tar.gz -C /tmp/fluent-bit --strip-components=1 \
    && rm -rf /tmp/fluent-bit/build/*

WORKDIR /tmp/fluent-bit/build/
RUN cmake -DFLB_RELEASE=On \
          -DFLB_TRACE=Off \
          -DFLB_JEMALLOC=On \
          -DFLB_TLS=On \
          -DFLB_SHARED_LIB=Off \
          -DFLB_EXAMPLES=Off \
          -DFLB_HTTP_SERVER=On \
          -DFLB_IN_SYSTEMD=On \
          -DFLB_OUT_KAFKA=On \
          -DFLB_OUT_PGSQL=On ..

RUN make -j "$(getconf _NPROCESSORS_ONLN)"
RUN install bin/fluent-bit /fluent-bit/bin/

# Configuration files
COPY conf/fluent-bit.conf \
     conf/parsers.conf \
     conf/parsers_ambassador.conf \
     conf/parsers_java.conf \
     conf/parsers_extra.conf \
     conf/parsers_openstack.conf \
     conf/parsers_cinder.conf \
     conf/plugins.conf \
     /fluent-bit/etc/

#####################################
## Additional custom changes below ##
#####################################

ENV DOCKER_VERSION "20.10.12"

RUN apt-get update \
    && apt-get install --no-install-recommends curl netcat jq -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

RUN curl -o /tmp/docker-$DOCKER_VERSION.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz \
    && tar -xz -C /tmp -f /tmp/docker-$DOCKER_VERSION.tgz \
    && mv /tmp/docker/docker /usr/bin \
    && rm -rf /tmp/docker /tmp/docker-$DOCKER_VERSION.tgz

RUN curl -o /tmp/miller.tar.gz -L https://github.com/johnkerl/miller/releases/download/v6.0.0/miller_6.0.0_linux_amd64.tar.gz \
    && mkdir -p /tmp/miller && tar -xzf /tmp/miller.tar.gz -C /tmp/miller \
    && mv /tmp/miller/mlr /usr/bin \
    && rm -rf /tmp/miller /tmp/miller.tar.gz

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]