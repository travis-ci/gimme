UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)
COPYRIGHT := $(shell grep ^Copyright LICENSE)
LICENSE_URL := https://raw.githubusercontent.com/travis-ci/gimme/$(shell git rev-parse --verify HEAD | cut -b1-7)/LICENSE

AWK ?= awk
CAT ?= cat
CURL ?= curl
GIT ?= git
GREP ?= grep
JQ ?= jq
SED ?= sed
SORT ?= sort
UNIQ ?= uniq
ifeq ($(UNAME), Darwin)
	SED := gsed
	SORT := gsort
	UNIQ := guniq
endif

KNOWN_BINARY_VERSIONS_FILES := \
	.known-binary-versions-darwin \
	.known-binary-versions-linux

.PHONY: all
all: update-version update-copyright $(KNOWN_BINARY_VERSIONS_FILES)

clean:
	$(RM) $(KNOWN_BINARY_VERSIONS_FILES) .known-versions-object-urls

.PHONY: update-version
update-version:
	$(SED) -i "s/^GIMME_VERSION=.*/GIMME_VERSION=\"$(VERSION)\"/" gimme

.PHONY: update-copyright
update-copyright:
	$(SED) -i "s/^GIMME_COPYRIGHT=.*/GIMME_COPYRIGHT=\"$(COPYRIGHT)\"/" gimme
	$(SED) -i "s,^GIMME_LICENSE_URL=.*,GIMME_LICENSE_URL=\"$(LICENSE_URL)\"," gimme

.known-binary-versions-%: .known-versions-object-urls
	$(CAT) $< | \
		$(GREP) -E "$(lastword $(subst -, ,$@)).*tar\.gz$$" | \
		$(AWK) -F/ '{ print $$9 }' | \
		$(SED) "s/\.$(lastword $(subst -, ,$@)).*//;s/^go//" | \
		$(SORT) -r | $(UNIQ) > $@
	if [ -f $@.tail ] ; then $(CAT) $@.tail >> $@ ; fi

.known-versions-object-urls:
	$(CURL) -s https://www.googleapis.com/storage/v1/b/golang/o | \
		$(JQ) -r '.items | .[] | .selfLink' > $@
