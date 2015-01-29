# gimme

Install go, yay!

`gimme` is a shell script that knows how to install [go](https://golang.org).  Fancy! :tada:

## Installation & usage

Install from github:

``` bash
# assumes ~/bin exists and is in $PATH, so adjust accordingly!

curl -sL -o ~/bin/gimme https://raw.githubusercontent.com/meatballhat/gimme/master/gimme
chmod +x ~/bin/gimme
```

Then check the help text a la:

``` bash
gimme help
```

To install and use version 1.4, for example:
``` bash
eval "$(GIMME_GO_VERSION=1.4 gimme)"

# or:

eval "$(gimme 1.4)"

# or if you can't stand the thought of using `eval`:

gimme 1.4 | source /dev/stdin
```

Or run without installing:

``` bash
eval "$(GIMME_GO_VERSION=1.4 curl -sL https://raw.githubusercontent.com/meatballhat/gimme/master/gimme | bash)"
```
