UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)
COPYRIGHT := $(shell grep ^Copyright LICENSE)
LICENSE_URL := https://raw.githubusercontent.com/travis-ci/gimme/$(shell git rev-parse --verify HEAD | cut -b1-7)/LICENSE
GIT ?= git
SED ?= sed
ifeq ($(UNAME), Darwin)
	SED := gsed
endif

.PHONY: all
all: update-version update-copyright

.PHONY: update-version
update-version:
	$(SED) -i "s/^GIMME_VERSION=.*/GIMME_VERSION=\"$(VERSION)\"/" gimme

.PHONY: update-copyright
update-copyright:
	$(SED) -i "s/^GIMME_COPYRIGHT=.*/GIMME_COPYRIGHT=\"$(COPYRIGHT)\"/" gimme
	$(SED) -i "s,^GIMME_LICENSE_URL=.*,GIMME_LICENSE_URL=\"$(LICENSE_URL)\"," gimme
