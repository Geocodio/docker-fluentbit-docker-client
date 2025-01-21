# Builder stage
FROM debian:bookworm-slim AS builder

# Install Docker CLI
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli

# Install Redis CLI
RUN apt-get install -y redis-tools

# Install Miller (awk-like tool for csv/json etc.)
RUN curl -o /tmp/miller.tar.gz -L https://github.com/johnkerl/miller/releases/download/v6.13.0/miller-6.13.0-linux-amd64.tar.gz \
    && mkdir -p /tmp/miller && tar -xzf /tmp/miller.tar.gz -C /tmp/miller \
    && mv /tmp/miller/miller-6.13.0-linux-amd64/mlr /usr/bin \
    && rm -rf /tmp/miller /tmp/miller.tar.gz

# Final stage (use giantswarm as base image since it has the exec input enabled and other goodies)
FROM giantswarm/fluent-bit:3.1.10-debug

# Copy only the necessary binaries and their dependencies
COPY --from=builder /usr/bin/docker /usr/bin/
COPY --from=builder /usr/bin/redis-cli /usr/bin/
COPY --from=builder /usr/bin/mlr /usr/bin/


COPY --from=builder /lib/x86_64-linux-gnu/*.so* /usr/lib
COPY --from=builder /usr/lib/x86_64-linux-gnu/*.so* /usr/lib

