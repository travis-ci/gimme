UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)
GIT ?= git
SED ?= sed
ifeq ($(UNAME), Darwin)
	SED := gsed
endif

.PHONY: update-version
update-version:
	$(SED) -i "s/^GIMME_VERSION=.*/GIMME_VERSION=$(VERSION)/" gimme
