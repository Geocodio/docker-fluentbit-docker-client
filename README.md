# Fluenbit w/ Docker Client

This builds a docker image from the official fluentbit image and adds the docker client binary.

This allows us to use run e.g. `docker inspect` commands with the `exec` input in fluentbit.

## Developing

```
# Build docker image
make build

# Push docker image
make deploy

# Run docker image
make run
```
