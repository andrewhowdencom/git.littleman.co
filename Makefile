# Task runner

.PHONY: help build

.DEFAULT_GOAL := help

SHELL := /bin/bash

PROJECT_NS   := git-littleman-co
CONTAINER_NS := littleman-co

GIT_HASH     := $(shell git rev-parse --short HEAD)

ANSI_TITLE        := '\e[1;32m'
ANSI_CMD          := '\e[0;32m'
ANSI_TITLE        := '\e[0;33m'
ANSI_SUBTITLE     := '\e[0;37m'
ANSI_WARNING      := '\e[1;31m'
ANSI_OFF          := '\e[0m'

PATH_BUILD_CONFIGURATION := $(shell pwd)/build

HUGO_THEME := blackburn
HUGO_BUILD_DRAFTS := true

GCR_NAMESPACE := littleman-co

SECRET_CERT       := $(shell base64 -w 0 etc/tls/cert.pem)
SECRET_FULL_CHAIN := $(shell base64 -w 0 etc/tls/fullchain.pem)
SECRET_PRIVKEY    := $(shell base64 -w 0 etc/tls/privkey.pem)

GOGS_VERSION := 0.9.13

help: ## Show this menu
	@echo -e $(ANSI_TITLE)git.littleman.co$(ANSI_OFF)$(ANSI_SUBTITLE)" - Development documentation that is handy\n"$(ANSI_OFF)
	@echo -e $(ANSI_TITLE)Commands:$(ANSI_OFF)
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[32m%-30s\033[0m %s\n", $$1, $$2}'

push-container-%: ## Tags and pushes a container to the repo
	docker tag ${CONTAINER_NS}/${PROJECT_NS}-$*:${GIT_HASH} gcr.io/${GCR_NAMESPACE}/${PROJECT_NS}-$*:${GIT_HASH}
	docker push gcr.io/${GCR_NAMESPACE}/${PROJECT_NS}-$*:${GIT_HASH}

push-secret-tls: ## Push updates to the TLS Certificates
	sed "s/{{CERT}}/${SECRET_CERT}/" build/kubernetes/gogs-etc-tls.yml | sed -e "s/{{FULL_CHAIN}}/${SECRET_FULL_CHAIN}/" | sed -e "s/{{PRIVKEY}}/${SECRET_PRIVKEY}/" | kubectl create -f -

build-container-%: ## Builds the $* (gollum) container, and tags it with the git hash.
	docker build -t ${CONTAINER_NS}/${PROJECT_NS}-$*:${GIT_HASH} -f build/docker/$*/Dockerfile .

deploy-%: ## Push a deployment to Kubernetes
	sed "s/{{GOGS_VERSION}}/${GOGS_VERSION}/" "build/kubernetes/$*.deployment.yml" | sed -e "s/{{GIT_HASH}}/${GIT_HASH}/" | kubectl apply -f -
