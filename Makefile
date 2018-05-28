ENV=prod
REGION=.learnosity.com
# Data API
VER=v1

all: devbuild test

install-deps:
	bundle install
prodbuild: dist-check-version build
devbuild: build
build: install-deps
	rake build

test: test-unit test-integration-env
test-unit: install-deps
	rake spec SPEC=spec/learnosity/*

test-integration-env:
	rake spec SPEC=spec/integration/*

build-clean: real-clean

dist: distclean
	$(error not implemented)
dist-upload: dist-check-version clean test
dist-check-version: PKG_VER=v$(shell sed -n 's/^.*VERSION\s\+=\s\+"\([^"]\+\)".*$$/\1/p' lib/learnosity/sdk/version.rb)
dist-check-version: GIT_TAG=$(shell git describe --tags)
dist-check-version:
ifeq ('$(shell echo $(GIT_TAG) | grep -qw "$(PKG_VER)")', '')
	$(error Version number $(PKG_VER) in setup.py does not match git tag $(GIT_TAG))
endif

clean:
	$(error not implemented)
real-clean: clean

.PHONY: all clean real-clean \
	install-deps \
	prodbuild devbuild build \
	test test-unit test-integration-dev \
	build-clean \
	dist dist-upload dist-check-version
