UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)
COPYRIGHT := $(shell grep ^Copyright LICENSE)
LICENSE_URL := https://raw.githubusercontent.com/travis-ci/gimme/$(shell git rev-parse --verify HEAD | cut -b1-7)/LICENSE

AWK ?= awk
CAT ?= cat
CURL ?= curl
CUT ?= cut
GIT ?= git
HEAD ?= head
GREP ?= grep
JQ ?= jq
SED ?= sed
SORT ?= sort
TOUCH ?= touch
UNIQ ?= uniq
ifeq ($(UNAME), Darwin)
	SED := gsed
	SORT := gsort
	UNIQ := guniq
endif

SED_STRIP_COMMENTS ?= $(SED) -n -e '/^[^\#]/p'

KNOWN_BINARY_VERSIONS_FILES := \
	.testdata/binary-darwin \
	.testdata/binary-linux \
	.testdata/sample-binary-darwin \
	.testdata/sample-binary-linux

.PHONY: all
all: lint update-version update-copyright $(KNOWN_BINARY_VERSIONS_FILES)

.PHONY: clean
clean:
	$(RM) $(KNOWN_BINARY_VERSIONS_FILES) .testdata/object-urls

.PHONY: lint
lint:
	git grep -l '^#!/usr/bin/env bash' | xargs shellcheck
	git grep -l '^#!/usr/bin/env bash' | xargs shfmt -i 0 -w

.PHONY: update-version
update-version:
	$(SED) -i "s/^GIMME_VERSION=.*/GIMME_VERSION=\"$(VERSION)\"/" gimme

.PHONY: update-copyright
update-copyright:
	$(SED) -i "s/^GIMME_COPYRIGHT=.*/GIMME_COPYRIGHT=\"$(COPYRIGHT)\"/" gimme
	$(SED) -i "s,^GIMME_LICENSE_URL=.*,GIMME_LICENSE_URL=\"$(LICENSE_URL)\"," gimme

.PHONY: remove-object-urls
remove-object-urls:
	$(RM) .testdata/object-urls

.PHONY: force-update-versions
force-update-versions: remove-object-urls .testdata/object-urls
	@true

.PHONY: update-binary-versions
update-binary-versions: force-update-versions $(KNOWN_BINARY_VERSIONS_FILES)

.testdata/binary-%: .testdata/object-urls
	$(RM) $@
	$(CAT) .testdata/stubheader-all > $@
	$(CAT) $< | \
		$(GREP) -E "$(lastword $(subst -, ,$@)).*tar\.gz$$" | \
		$(AWK) -F/ '{ print $$9 }' | \
		$(SED) "s/\.$(lastword $(subst -, ,$@)).*//;s/^go//" | \
		$(SORT) -r | $(UNIQ) >> $@

.testdata/object-urls:
	./fetch-object-urls >$@

.testdata/sample-binary-%: .testdata/binary-%
	$(RM) $@
	$(CAT) .testdata/stubheader-sample > $@
	for prefix in $$($(SED_STRIP_COMMENTS) $< | $(GREP) -E '\.[0-9]\.|\.9' | $(CUT) -b1-3 | $(SORT) -r | $(UNIQ)) ; do \
		$(GREP) "^$${prefix}" $< | $(GREP) -vE 'rc|beta' | $(SORT) -r | $(HEAD) -1 >> $@ ; \
	done
