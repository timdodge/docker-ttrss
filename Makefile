REPO := adamashley/docker-ttrss
TAG := $(shell git describe --tags --abbrev=1)

build:
	docker build . -t "${REPO}:${TAG}" -t "${REPO}:latest" -t "${REPO}:amd64"

push: build
	docker push "${REPO}:${TAG}"
	docker push "${REPO}:amd64"
	docker push "${REPO}:latest"

