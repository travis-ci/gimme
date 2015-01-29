UNAME := $(shell uname)
VERSION := $(shell cat VERSION)
GIT ?= git
SED ?= sed
ifeq ($(UNAME), Darwin)
	SED := gsed
endif

.PHONY: update-version
update-version: VERSION
	$(SED) -i "s/^GIMME_VERSION=.*/GIMME_VERSION=$(VERSION)/" gimme

.PHONY: tag-release
tag-release: VERSION
	$(GIT) tag -a -m 'Tagging $(VERSION)' $(VERSION)
