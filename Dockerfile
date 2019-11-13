FROM fluent/fluent-bit:0.14

ENV DOCKER_VERSION "18.09.1"

RUN apt-get update \
    && apt-get install --no-install-recommends curl netcat -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

RUN curl i /tmp/docker-$DOCKER_VERSION.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz \
    && tar -xz -C /tmp -f /tmp/docker-$DOCKER_VERSION.tgz \
    && mv /tmp/docker/docker /usr/bin \
    && rm -rf /tmp/docker /tmp/docker-$DOCKER_VERSION.tgz
