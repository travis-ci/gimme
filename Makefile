SHELL := bash
UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)

AWK ?= awk
CAT ?= cat
CURL ?= curl
CUT ?= cut
DIFF ?= diff
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
all: lint CONTRIBUTORS assert-copyright $(KNOWN_BINARY_VERSIONS_FILES)

.PHONY: clean
clean:
	$(RM) $(KNOWN_BINARY_VERSIONS_FILES) .testdata/object-urls
	$(RM) CONTRIBUTORS

.PHONY: lint
lint:
	$(GIT) grep -l '^#!/usr/bin/env bash' | xargs shellcheck
	$(GIT) grep -l '^#!/usr/bin/env bash' | xargs shfmt -i 0 -w

.PHONY: assert-copyright
assert-copyright:
	@$(DIFF) -u \
		--label a/copyright/gimme \
		<($(AWK) 'BEGIN { FS="="; } /^GIMME_COPYRIGHT/ { gsub(/"/, "", $$2); print $$2 }' gimme) \
		--label b/copyright/LICENSE \
		<(awk '/^Copyright/ { print $$0 }' LICENSE)

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
	for prefix in $$($(SED_STRIP_COMMENTS) $< | $(GREP) -E '\.[0-9]+(\.|$$)' | $(CUT) -b1-3 | $(SORT) -r | $(UNIQ)) ; do \
		$(GREP) "^$${prefix}" $< | $(GREP) -vE 'rc|beta' | $(SORT) -r | $(HEAD) -1 >> $@ ; \
	done

CONTRIBUTORS:
	@echo 'gimme was built by these wonderful humans:' >$@
	@$(GIT) log --format=%an | $(SORT) | $(UNIQ) | $(SED) 's/^/- /' >>$@
