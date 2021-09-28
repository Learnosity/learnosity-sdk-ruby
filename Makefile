ifndef LRN_SDK_NO_DOCKER
CMP_PROJECT = lrn-sdk-ruby
CMP = docker-compose -f lrn-dev/docker-compose.yml --env-file lrn-dev/env --project-name $(CMP_PROJECT)
CMP_RUN = $(CMP) run --rm ruby
CMP_BUILD = $(CMP) build
CMP_CLEAN = docker image ls --filter reference=$(CMP_PROJECT)\* -q | xargs docker rmi
CMP_RM_VOLUME = docker volume rm $(CMP_PROJECT)_repo
endif

PROJECT_VERSION_CMD = bundle exec rake version
PKG_VER = v$(shell $(CMP_RUN) $(PROJECT_VERSION_CMD))
GIT_TAG = $(shell git describe --tags)
VERSION_MISMATCH = For a release build, the package version number $(PKG_VER) must match the git tag $(GIT_TAG).

# Data API settings

DAPI_ENV = prod
DAPI_REGION = .learnosity.com
DAPI_VER = v1

# Dev cycle targets

all: lrn-dev build test

build: install-deps
	$(CMP_RUN) bundle exec rake build

test: test-unit test-integration-env

install-deps:
	$(CMP_RUN) gem install bundler
	$(CMP_RUN) bundle install

test-unit: install-deps
	$(CMP_RUN) bundle exec rake spec SPEC=spec/learnosity/*

test-integration-env:
	ENV=$(DAPI_ENV) REGION=$(DAPI_REGION) VER=$(DAPI_VER) $(CMP_RUN) bundle exec rake spec SPEC=spec/integration/*

clean:
	$(CMP_RUN) bundle exec rake clean

#-rm Gemfile.lock .rspec_status

prodbuild: build version-check test

version-check-message:
	@echo Checking git and project versions ...

version-check: version-check-message
	@echo $(GIT_TAG) | grep -qw "$(PKG_VER)" || (echo $(VERSION_MISMATCH); exit 1)

# Some target aliases

dist: prodbuild

devbuild: build

# LRN environment targets

lrn-dev:
	$(CMP_BUILD)

lrn-clean: clean
	$(CMP_CLEAN)
	-$(if $(LRN_SDK_KEEP_VOLUME),,$(CMP_RM_VOLUME))

.PHONY: all build prodbuild devbuild dist \
	test test-unit test-integration-dev \
	install-deps gem-info \
	version-check version-check-message \
	clean \
	lrn-dev lrn-clean
