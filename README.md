# Fluenbit w/ Docker Client

This builds a docker image from the official fluentbit image and adds the docker client binary.

This allows us to use run e.g. `docker inspect` commands with the `exec` input in fluentbit.

This also installs the following useful packages:
* `curl`
* `netcat`

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
