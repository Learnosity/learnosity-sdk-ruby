DOCKER := $(if $(LRN_SDK_NO_DOCKER),,$(shell which docker))
RUBY_VERSION ?= 3.1

TARGETS = all install-deps build devbuild prodbuild \
	test test-unit test-integration-env \
	dist \
	version-check version-check-message \
	clean
.PHONY: $(TARGETS)
.default: all

ifneq (,$(DOCKER))
# Re-run make command in a container
DKR = docker container run -t --rm \
		-v $(CURDIR):/srv/sdk/ruby:z,delegated \
		-v lrn-sdk-ruby_cache:/srv/sdk/ruby/vendor/cache \
		-w /srv/sdk/ruby \
		-e LRN_SDK_NO_DOCKER=1 \
		-e ENV -e REGION -e VER \
		$(if $(findstring dev,$(ENV)),--net host) \
		ruby:$(value RUBY_VERSION)

$(TARGETS):
	$(DKR) make -e MAKEFLAGS="$(MAKEFLAGS)" $@

else
# Data API settings
ENV = prod
REGION = .learnosity.com
VER = v1

all: build test

build: install-deps
	bundle exec rake build

test: test-unit test-integration-env

install-deps:
	gem install bundler
	bundle install

test-unit: install-deps
	bundle exec rake spec SPEC=spec/learnosity/*

test-integration-env:
	ENV=$(ENV) REGION=$(REGION) VER=$(VER) bundle exec rake spec SPEC=spec/integration/*

clean:
	-bundle exec rake clean
	-rm -f Gemfile.lock .rspec_status

dist: build version-check test

PROJECT_VERSION_CMD = bundle exec rake version
PKG_VER = v$(shell $(PROJECT_VERSION_CMD))
GIT_TAG = $(shell git describe --tags)
VERSION_MISMATCH = For a release build, the package version number $(PKG_VER) must match the git tag $(GIT_TAG).

version-check-message:
	@echo Checking git and project versions ...

version-check: version-check-message
	@echo $(GIT_TAG) | grep -qw "$(PKG_VER)" || (echo $(VERSION_MISMATCH); exit 1)

# Some target aliases
prodbuild: dist
devbuild: build
endif
