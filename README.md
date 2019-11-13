# Fluenbit w/ Docker Client

This docker image is based off of the official [Fluentbit 1.3.2](https://hub.docker.com/r/fluent/fluent-bit) Docker image. It adds a couple of small extras such as the docker client.

This allows us to use run e.g. `docker inspect` commands with the `exec` input in fluentbit.

This also installs the following useful packages:
* `curl`
* `netcat`
* [miller](https://github.com/johnkerl/miller)

## Example
```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock geocodio/fluentbit-docker-client
```

> Note: The docker socket needs to be attached as a volume in order for the client to be able access the docker daemon on the host. Make sure that you understand the security implications of this.

## Developing

```
# Build docker image
make build

# Push docker image
make deploy

# Run docker image
make run
```
