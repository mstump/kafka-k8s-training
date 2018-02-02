# Copyright 2017 Vorstella

BUILD_DATE?=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_VERSION?=$(shell git rev-parse --short HEAD)
DEV_REPOS?=vorstella quay.io/vorstella

# used for newline in push
define \n


endef

ifdef CIRCLE_TAG
  TAG_SUFFIXES += ${CIRCLE_TAG}
  TAG_SUFFIXES += ${CIRCLE_TAG}-${GIT_VERSION}
  TAG_SUFFIXES += ${CIRCLE_TAG}-${GIT_VERSION}-${CIRCLE_BUILD_NUM}
  RELEASE=1
endif

ifdef CIRCLE_PR
  TAG_SUFFIXES += pr-${CIRCLE_PR_NUMBER}
  TAG_SUFFIXES += pr-${CIRCLE_PR_NUMBER}-${GIT_VERSION}
  TAG_SUFFIXES += pr-${CIRCLE_PR_NUMBER}-${GIT_VERSION}-${CIRCLE_BUILD_NUM}
endif

ifndef TAG_SUFFIXES
  ifdef CIRCLE_BRANCH
    TAG_SUFFIXES += ${CIRCLE_BRANCH}
    TAG_SUFFIXES += ${CIRCLE_BRANCH}-${GIT_VERSION}
    TAG_SUFFIXES += ${CIRCLE_BRANCH}-${GIT_VERSION}-${CIRCLE_BUILD_NUM}
  else
    TAG_SUFFIXES += dev-${GIT_VERSION}
  endif
endif


define make-docker
.PHONY: $1_docker_build $1_docker_run $1_shell

$1_DOCKER_TAGS := $(foreach repo, ${DEV_REPOS}, $(foreach suffix, ${TAG_SUFFIXES}, -t $(repo)/$1:$(suffix)))
DOCKER_TAGS := $(foreach repo, ${DEV_REPOS}, $(foreach suffix, ${TAG_SUFFIXES}, $(repo)/$1:$(suffix)))
$1_DOCKER_RUN_TAG := $$(lastword $${DOCKER_TAGS})

$1_docker_build:
	@echo building docker image for $1
	docker build -f docker/Dockerfile.$1 \
	--build-arg="BUILD_DATE=${BUILD_DATE}" \
	--build-arg="VCS_REF=${GIT_VERSION}" \
	$${$1_DOCKER_TAGS} docker

$1_run:
	@echo running docker image $1
	docker run -i -t --rm \
	$${$1_DOCKER_RUN_TAG}

$1_shell:
	@echo running shell for docker image $1
	docker run -i -t --rm \
	$${$1_DOCKER_RUN_TAG} \
	/bin/bash

DOCKER_BUILD_TARGETS += $1_docker_build
endef

$(eval $(call make-docker,kafka-publisher))
$(eval $(call make-docker,kafka-consumer))

all: build

build: ${DOCKER_BUILD_TARGETS}

push:
	$(info ${DOCKER_TAGS})
	$(foreach tag, ${DOCKER_TAGS}, docker push ${tag}${\n})

run: java_run

shell: java_shell

ci: build push

.PHONY: all build push run ci
