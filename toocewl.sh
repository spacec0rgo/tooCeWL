#!/bin/bash

############################################################
################### EDIT THESE IF NEEDED ###################
############################################################

### Minimum required character for word
### Eg. for minimum of 5 the word 'money' is considered
### while 'dev' or 'cash' are not
defaultMinWordLength="4"

### How much depth is used to search for words
### Eg. a depth of 2 tells to stop at http://domain.com/dir/dir/
### a depth of 3 tells to stop at http://domain.com/dir/dir/dir/
defaultDepth="2"

### Custom path to save the results
### The value not defined since default is user home
### Can be set set with -p, --path flag or edited here for persistence
customDirectory=""

############################################################
############################################################
############################################################

### OTHER SETTINGS

defaultMaxWordLength=""
defaultOffsite=""
defaultExclude=""
defaultAllowed=""
defaultUserAgent=""
defaultLowercase=""
defaultWithNumbers=""
defaultConvertUmlauts=""
defaultMeta=""
defaultEmail=""
defaultMetaTempDir=""

defaultCount=""
defaultVerbose=""
defaultDebug=""

# Authentication
defaultAuthType=""
defaultAuthUser=""
defaultAuthPass=""

# Proxy Support
defaultProxyHost=""
defaultProxyPort=""
defaultProxyUser=""
defaultProxyPass=""

# Headers
defaultHeader=""

### VARIABLES

RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
#PURPLE="\033[1;35m"
#CYAN="\033[1;36m"
UND_CYAN="\033[1;4;36m"
LIGTH_GRAY="\033[0;37m"
RESET="\033[0m"

catFiles=""

### HELP PAGE

helpPage="tooCeWL is a bash wrapper of CeWL by Robin Wood (https://github.com/digininja/CeWL)
This tool is used to spider multiple websites at once

Made with love by c0rgo (https://github.com/spacec0rgo)

Usage:
        ./toocewl.sh [flags] ... (filename)
    
Flags:
        -h, --help		print this help page
        -p, --path              save results to path, default is user home
        -k, --keep              keep the downloaded files
        -d <x>,--depth <x>	depth to spider to, default $defaultDepth
        -m, --min_word_length   minimum word length, default $defaultMinWordLength
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
        --header, -H            in format name:value - can pass multiple"

### FUNCTIONS
map_ctrl_c () {
        echo -e "${RED} [\u2716] Aborted${RESET}"
        exit 1
}

printHelp () {
        echo "$helpPage"
}

printDone () {
        echo -e "${GREEN} [\u2714] DONE${RESET}"
}

handleFlags () {
        if [ $# -eq 0 ]; then
                printHelp
                echo -e "${YELLOW}[!] You need to specify at least the URLs list filename before launching tooCeWL ...${RESET}"
                exit 1
        else
        	while [ $# -gt 0 ]; do
                        case $1 in
                                -h | --help)
                                        printHelp
                                        exit 0
                                        shift;;
                                -k | --keep)
                                        defaultKeepFile="-k"
                                        shift;;
                                -p | --path)
                                        customDirectory="$2"
                                        shift;;
                                -d | --depth)
                                        defaultDepth="$2"
                                        shift;;
                                -m | --min_word_length)
                                        defaultMinWordLength="$2"
                                        shift;;
                                -x | --max_word_length)
                                        defaultMaxWordLength="-x $2"
                                        shift;;
                                -o | --offsite)
                                        defaultOffsite="-o"
                                        shift;;
                                --exclude)
                                        defaultExclude="--exclude $2"
                                        shift;;
                                --allowed)
                                        defaultAllowed="--allowed $2"
                                        shift;;
                                -u | --ua)
                                        defaultUserAgent="-u \"$2\""
                                        shift;;
                                --lowercase)
                                        defaultLowercase="--lowercase"
                                        ;;
                                --with-numbers)
                                        defaultWithNumbers="--with-numbers"
                                        ;;
                                --convert-umlauts)
                                        defaultConvertUmlauts="--convert-umlauts"
                                        ;;
                                -a | --meta)
                                        defaultMeta="-a"
                                        ;;
                                -e | --email)
                                        defaultEmail="-e"
                                        ;;
                                --meta-temp-dir)
                                        defaultMetaTempDir="--meta-temp-dir $2"
                                        shift;;
                                -c | --count)
                                        defaultCount="-c"
                                        ;;
                                -v | --verbose)
                                        defaultVerbose="-v"
                                        ;;
                                --debug)
                                        defaultDebug="--debug"
                                        ;;
                                ### Authentication
                                --auth_type)
                                        defaultAuthType="--auth_type $2"
                                        shift;;
                                --auth_user)
                                        defaultAuthUser="--auth_user $2"
                                        shift;;
                                --auth_pass)
                                        defaultAuthPass="--auth_pass $2"
                                        shift;;
                                ### Proxy Support
                                --proxy_host)
                                        defaultProxyHost="--proxy_host $2"
                                        shift;;
                                --proxy_port)
                                        defaultProxyPort="--proxy_port $2"
                                        shift;;
                                --proxy_username)
                                        defaultProxyUser="--proxy_username $2"
                                        shift;;
                                --proxy_password)
                                        defaultProxyPass="--proxy_password $2"
                                        shift;;
                                ### Headers
                                -H | --header)
                                        defaultHeader+="-H $2 "
                                        shift;;
                                ### Wildcard
                                *)
                                        if [ ! -f "$1" ]; then
                                                echo "Invalid option: $1" >&2
                                                echo -n $'\n'
                                                printHelp
                                                exit 1
                                        else
                                                filename="$1"
                                        fi
                                        ;;
                        esac
                        shift
                done
        fi
}

makePath () {
        executionTime=$(date "+%Y-%m-%d_%H%M%S")
        maindir="tooCeWL/results"

        if [[ ! -z "$customDirectory" ]]; then
                savedir="$customDirectory"
                savepath="$savedir/tooCeWL_$executionTime"
        else
                savedir="$HOME/$maindir"
                savepath="$savedir/$executionTime"
        fi
        
        metapath="$savepath/meta"
        emailpath="$savepath/email"

        fullWordlistPath="$savepath/wordlist_$executionTime.txt"
}

craft_flags () {
        cewlFlags="-d $defaultDepth -m $defaultMinWordLength
        $defaultKeepFile
        $defaultMaxWordLength
        $defaultOffsite
        $defaultExclude
        $defaultAllowed
        $defaultUserAgent
        $defaultLowercase
        $defaultWithNumbers
        $defaultConvertUmlauts
        $defaultMeta
        $defaultEmail
        $defaultMetaTempDir
        $defaultCount
        $defaultVerbose
        $defaultDebug
        $defaultAuthType
        $defaultAuthUser
        $defaultAuthPass
        $defaultProxyHost
        $defaultProxyPort
        $defaultProxyUser
        $defaultProxyPass
        $defaultHeader"

        cewlFlags=$(echo $cewlFlags)
}

### PRE-SCRIPT CONTROLS

if [ ! "$(which cewl &>/dev/null ; echo $?)" -eq 0 ]; then
        echo -e "${YELLOW}[!] CeWL is NOT installed ...${RESET}"
        echo -e "${YELLOW} [+] Install it by using the proper package manager ...${RESET}"
        echo -e "${RED} [\u2716] Aborted ${RESET}"
        exit 1 
fi

### HANDLE FLAGS BEFORE STARTING SCRIPT

handleFlags "$@"

### HANDLE THE KEYBOARD INTERRUPTS
trap map_ctrl_c SIGINT SIGTERM

### IF EVERYTHING IS OK
### TIME TO GO

### CHECK DIRECTORY EXISTENCE

# Define savepath before creating directories
makePath

if [[ ! -d "$savepath" ]]; then
	mkdir -p "$savepath"
fi

if [[ ! -d "$metapath" ]] && [[ ! -z "$defaultMeta" ]]; then
        mkdir -p "$metapath"
fi

if [[ ! -d "$emailpath" ]] && [[ ! -z "$defaultEmail" ]]; then
        mkdir -p "$emailpath"
fi

### START OF SCRIPT

echo -e "${BLUE}[+] Starting tooCeWL from file $filename ...${RESET}"
echo -e "${YELLOW} [!] This may take some time, depending on the URLs list length ...${RESET}"
echo -n $'\n'

while IFS="" read -r url
do
	domain="$(echo $url | sed -E 's/^http(|s):\/\///;s/\/(([a-z](|\-))*\/)*//')"
        normalized_domain=$(echo $domain | tr -s "." "_" | tr -s "/" "_")
	savedWordlist="$savepath/$normalized_domain"
	catFiles+=$(echo -n "$savedWordlist " | tr -s "\n" " ")

        #set -x
        if [[ ! -z "$defaultMeta" ]]; then
                metafile="$metapath/meta_$normalized_domain"
                defaultMeta="-a --meta_file $metafile"
        fi

        if [[ ! -z "$defaultEmail" ]]; then
                emailfile="$emailpath/email_$normalized_domain.txt"
                defaultEmail="-e --email_file $emailfile"
        fi

	craft_flags

	echo -e "${BLUE}[+] Spidering ${UND_CYAN}$url${RESET}${BLUE} ...${RESET}"

        if [[ ! -z "$defaultVerbose" ]] || [[ ! -z "$defaultDebug" ]]; then
                eval cewl "$cewlFlags" "-w $savedWordlist" "$url"
        else
                eval cewl "$cewlFlags" "-w $savedWordlist" "$url" 1>/dev/null
        fi
        #set +x

        echo -e "${BLUE} [!] Wordlist file saved at ${LIGTH_GRAY}$savedWordlist ${RESET}"
        
        if [[ -f "$metafile" ]]; then
                echo -e "${BLUE} [!] Meta file saved at ${LIGTH_GRAY}$metafile ${RESET}"
        fi
        
        if [[ -f "$emailfile" ]]; then
                echo -e "${BLUE} [!] Email file saved at ${LIGTH_GRAY}$emailfile ${RESET}"
        fi
	
        echo -n $'\n'
done < $filename

echo -e "${BLUE}[+] Saving full ordered wordlist to ${LIGTH_GRAY}$fullWordlistPath ${RESET}${BLUE}...${RESET}"
if [[ ! -z "$defaultCount" ]]; then
        cat $catFiles | sort > "$fullWordlistPath"
else
        cat $catFiles | sort -u > "$fullWordlistPath"
fi

printDone

### END OF SCRIPT
