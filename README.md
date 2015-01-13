# gimme

Gimme the Go already

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

