.PHONY: default build deploy run

default: build

org = geocodio
name = fluentbit-docker-client

build:
	docker build -t $(org)/$(name):3.1 .

deploy:
	docker push $(org)/$(name):3.1

run:
	docker run --rm --name=$(name) $(org)/$(name):3.1
