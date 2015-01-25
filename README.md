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

To install version 1.4, for example:
``` bash
GIMME_GO_VERSION=1.4 gimme

# or:

gimme 1.4
```

Or run without installing:

``` bash
GIMME_GO_VERSION=1.4 curl -sL https://raw.githubusercontent.com/meatballhat/gimme/master/gimme | bash
```
