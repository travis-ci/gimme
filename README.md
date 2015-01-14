# gimme

Install go, yay!

`gimme` is a shell script that knows how to install [go](https://golang.org).  Fancy! :tada:

## Installation & usage

Install from github:

``` bash
curl -sL -o ${PATH%%:*}/gimme https://raw.githubusercontent.com/meatballhat/gimme/master/gimme
chmod +x ${PATH%%:*}/gimme
```

Then check the help text a la:

``` bash
gimme help
```

To install version 1.4, for example:
``` bash
gimme 1.4
```

Or run without installing:

``` bash
GIMME_GO_VERSION=1.4 curl -sL https://raw.githubusercontent.com/meatballhat/gimme/master/gimme | bash
```

## `goenv` compatibility

As [goenv](https://github.com/wfarr/goenv) doesn't care much how binaries get into the versions dir, compatibility looks
like this:

``` bash
GIMME_VERSIONS_DIR=${HOME}/.goenv/versions
```
