# gimme [![Build Status](https://travis-ci.org/travis-ci/gimme.svg?branch=master)](https://travis-ci.org/travis-ci/gimme)

Install go, yay!

`gimme` is a shell script that knows how to install [go](https://golang.org).  Fancy! :tada:

## Installation & usage

Requires `jq` for JSON processing.  This is a common tool.

Install from github:

``` bash
# assumes ~/bin exists and is in $PATH, so adjust accordingly!

curl -sL -o ~/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
chmod +x ~/bin/gimme
```

[Homebrew](http://brew.sh) (OS X):

```bash
brew install jq gimme
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
