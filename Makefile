.PHONY: default build deploy run

default: build

org = geocodio
name = fluentbit-docker-client

build:
	docker build -t $(org)/$(name):2.2 .

deploy:
	docker push $(org)/$(name):2.2

run:
	docker run --rm --name=$(name) $(org)/$(name)
