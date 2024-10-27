# tooCeWL

Based on [CeWL](https://github.com/digininja/CeWL), Robin Wood's famous tool, tooCeWL is a simple bash script that acts as a wrapper and allows to spider multiple URLs at once to create one, big custom wordlist.

All rights go to Robin Wood, aka dijininja, all I did was simply build something around it as I don't know Ruby.

## Usage

```text
tooCeWL is a bash wrapper of CeWL by Robin Wood (https://github.com/digininja/CeWL)
This tool is used to spider multiple URLs at once

Made with love by c0rgo (https://github.com/spacec0rgo)

Usage:
        ./toocewl.sh [flags] ... (filename)
    
Flags:
        -h, --help		print this help page
        -p, --path              save results to path, default is ~/tooCeWL/results
        -k, --keep              keep the downloaded files
        -d <x>,--depth <x>	depth to spider to, default 2
        -m, --min_word_length   minimum word length, default 4
        -x, --max_word_length   maximum word length, default unset
        -o, --offsite           let the spider visit other sites
        --exclude               a file containing a list of paths to exclude
        --allowed               a regex pattern that path must match to be followed
        -u, --ua <agent>        user agent to send
        --lowercase             lowercase all parsed words
        --with-numbers          accept words with numbers in as well as just letters
        --convert-umlauts       convert common ISO-8859-1 (Latin-1) umlauts (ä-ae, ö-oe, ü-ue, ß-ss)
        -a, --meta              include meta data
        -e, --email             include email addresses
        --meta-temp-dir <dir>   the temporary directory used by exiftool when parsing files, default /tmp
        -c, --count             show the count for each word found
        -v, --verbose           verbose
        --debug                 extra debug information
        
        Authentication
        --auth_type             digest or basic
        --auth_user             authentication username
        --auth_pass             authentication password

        Proxy Support
        --proxy_host            proxy host
        --proxy_port            proxy port, default 8080
        --proxy_username        username for proxy, if required
        --proxy_password        password for proxy, if required

        Headers
        --header, -H            in format name:value - can pass multiple
```

## Contribution

Any suggestion on how to improve this script is welcome.