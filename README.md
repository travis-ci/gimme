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
eval "$(curl -sL https://raw.githubusercontent.com/meatballhat/gimme/master/gimme | GIMME_GO_VERSION=1.4 bash)"
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
