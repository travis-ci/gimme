# gimme [![Build Status](https://travis-ci.org/travis-ci/gimme.svg?branch=master)](https://travis-ci.org/travis-ci/gimme)

Install go, yay!

`gimme` is a shell script that knows how to install [go](https://golang.org).  Fancy! :tada:

## Installation & usage

Install from github:

``` bash
# assumes ~/bin exists and is in $PATH, so adjust accordingly!

curl -sL -o ~/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
chmod +x ~/bin/gimme
```

[Homebrew](http://brew.sh) (OS X):

```bash
brew install gimme
```

[Arch AUR](https://aur.archlinux.org/) (Arch Linux), substituting `yaourt` with
however you prefer to install from AUR:

``` bash
# latest released version
yaourt -S gimme

# current git HEAD revision
yaourt -S gimme-git
```

Then check the help text a la:

``` bash
gimme -h

# or

gimme --help

# or

gimme help

# or

gimme wat
```

To install and use version 1.4, for example:
``` bash
eval "$(GIMME_GO_VERSION=1.4 gimme)"

# or:

eval "$(gimme 1.4)"

# or if you can't stand the thought of using `eval`:

gimme 1.4
source ~/.gimme/envs/go1.4.env
```

Or run without installing gimme:

``` bash
eval "$(curl -sL https://raw.githubusercontent.com/travis-ci/gimme/master/gimme | GIMME_GO_VERSION=1.4 bash)"
```

To install and use the current stable release of Go:

``` bash
gimme stable
```

Or to install and use the development version (master branch) of Go:

``` bash
gimme master
```

To list installed versions of Go:

``` bash
gimme -l

# or

gimme --list

# or

gimme list
```

To force re-installation of an existing Go version:
``` bash
gimme --force 1.4.1

# or

gimme -f 1.4.1

# or even

gimme force 1.4.1
```

To get the version of gimme:
``` bash
gimme -V

# or

gimme --version

# or even

gimme version
```

### `.travis.yml`

The original goal of this project was trivial cross-compilation within Travis.  The following is an example `.travis.yml` file to accomplish this for a normal Go project:

```yaml
language: go

env:
    - GIMME_OS=linux GIMME_ARCH=amd64
    - GIMME_OS=darwin GIMME_ARCH=amd64
    - GIMME_OS=windows GIMME_ARCH=amd64

install:
    - go get -d -v ./...

script:
    - go build -v ./...
```

## Available Versions

### Policy of Gimme

Gimme only supports downloading versions which the Go developers make
available.  If a version of Go is withdrawn, then Gimme has no logic
to go look elsewhere for that version.  Thus as the Go Maintainers withdraw
old releases, they'll stop being available for Gimme to fetch.

Because Gimme caches builds, a testing framework which preserves that cache
might still have older releases available, leading to sporadic failures.  The
only fix is to switch to only requesting currently available versions of Go.

The environment variable `$GIMME_DOWNLOAD_BASE` can be used to point Gimme
at another location, so if you need to keep working with older Go releases,
then you can maintain your own software artifact mirror which preserves those
versions and point Gimme at that instead.

### Asking Gimme about Available Versions

Invoke `gimme -k` or `gimme --known` to have Gimme report the versions which
can be installed; invoking `gimme stable` installs the version which the Go
Maintainers have declared to be stable.  Both of these involve making
non-cached network requests to retrieve this information.

The `stable` request retrieves <https://golang.org/VERSION?m=text> and reports
that.

The `known` request retrieves <https://golang.org/dl> and parses the page to
find releases.  This is not the same as the location where the images are
retrieved from, thus it's possible for `known` to know about more or fewer
versions than are actually available.  We proceed on the basis that the
documented releases are suitable and undocumented releases no longer are.

