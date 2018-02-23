SHELL := bash
UNAME := $(shell uname)
VERSION := $(shell git describe --always --tags)
.DEFAULT_GOAL := all

# Affects sorting for CONTRIBUTORS file; unfortunately these are not
# totally names (standards opaque IIRC) but this should work for us.
LC_COLLATE:=en_US.UTF-8
# Alas, macOS collation is broken and generates spurious differences.

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

ifeq "$(shell $(SORT) --version-sort </dev/null >/dev/null 2>&1 || echo no)" "no"
	_ := $(warning "$(SORT) --version-sort not available, falling back to shell")
	REV_VERSION_SORT := $(SED) -E 's/\.([0-9](\.|$$))/.00\1/g; s/\.([0-9][0-9](\.|$$))/.0\1/g' | $(SORT) --general-numeric-sort -r | $(SED) 's/\.00*/./g'
else
	REV_VERSION_SORT := $(SORT) --version-sort -r
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
ifeq ($(UNAME), Darwin)
	$(warning Not deleting CONTRIBUTORS on macOS, locale sorting is broken)
else
	$(RM) CONTRIBUTORS
endif

.PHONY: lint
lint:
	$(GIT) grep -l '^#!/usr/bin/env bash' | xargs shellcheck
	$(GIT) grep -l '^#!/usr/bin/env bash' | xargs shfmt -i 0 -w

.PHONY: assert-copyright
assert-copyright:
	@$(DIFF) -u \
		--label a/copyright/gimme \
		<($(AWK) 'BEGIN { FS="="; } /^readonly GIMME_COPYRIGHT/ { gsub(/"/, "", $$2); print $$2 }' gimme) \
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
	for prefix in $$($(SED_STRIP_COMMENTS) $< | $(SED) -En 's/^([0-9]+\.[0-9]+)(\..*)?$$/\1/p' | $(REV_VERSION_SORT) | $(UNIQ)) ; do \
		$(GREP) "^$${prefix}" $< | $(GREP) -vE 'rc|beta' | $(REV_VERSION_SORT) | $(HEAD) -1 >> $@ ; \
	done

CONTRIBUTORS:
ifeq ($(UNAME), Darwin)
	$(error macOS appears to have broken collation and will make spurious differences)
endif
	@echo 'gimme was built by these wonderful humans:' >$@
	@$(GIT) log --format=%an | $(SORT) | $(UNIQ) | $(SED) 's/^/- /' >>$@
