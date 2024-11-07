.PHONY: default build deploy run

default: build

org = geocodio
name = fluentbit-docker-client

build:
	docker build https://raw.githubusercontent.com/giantswarm/fluent-bit/refs/heads/main/Dockerfile --target debug --tag giantswarm/fluent-bit:3.1.10-debug
	docker build -t $(org)/$(name):3.1 .

deploy:
	docker push $(org)/$(name):3.1

run:
	docker run --rm --name=$(name) $(org)/$(name):3.1
