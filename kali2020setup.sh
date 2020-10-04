#!/bin/bash
#-METADATA------------------------------------------------------------------#
#  Filename: .kali2020setup.sh            (Update: 9/15/2020)               #
#-INFO----------------------------------------------------------------------#
#  Post-installation script for Kali Linux                                  #
#                                                                           #
#-AUTHOR(S)-----------------------------------------------------------------#
#  Creator   : StuckInTheStack ~ https://github.com/StuckInTheStack         #
#  This script is an adaptation that heavily relied on prior scripts by:    #
#         g0tmilk ~ https://blog.g0tmi1k.com/                               #
#         drkpasngr ~ https://drkpasngr.github.io/                          #
#                                                                           #
#-TARGET OPERATING SYSTEM---------------------------------------------------#
#  Designed for: Kali Linux Rolling 2020.3 [x64] (VMWare)                   #
#  Tested on   : Kali Linux Rolling 2020.3 [x64] (VMWare)                   #
#                                                                           #
#-LICENSE-------------------------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT                         #
#                                                                           #
#-INSTRUCTIONS--------------------------------------------------------------#
#  1. Run as root after a clean install of Kali Linux.                      #
#     *  Create a clone or snapshot prior to any changes.                   #
#                             ---                                           #
#  2. You will need 25GB  free HDD space before running.                    #
#                  (10GB if -noteverything passed as argument)              #
#  3. Command line arguments:                                               #
#      -burp     = Deletes Burpsuite community (for Pro users)              #
#      -noteverything =Does not load every kali package(saves15Gb)          #
#      -keepdirs = Stops deletion of the Public,Videos,Templates,and Music  #
#      -dns      = Use OpenDNS and locks permissions                        #
#      -osx      = Changes to Apple keyboard layout                         #
#    -keyboard <value> = Change the keyboard layout language (default US )  #
#    -timezone <value> = Change the timezone location (default geolocated)  #
#                                   "US/Pacific"                            #
#                             ---                                           #
#  Use with# ./kali2020setup.sh -burp -keepdirs -dns -noteverything         #
#                                                                           #
#-DISCLAIMER----------------------------------------------------------------#
#  ** This script configures Kali How I like it. **                         #
#  ** Please edit it and make it your own. **                               #
#---------------------------------------------------------------------------#


#-Defaults-------------------------------------------------------------#

##### Kali home directories and your Github tools information
HOME="/home/kali"
ROOT="/root"
GITHUBURL="http://github.com/StuckInTheStack"  # used potentially to download your own tools


##### Location information
keyboardApple=false         # Using a Apple/Macintosh keyboard (non VM)?                [ --osx ]
keyboardLayout="us"           # Set keyboard layout, default=us                         [ --keyboard us]
timezone=""                 # Set timezone location                                     [ --timezone US/Chicago ]

##### Optional steps
hardenDNS=false       # Set static & lock DNS name server                               [ --dns ]
DelBurp=false         # Will delete Burp Community from the host ( for Burp Pro users ) [ -burp ]
KeepDirs=false        # Prevent deletion of Public,Videos,Templates,Music directories   [ -keepdirs ]   
NotEverything=false   # Prevent loading of all the available tools                      [ -noteverything ]


##### (Optional) Enable debug mode?
#set -x

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                         # Where are we up to
TOTAL=$( grep '(${STAGE}/${TOTAL})' $0 | wc -l );(( TOTAL-- ))  # How many things have we got todo


#-Arguments------------------------------------------------------------#


##### Read command line arguments
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]; do
  opt="${1}";
  shift;
  case "$(echo ${opt} | tr '[:upper:]' '[:lower:]')" in
    -|-- ) break 2;;

    -osx|--osx )
      keyboardApple=true;;
    -apple|--apple )
      keyboardApple=true;;

    -dns|--dns )
      hardenDNS=true;;

    -burp|--burp )
      DelBurp=true;;

    -noteverything|--noteverything )
      NotEverything=true;;

    -keepdirs|--keepdirs )
      KeepDirs=true;;

    -keyboard|--keyboard )
      keyboardLayout="${1}"; shift;;
    -keyboard=*|--keyboard=* )
      keyboardLayout="${opt#*=}";;

    -timezone|--timezone )
      timezone="${1}"; shift;;
    -timezone=*|--timezone=* )
      timezone="${opt#*=}";;

    *) echo -e ' '${RED}'[!]'${RESET}" Unknown option: ${RED}${x}${RESET}" 1>&2 \
      && exit 1;;
   esac
done


##### Check user inputs
if [[ -n "${timezone}" && ! -f "/usr/share/zoneinfo/${timezone}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" Looks like the ${RED}timezone '${timezone}'${RESET} is incorrect/not supported (Example: ${BOLD}Europe/London${RESET})" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
  exit 1
elif [[ -n "${keyboardLayout}" && -e /usr/share/X11/xkb/rules/xorg.lst ]]; then
  if ! $(grep -q " ${keyboardLayout} " /usr/share/X11/xkb/rules/xorg.lst); then
    echo -e ' '${RED}'[!]'${RESET}" Looks like the ${RED}keyboard layout '${keyboardLayout}'${RESET} is incorrect/not supported (Example: ${BOLD}gb${RESET})" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
    exit 1
  fi
fi


#-Start----------------------------------------------------------------#


##### Check if we are running as root - else this script will fail (Hard!)
if [[ "${EUID}" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" This script must be ${RED}run as root${RESET}" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
  exit 1
else
  echo -e " ${BLUE}[*]${RESET} ${BOLD}Post-installation script for Kali Linux.${RESET}"
  sleep 3s
fi


##### Checking if there is at least 25/10Mb of space availale on the disk, feel free to change the limit if your modifications use less.
if [[ "${NotEverything}" = "true" ]] ; then
DiskNeeded="10000000";
else
DiskNeeded="25000000";
fi
if [[  $(df | grep /dev/s  | head -n 1 | tr -s [:space:] " " | cut -d " " -f 4) -lt "${DiskNeeded}" ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There may not 25Gb space available on the disk to install kali-linux-everything. Still need 10Mb with the -noteverything argument."
  echo -e ' '${RED}'[!]'${RESET}" Quitting..."
  exit 1
else
  echo -e " ${GREEN}[i]${RESET} You have at least 25Gb default (or 10Gb with -noteverything) of available space on the disk..."
fi


##### Check Internet access
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Checking ${GREEN}Internet access${RESET}"
#--- Can we ping google?
for i in {1..10}; do ping -c 1 -W ${i} www.google.com &>/dev/null && break; done
#--- Run this, if we can't
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" ${RED}Possible DNS issues${RESET}(?)" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Will try and use ${YELLOW}DHCP${RESET} to 'fix' the issue" 1>&2
  chattr -i /etc/resolv.conf 2>/dev/null
  dhclient -r
  #--- Second interface causing issues?
  ip addr show eth1 &>/dev/null
  [[ "$?" == 0 ]] \
    && route delete default gw 192.168.155.1 2>/dev/null
  #--- Request a new IP
  dhclient
  dhclient eth0 2>/dev/null
  dhclient wlan0 2>/dev/null
  #--- Wait and see what happens
  sleep 15s
  _TMP="true"
  _CMD="$(ping -c 1 8.8.8.8 &>/dev/null)"
  if [[ "$?" -ne 0 && "$_TMP" == "true" ]]; then
    _TMP="false"
    echo -e ' '${RED}'[!]'${RESET}" ${RED}No Internet access${RESET}" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" You will need to manually fix the issue, before re-running this script" 1>&2
  fi
  _CMD="$(ping -c 1 www.google.com &>/dev/null)"
  if [[ "$?" -ne 0 && "$_TMP" == "true" ]]; then
    _TMP="false"
    echo -e ' '${RED}'[!]'${RESET}" ${RED}Possible DNS issues${RESET}(?)" 1>&2
    echo -e ' '${RED}'[!]'${RESET}" You will need to manually fix the issue, before re-running this script" 1>&2
  fi
  if [[ "$_TMP" == "false" ]]; then
    (dmidecode | grep -iq virtual) && echo -e " ${YELLOW}[i]${RESET} VM Detected"
    (dmidecode | grep -iq virtual) && echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Try switching network adapter mode${RESET} (e.g. NAT/Bridged)"
    echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
    exit 1
  fi
else
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Detected Internet access${RESET}" 1>&2
fi


##### Cpdating the cache
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}the cache${RESET}"
apt update 1>/dev/null


##### Making my own preset directories for my preset tools to be downloaded later ( and ssh keys )
#   I'm particular about how I like my directories, please change to your taste.
#   /wintools      =privilege escalation tools I would always upload to a windows host
#   /linuxtools    =privilege escalation tools I would always upload to a linux host
#   /toolslinuxall =linux tools I use, but don't want to upload every time
#   /toolswinall   =windows tools I use, but don't want to upload every time
#   /.local/bin    =scripts and binaries I want to incude on PATH
#   /shells        =easy access to a collections of shell scripts and binaries 
#   /lists         =collections of custom lists for enumeration and cracking
#   /logs          =log files for saving bash output and input
#   /Pictures/Wallpapers =gotta brand yourself
#
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Creating tools directories and deleting unused directories..."
mkdir /home/kali/.ssh
mkdir /home/kali/linuxtools
mkdir /home/kali/toolslinuxall
mkdir /home/kali/wintools
mkdir /home/kali/toolswinall
mkdir /home/kali/shells
mkdir /home/kali/lists
mkdir /home/kali/logs
mkdir /home/kali/Pictures/Wallpapers
mkdir /home/kali/.local/bin
chown -R kali:kali /home/kali
chmod +wr /home/kali/*  # required to allow root to write /home/kali/.cache
mkdir /root/.ssh
if [[ "${KeepDirs}" = "false" ]]; then
  echo "Removing Public, Templates, Vidoes, and Music home directories..."
  rmdir /home/kali/Public
  rmdir /home/kali/Templates
  rmdir /home/kali/Videos
  rmdir /home/kali/Music
  rmdir /root/Public
  rmdir /root/Templates
  rmdir /root/Videos
  rmdir /root/Music;
else
  echo "Keeping the Public, Templates, Vidoes, and Music home directories...";
fi


##### Mounting my local host machine share that I can use for file transfers ( also can use github or other internet facing storage )  
#   If you have some tools that have your own passwords or privately obfuscated tools, then I use
#       a local file share to upload them into kali. This can be replaced with in internet facing private cloud, etc...
#   It is preferable to load tools directly from the source so you're always getting the latest updated tool.
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Mounting host OS share onto /mnt/hgfs..."
mkdir /mnt/hgfs 2>/dev/null 
mount -t cifs //192.168.1.99/Shared /mnt/hgfs -o user=kali,pass=kali 1>/dev/null
chmod -R 777 /mnt/hgfs


##### Downloading my preset tools, lists, and wallpapers from the host OS share  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading local tools from localshare and internet..." 1>&2

cp -r /mnt/hgfs/lists/* /home/kali/lists 1>/dev/null 1>&2
cp -r /mnt/hgfs/shells/* /home/kali/shells 1>&2 
cp -r /mnt/hgfs/wallpapers/* /home/kali/Pictures/Wallpapers 1>&2 

cp -r /mnt/hgfs/linuxtools/* /home/kali/linuxtools 1>&2 
cp -r /mnt/hgfs/toolslinuxall/* /home/kali/toolslinuxall  1>&2 
cd /home/kali/linuxtools 1>&2
wget https://github.com/StuckInTheStack/Kali2020Setup/blob/master/aliases 1>&2    # copies over my aliases that I use on kali and linux hosts
wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh 1>&2
wget https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/linPEAS/linpeas.sh 1>&2
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh 1>&2
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s 1>&2 
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s 1>&2 
chmod +x /home/kali/linuxtools /home/kali/toolslinuxall 1>&2  

cp -r /mnt/hgfs/wintools/* /home/kali/wintools 1>&2
cp -r /mnt/hgfs/toolswinall/* /home/kali/toolswinall 1>&2
cd /home/kali/wintools/ 1>&2
wget "https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/blob/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASany.exe" 1>&2
wget https://github.com/carlospolop/winPE/tree/master/binaries/watson/WatsonNet3.5AnyCPU.exe 1>&2 
wget https://github.com/carlospolop/winPE/tree/master/binaries/watson/WatsonNet4AnyCPU.exe 1>&2 
curl -LJ https://eternallybored.org/misc/wget/1.20/32/wget.exe > /home/kali/wintools/wget.exe 1>&2 
wget https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/blob/master/Seatbelt.exe 1>&2
wget https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/blob/master/SharpUp.exe 1>&2


##### Downloading my aliases and scripts from the host OS share then adding aliases from this script
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading tools from localshare then adding aliases from this script..." 1>&2
file=/home/kali/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
cp -r /mnt/hgfs/.scripts/* /home/kali/.local/bin 1>&2       #copies my custom scripts to .local/bin to be in PATH
export PATH=/home/kali/.local/bin:$PATH 
echo 'export PATH=/home/kali/.local/bin:$PATH' >> /home/kali/.bashrc
echo 'export PATH=/home/kali/.local/bin:$PATH' >> /root/.bashrc


if [ ! -f "/home/kali/.bash_aliases" ]; then      # copy over my standard /linuxtools/aliases if no .bash_aliases
cp /home/kali/linuxtools/aliases /home/kali/.bash_aliases;
fi
#if [ -f "/home/kali/.bashrc" ]; then #These commands should not be necessary as std .bashrc includes .bash_aliases
#echo  ". \"/home/kali/.bash_aliases\" " >> /home/kali/.bashrc; 
#fi
if [ -f "/root/.bashrc" ]; then
echo  ". \"/home/kali/.bash_aliases\" " >> /root/.bashrc; # for root to source /home/kali/.bash_aliases
fi

if [ -n "$(grep "### ALIASES LOADED" /home/kali/.bash_aliases )" ]; then   ### ALIASES LOADED signals that these aliases are already in .bash_aliases
  echo -e ' '${YELLOW}'[!]'${RESET}" The aliases have already been appended to .bash_aliases.  Skipping bulk copy..." 1>&2;
else
  cat /home/kali/linuxtools/aliases >> /home/kali/.bash_aliases  1>&2
  echo -e ' '${YELLOW}'[!]'${RESET}" The aliases have been bulked copied to /home/kali/.bash_aliases...";
fi

if  cat /home/kali/.bash_aliases | grep -q "### ALIASES LOADED" ; then   ### ALIASES LOADED signals that these aliases are already in .bash_aliases
  echo -e ' '${YELLOW}'[!]'${RESET}" The aliases have already been appended to .bash_aliases.  Skipping script alias write...";
else
  echo -e ' '${YELLOW}'[!]'${RESET}" Writing aliases to .bash_aliases..." 1>&2
  echo -e '### ALIASES LOADED\n' >> "${file}" 
  echo -e 'alias ll="ls -l --block-size=1 --color=always "\n' >> "${file}"
  echo -e 'alias la="ls -altrh --color=always "\n' >> "${file}" 
  echo -e 'alias grep="grep --color=always "\n' >> "${file}"
  echo -e 'alias sp="searchsploit "\n' >> "${file}"
  echo -e 'alias spm="searchsploit -m "\n' >> "${file}"
  echo -e 'alias spx="searchsploit -x "\n' >> "${file}"
  echo -e 'alias mp="mousepad "\n' >> "${file}"
  echo -e 'function mcd () { mkdir -p $1; cd $1;} \n' >> "${file}"
  echo -e 'function me () { chmod +x $1;} \n' >> "${file}"
  echo -e 'alias listen="netstat -antp | grep LISTEN "\n' >> "${file}"
  echo -e 'alias nmap="nmap --reason --open --stats-every 3m --max-retries 1 --max-scan-delay 20 --defeat-rst-ratelimit "\n' >> "${file}"
  echo -e 'alias ports="netstat -tulanp "\n' >> "${file}"
  echo -e 'alias httpup="python3 -m http.server " # quick http server usage: httpup [port=8000]\n' >> "${file}"
  echo -e 'alias ftpup="python3 -m pyftpdlib -wV -p "   # quick anonymous ftp server usage: ftpup 21\n' >> "${file}"
  echo -e 'alias smbup="python3 /opt/impacket/examples/smbserver.py " # quick smb share usage: smbup [-smb2support] <name> <path>\n' >> "${file}"
  echo -e '\n' >> "${file}"
  echo -e 'function rg() {\n' >> "${file}"
  echo -e 'if [ -z $1 ]; then\n' >> "${file}"
  echo -e 'echo "Bash script to recursively search from the current directory for given search term in all files."\n' >> "${file}"
  echo -e 'echo "Use with:  rg <term> [term, term, ...]"; \n' >> "${file}"
  echo -e 'return 1  \n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e 'search=""\n' >> "${file}"
  echo -e 'for string in "$@" \n' >> "${file}"
  echo -e 'do\n' >> "${file}"
  echo -e '  if [ -z $search ]; then\n' >> "${file}"
  echo -e '    search=$string; \n' >> "${file}"
  echo -e '  else\n' >> "${file}"
  echo -e '    search=$search" | "$string;\n' >> "${file}"
  echo -e '  fi\n' >> "${file}"
  echo -e 'done\n' >> "${file}"
  echo -e 'grep -R -n -i $search . 2>/dev/null;\n' >> "${file}"
  echo -e '}\n' >> "${file}"
  echo -e '\n' >> "${file}"
  echo -e 'function ge() {\n' >> "${file}"
  echo -e 'if [ -z $1 ]; then \n' >> "${file}"
  echo -e 'echo "This function calls firefox to search with google.com for exploit + whatever arguments given,"\n' >> "${file}"
  echo -e 'echo "Use with:  ge [service] [version] [github|anyotherterm]";\n' >> "${file}"
  echo -e 'return 1\n' >> "${file}"
  echo -e 'local s="$_"\n' >> "${file}"
  echo -e 'local query=\n' >> "${file}"
  echo -e 'case "$1" in\n' >> "${file}"
  echo -e '    '')   ;;\n' >> "${file}"
  echo -e '    *)    s="$*"; query="search?q=exploit+${s//[[:space:]]/+}" ;;\n' >> "${file}"
  echo -e 'esac\n' >> "${file}"
  echo -e 'firefox "http://www.google.com/${query}"\n' >> "${file}"
  echo -e '}\n' >> "${file}"
  echo -e '\n' >> "${file}"
  echo -e 'function showweb() \n' >> "${file}"
  echo -e '{\n' >> "${file}"
  echo -e 'if [ -z "$1" ]; then \n' >> "${file}"
  echo -e 'echo "Usage is: showweb <IPorwebsite>"\n' >> "${file}"
  echo -e 'echo "Need Firefox already running, puts new tabs into last touched firefox instance, only 1 argument allowed";\n' >> "${file}"
  echo -e 'return 1\n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e 'firefox http://"$1" &\n' >> "${file}"
  echo -e 'sleep .1\n' >> "${file}"
  echo -e 'firefox --new-tab view-source:http://"$1" &\n' >> "${file}"
  echo -e 'sleep .1\n' >> "${file}"
  echo -e 'firefox --new-tab https://"$1" &\n' >> "${file}"
  echo -e 'sleep .1\n' >> "${file}"
  echo -e 'firefox --new-tab view-source:https://"$1" &\n' >> "${file}"
  echo -e '}\n' >> "${file}"
  echo -e '\n' >> "${file}"
  echo -e 'function cool() {\n' >> "${file}"
  echo -e 'if [ -z "$1" ]; then \n' >> "${file}"
  echo -e 'echo "Bash script to search a given site with cewl to level set by second argument and mutate with john."\n' >> "${file}"
  echo -e 'echo "Output is stored in cool.lst file."\n' >> "${file}"
  echo -e 'echo "Use with:  cool <website/IPaddr> [depth:3]"; \n' >> "${file}"
  echo -e 'return 1\n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e 'if [ -z $2 ]\n' >> "${file}"
  echo -e 'then\n' >> "${file}"
  echo -e '  cewl $1 -d 3 -m 3 -w cool.tmp0 -a --with-numbers\n' >> "${file}"
  echo -e 'else\n' >> "${file}"
  echo -e '  cewl $1 -d $2 -m 3 -w cool.tmp0 -a --with-numbers\n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e 'cat cool.tmp0 | sort -u > cool.tmp1\n' >> "${file}"
  echo -e 'john --wordlist=cool.tmp1 --rules --stdout > cool.lst\n' >> "${file}"
  echo -e 'rm cool.tmp0\n' >> "${file}"
  echo -e 'rm cool.tmp1\n' >> "${file}"
  echo -e '}\n' >> "${file}"
  echo -e '\n' >> "${file}"
  echo -e 'extract() {\n' >> "${file}"
  echo -e 'if [ -z "$1" ]; then \n' >> "${file}"
  echo -e 'echo "Bash script to extract any compressed file."\n' >> "${file}"
  echo -e 'echo "Use with:  extract <file>";\n' >> "${file}"
  echo -e 'return 1\n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e 'if [[ -f \$1 ]]; then\n' >> "${file}"
  echo -e '  case \$1 in\n' >> "${file}"
  echo -e '    *.tar.bz2) tar xjf \$1 ;;\n' >> "${file}"
  echo -e '    *.tar.gz)  tar xzf \$1 ;;\n' >> "${file}"
  echo -e '    *.bz2)     bunzip2 \$1 ;;\n' >> "${file}"
  echo -e '    *.rar)     rar x \$1 ;;\n' >> "${file}"
  echo -e '    *.gz)      gunzip \$1  ;;\n' >> "${file}"
  echo -e '    *.tar)     tar xf \$1  ;;\n' >> "${file}"
  echo -e '    *.tbz2)    tar xjf \$1 ;;\n' >> "${file}"
  echo -e '    *.tgz)     tar xzf \$1 ;;\n' >> "${file}"
  echo -e '    *.zip)     unzip \$1 ;;\n' >> "${file}"
  echo -e '    *.Z)       uncompress \$1 ;;\n' >> "${file}"
  echo -e '    *.7z)      7z x \$1 ;;\n' >> "${file}"
  echo -e '    *)         echo \$1 cannot be extracted ;;\n' >> "${file}"
  echo -e '  esac\n' >> "${file}"
  echo -e 'else\n' >> "${file}"
  echo -e '  echo \$1 is not a valid file\n' >> "${file}"
  echo -e 'fi\n' >> "${file}"
  echo -e '}\n' >> "${file}";
fi

#--- Apply new aliases ( /root/.bashrc and /home/kali/.bashrc already updated to include /home/kali/.bashrc at start of this section )
source /home/kali/.bash_aliases


##### Setting wallpaper  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting wallpaper..."
cd /home/kali/Pictures/Wallpaper
wget https://raw.githubusercontent.com/StuckInTheStack/Kali2020SetUp/master/darkweavekali.jpg
wget https://raw.githubusercontent.com/StuckInTheStack/Kali2020SetUp/master/darkwwoodkaliRitter.jpg
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set /home/kali/Pictures/Wallpaper/darkwoodkaliRitter.jpg 2>/dev/null


##### Possibly deleting BurpSuite Community  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Checking if we should keep Burpsuite Community..." 1>&2
if [[ "${DelBurp}" = "true" ]]; then
  echo "Deleting Burp Community"
  apt-get remove burpsuite;
else
  echo "Keeping Burp Community";
fi


##### Install seclists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}seclist${RESET} ~ multiple types of (word)lists (and similar things)"
apt -y -qq install seclists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Link to others
apt -y -qq install wordlists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
[ -e /usr/share/seclists ] \
  && ln -sf /usr/share/seclists /usr/share/wordlists/seclists


##### Unzipping rockyou.txt and appending my custom wordlist, custom.txt  which I keep in my share's /lists directory 
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Unzipping rockyou.txt and appending my custom wordlist if custom.txt exists..." 1>&2
gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
mv /usr/share/wordlists/rockyou.txt /home/kali/lists/rockyou.txt 2>/dev/null
if [[ -e "/home/kali/lists/custom.txt" ]]; then
  mv /home/kali/rockyou.txt /home/kali/lists/rockyou.tmp 2>/dev/null
  mv /home/kali/lists/custom.txt /home/kali/lists/rockyou.txt 2>/dev/null
  cat /home/kali/lists/rockyou.tmp >> /home/kali/lists/rockyou.txt 2>/dev/null
fi


##### Enabling and initializing Metasploit Framework Database  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Enabling and initializing Metasploit Framework Database..." 1>&2
systemctl start postgresql 2>/dev/null
systemctl enable postgresql 2>/dev/null
msfdb init


##### Enabling global logging  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Enabling Global Logging ${RESET} with UNDER_SCRIPT environment variable named by time."
grep -q 'UNDER_SCRIPT' ~/.bashrc || echo 'if [[ -z "$UNDER_SCRIPT" && -z "$TMUX" && ! -z "$PS1" ]]; then
        logdir=/home/kali/logs
        if [ ! -d $logdir ]; then
                mkdir $logdir
        fi
        #gzip -q $logdir/*.log &>/dev/null
        logfile=$logdir/$(date +%F_%H_%M_%S).$$.log
        export UNDER_SCRIPT=$logfile
        script -f -q $logfile
        exit
fi' >> ~/.bashrc


##### Fix display output for GUI programs (when connecting via SSH)
export DISPLAY=:0.0
export TERM=xterm-256


##### Enable default network repositories ~ http://docs.kali.org/general-use/kali-linux-sources-list-repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Enabling default OS ${GREEN}network repositories${RESET}"
#--- Add network repositories
file=/etc/apt/sources.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#--- Main
grep -q '^deb .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "\n\n# Kali Rolling\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Source
grep -q '^deb-src .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Disable CD repositories
sed -i '/kali/ s/^\( \|\t\|\)deb cdrom/#deb cdrom/g' "${file}"
#--- incase we were interrupted
dpkg --configure -a
#--- Update
apt -qq update
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue accessing network repositories${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are the remote network repositories ${YELLOW}currently being sync'd${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} Here is ${BOLD}YOUR${RESET} local network ${BOLD}repository${RESET} information (Geo-IP based):\n"
  curl -sI http://http.kali.org/README
  exit 1
fi

##### Set static & protecting DNS name servers.   Note: May cause issues with forced values (e.g. captive portals etc)
if [[ "${hardenDNS}" != "false" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting static & protecting ${GREEN}DNS name servers${RESET}"
  file=/etc/resolv.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
  chattr -i "${file}" 1>&2 
  #--- Use OpenDNS DNS
  #echo -e 'nameserver 208.67.222.222\nnameserver 208.67.220.220' > "${file}"
  #--- Use Google DNS
  echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > "${file}"
  #--- Protect it
  chattr +i "${file}" 1>&2 
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping DNS${RESET} (missing: '$0 ${BOLD}--dns${RESET}')..." 1>&2
fi


##### Update location information - set either value to "" to skip.
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET}"
#--- Configure keyboard layout (Apple)
if [ "${keyboardApple}" != "false" ]; then
  ( (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Applying ${GREEN}Apple hardware${RESET} profile" )
  file=/etc/default/keyboard; #[ -e "${file}" ] && cp -n $file{,.bkup}
  sed -i 's/XKBVARIANT=".*"/XKBVARIANT="mac"/' "${file}"
fi
#--- Configure keyboard layout (location)
if [[ -n "${keyboardLayout}" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET} ~ keyboard layout (${BOLD}${keyboardLayout}${RESET})"
  geoip_keyboard=$(curl -s http://ifconfig.io/country_code | tr '[:upper:]' '[:lower:]')
  [ "${geoip_keyboard}" != "${keyboardLayout}" ] \
    && echo -e " ${YELLOW}[i]${RESET} Keyboard layout (${BOLD}${keyboardLayout}${RESET}) doesn't match what's been detected via GeoIP (${BOLD}${geoip_keyboard}${RESET})"
  file=/etc/default/keyboard; #[ -e "${file}" ] && cp -n $file{,.bkup}
  sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="'${keyboardLayout}'"/' "${file}"
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping keyboard layout${RESET} (missing: '$0 ${BOLD}--keyboard <value>${RESET}')..." 1>&2
fi
#--- Changing time zone
if [[ -n "${timezone}" ]]; then
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}location information${RESET} ~ time zone (${BOLD}${timezone}${RESET})"
  echo "${timezone}" > /etc/timezone
  ln -sf "/usr/share/zoneinfo/$(cat /etc/timezone)" /etc/localtime
  dpkg-reconfigure -f noninteractive tzdata
else
  echo -e "\n\n ${YELLOW}[i]${RESET} Skipping time zone set to command.${RESET} (missing: '$0 ${BOLD}--timezone <value>${RESET}')..." 1>&2
fi

#--- Installing ntp tools
(( STAGE++ )); echo -e " ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ntpdate${RESET} ~ keeping the time in sync"
apt -y -qq install ntp ntpdate  1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Update time
ntpdate -b -s -u pool.ntp.org 1>&2 
#--- Start service
systemctl restart ntp
#--- Remove from start up
systemctl disable ntp  1>&2 
#--- Only used for stats at the end
start_time=$(date +%s)


##### Update OS from network repositories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Updating OS${RESET} from network repositories"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Internet connection & Kali version/age"
for FILE in clean autoremove; do apt -y -qq "${FILE}" 1>&2 ; done         # Clean up      clean remove autoremove autoclean
export DEBIAN_FRONTEND=noninteractive
apt -qq update && APT_LISTCHANGES_FRONTEND=none apt -o Dpkg::Options::="--force-confnew" -y dist-upgrade --fix-missing  1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET}
#--- Cleaning up temp stuff
for FILE in clean autoremove; do apt -y -qq "${FILE}" 1>&2 ; done         # Clean up - clean remove autoremove autoclean
#--- Check kernel stuff
_TMP=$(dpkg -l | grep linux-image- | grep -vc meta)
if [[ "${_TMP}" -gt 1 ]]; then
  echo -e "\n ${YELLOW}[i]${RESET} Detected ${YELLOW}multiple kernels${RESET}"
  TMP=$(dpkg -l | grep linux-image | grep -v meta | sort -t '.' -k 2 -g | tail -n 1 | grep "$(uname -r)")
  if [[ -z "${TMP}" ]]; then
    echo -e '\n '${RED}'[!]'${RESET}' You are '${RED}'not using the latest kernel'${RESET} 1>&2
    echo -e " ${YELLOW}[i]${RESET} You have it ${YELLOW}downloaded${RESET} & installed, just ${YELLOW}not USING IT${RESET}"
    echo -e "\n ${YELLOW}[i]${RESET} You ${YELLOW}NEED to run apt update && apt upgrade , and then REBOOT${RESET}, before re-running this script"
    exit 1
    sleep 30s
  else
    echo -e " ${YELLOW}[i]${RESET} ${YELLOW}You're using the latest kernel${RESET} (Good to continue)"
  fi
fi


##### Install kernel headers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kernel headers${RESET}"
apt -y -qq install make gcc "linux-headers-$(uname -r)"  1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET}
if [[ $? -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue installing kernel headers${RESET}"
  echo -e " ${YELLOW}[i]${RESET} Are you ${YELLOW}USING${RESET} the ${YELLOW}latest kernel${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Run apt update && apt upgrade, and then Reboot${RESET} your machine"
  exit 1
  sleep 30s
fi


##### Install "kali full" meta packages (default tool selection)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kali-linux-everything${RESET} meta-package"
echo -e " ${YELLOW}[i]${RESET}  ...this ${BOLD}may take a while${RESET} depending on your Kali version (e.g. ARM, light, mini or docker...)"
#--- Kali's default tools ~ https://www.kali.org/news/kali-linux-metapackages/
if [[ "${NotEverything}" = "true" ]] ; then
apt -y -qq install kali-linux-default \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET};
else
apt -y -qq install kali-linux-everything  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET};
fi


##### Configure GRUB
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}GRUB${RESET} ~ boot manager"
grubTimeout=5
(dmidecode | grep -iq virtual) && grubTimeout=1   # Much less if we are in a VM
file=/etc/default/grub; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT='${grubTimeout}'/' "${file}"                           # Time out (lower if in a virtual machine, else possible dual booting)
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="vga=0x0318"/' "${file}"   # TTY resolution
update-grub


##### Configure file   Note: need to restart xserver for effect
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}file${RESET} (Nautilus/Thunar) ~ GUI file system navigation"
#--- Settings
mkdir -p ~/.config/gtk-2.0/
file=~/.config/gtk-2.0/gtkfilechooser.ini; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/^.*ShowHidden.*/ShowHidden=true/' "${file}" 2>/dev/null \
  || cat <<EOF > "${file}"
[Filechooser Settings]
LocationMode=path-bar
ShowHidden=true
ExpandFolders=true
ShowSizeColumn=true
GeometryX=66
GeometryY=39
GeometryWidth=780
GeometryHeight=618
SortColumn=name
SortOrder=ascending
EOF


##### Configure bash - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}N/${TOTAL}) Configuring ${GREEN}bash${RESET} ~ CLI shell"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
#grep -q "cdspell" "${file}" \
#  || echo "shopt -sq cdspell" >> "${file}"             # Spell check 'cd' commands
grep -q "autocd" "${file}" \
 || echo "shopt -s autocd" >> "${file}"                # So you don't have to 'cd' before a folder
grep -q "checkwinsize" "${file}" \
 || echo "shopt -sq checkwinsize" >> "${file}"         # Wrap lines correctly after resizing
#grep -q "nocaseglob" "${file}" \
# || echo "shopt -sq nocaseglob" >> "${file}"           # Case insensitive pathname expansion
#grep -q "HISTSIZE" "${file}" \
# || echo "HISTSIZE=" >> "${file}"                 # Bash history (memory scroll back)
#grep -q "HISTFILESIZE" "${file}" \
# || echo "HISTFILESIZE=" >> "${file}"             # Bash history (file .bash_history)
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install bash colour - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bash colour${RESET} ~ colours shell output"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
grep -q '^force_color_prompt' "${file}" 2>/dev/null \
  || echo 'force_color_prompt=yes' >> "${file}"
sed -i 's#PS1='"'"'.*'"'"'#PS1='"'"'${debian_chroot:+($debian_chroot)}\\[\\033\[01;31m\\]\\u@\\h\\\[\\033\[00m\\]:\\[\\033\[01;34m\\]\\w\\[\\033\[00m\\]\\$ '"'"'#' "${file}"
grep -q "^export LS_OPTIONS='--color=auto'" "${file}" 2>/dev/null \
  || echo "export LS_OPTIONS='--color=auto'" >> "${file}"
grep -q '^eval "$(dircolors)"' "${file}" 2>/dev/null \
  || echo 'eval "$(dircolors)"' >> "${file}"
grep -q "^alias ls='ls $LS_OPTIONS'" "${file}" 2>/dev/null \
  || echo "alias ls='ls $LS_OPTIONS'" >> "${file}"
grep -q "^alias ll='ls $LS_OPTIONS -l'" "${file}" 2>/dev/null \
  || echo "alias ll='ls $LS_OPTIONS -l'" >> "${file}"
grep -q "^alias l='ls $LS_OPTIONS -lA'" "${file}" 2>/dev/null \
  || echo "alias l='ls $LS_OPTIONS -lA'" >> "${file}"
#--- All other users that are made afterwards
file=/etc/skel/.bashrc   #; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/.*force_color_prompt=.*/force_color_prompt=yes/' "${file}"
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install and configure vim - all users  
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL})  ${GREEN}vim${RESET} Configuring vim -all users..."
#apt -y -qq install vim \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure vim
file=/etc/vim/vimrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.vimrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*syntax on/syntax on/' "${file}"
sed -i 's/.*set background=dark/set background=dark/' "${file}"
sed -i 's/.*set showcmd/set showcmd/' "${file}"
sed -i 's/.*set showmatch/set showmatch/' "${file}"
sed -i 's/.*set ignorecase/set ignorecase/' "${file}"
sed -i 's/.*set smartcase/set smartcase/' "${file}"
sed -i 's/.*set incsearch/set incsearch/' "${file}"
sed -i 's/.*set autowrite/set autowrite/' "${file}"
sed -i 's/.*set hidden/set hidden/' "${file}"
sed -i 's/.*set mouse=.*/"set mouse=a/' "${file}"
grep -q '^set number' "${file}" 2>/dev/null \
  || echo 'set number' >> "${file}"                                                                      # Add line numbers
grep -q '^set expandtab' "${file}" 2>/dev/null \
  || echo -e 'set expandtab\nset smarttab' >> "${file}"                                                  # Set use spaces instead of tabs
grep -q '^set softtabstop' "${file}" 2>/dev/null \
  || echo -e 'set softtabstop=4\nset shiftwidth=4' >> "${file}"                                          # Set 4 spaces as a 'tab'
grep -q '^set foldmethod=marker' "${file}" 2>/dev/null \
  || echo 'set foldmethod=marker' >> "${file}"                                                           # Folding
grep -q '^nnoremap <space> za' "${file}" 2>/dev/null \
  || echo 'nnoremap <space> za' >> "${file}"                                                             # Space toggle folds
grep -q '^set hlsearch' "${file}" 2>/dev/null \
  || echo 'set hlsearch' >> "${file}"                                                                    # Highlight search results
grep -q '^set laststatus' "${file}" 2>/dev/null \
  || echo -e 'set laststatus=2\nset statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]' >> "${file}"     # Status bar
grep -q '^filetype on' "${file}" 2>/dev/null \
  || echo -e 'filetype on\nfiletype plugin on\nsyntax enable\nset grepprg=grep\ -nH\ $*' >> "${file}"    # Syntax highlighting
grep -q '^set wildmenu' "${file}" 2>/dev/null \
  || echo -e 'set wildmenu\nset wildmode=list:longest,full' >> "${file}"                                 # Tab completion
grep -q '^set invnumber' "${file}" 2>/dev/null \
  || echo -e ':nmap <F8> :set invnumber<CR>' >> "${file}"                                                # Toggle line numbers
grep -q '^set pastetoggle=<F9>' "${file}" 2>/dev/null \
  || echo -e 'set pastetoggle=<F9>' >> "${file}"                                                         # Hotkey - turning off auto indent when pasting
#--- Set as default editor
export EDITOR="mousepad"   #update-alternatives --config editor
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^EDITOR' "${file}" 2>/dev/null \
  || echo 'EDITOR="mousepad"' >> "${file}"
#git config --global core.editor "vim"
#--- Set as default mergetool
#git config --global merge.tool vimdiff
#git config --global merge.conflictstyle diff3
#git config --global mergetool.prompt false


##### Install exe2hex
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exe2hex${RESET} ~ Inline file transfer"
apt -y -qq install exe2hexbat 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install AutoRecon  Python3 comes with the Kali Distro, but 
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}AutoRecon${RESET} ~ Automated enumeration"
apt -y -qq install python3 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install python3'${RESET} 1>&2
apt -y -qq install python3-pip 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install pip3'${RESET} 1>&2
apt -y -qq install python3-venv 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install python3-venv'${RESET} 1>&2
python3 -m pip install --user pipx 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install pipx'${RESET} 1>&2
python3 -m pipx ensurepath 1>&2  \
  || echo -e ' '${RED}'[!] Issue with pipx ensurepath'${RESET} 1>&2
echo Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/kali/.local/bin" >> /etc/sudoers 1>&2  \
  || echo -e ' '${RED}'[!] Issue with /etc/sudoers secure_path update'${RESET} 1>&2
apt -y -qq install seclists curl enum4linux gobuster nbtscan nikto nmap onesixtyone oscanner smbclient smbmap smtp-user-enum snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install requirements for AutoRecon'${RESET} 1>&2
pipx install git+https://github.com/Tib3rius/AutoRecon.git 1>&2  \
  || echo -e ' '${RED}'[!] Issue with pipx install AutoRecon'${RESET} 1>&2


##### Install Impacket python3 version 
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}python3 Impacket${RESET} ~ python3 network library"
apt install python3-impacket 1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install python3-impacket'${RESET} 1>&2


##### Install silver searcher
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}silver searcher${RESET} ~ code searching"
apt -y -qq install silversearcher-ag 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install rips
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rips${RESET} ~ source code scanner"
apt -y -qq install apache2 php git 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET}
git clone -q -b master https://github.com/ripsscanner/rips.git /opt/rips-git/ 1>&2  \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET}
pushd /opt/rips-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
file=/etc/apache2/conf-available/rips.conf
[ -e "${file}" ] \
  || cat <<EOF > "${file}"
Alias /rips /opt/rips-git

<Directory /opt/rips-git/ >
  Options FollowSymLinks
  AllowOverride None
  Order deny,allow
  Deny from all
  Allow from 127.0.0.0/255.0.0.0 ::1/128
</Directory>
EOF
ln -sf /etc/apache2/conf-available/rips.conf /etc/apache2/conf-enabled/rips.conf
systemctl restart apache2


##### Install graudit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}graudit${RESET} ~ source code auditing"
apt -y -qq install git 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/wireghoul/graudit.git /opt/graudit-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/graudit-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/graudit-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/graudit-git/ && bash graudit.sh "\$@"
EOF
chmod +x "${file}"


###### Setup pwgen
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pwgen${RESET} ~ password generator"
apt -y -qq install pwgen 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install gparted
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}GParted${RESET} ~ GUI partition manager"
apt -y -qq install gparted 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install VPN support
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}VPN${RESET} support for Network-Manager"
for FILE in network-manager-openvpn network-manager-pptp network-manager-vpnc network-manager-openconnect; do
  apt -y -qq install "${FILE}"  1>&2 \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
done


##### Install icmpsh
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}icmpsh${RESET} ~ Reverse ICMP shell"
apt -y -qq install git 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/inquisb/icmpsh.git /opt/icmpsh-git/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/icmpsh-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install dns2tcp
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dns2tcp${RESET} ~ DNS tunnelling (TCP over DNS)"
apt -y -qq install dns2tcp 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Daemon
file=/etc/dns2tcpd.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
listen = 0.0.0.0
port = 53
user = nobody
chroot = /tmp
domain = dnstunnel.mydomain.com
key = password1
ressources = ssh:127.0.0.1:22
EOF
#--- Client
file=/etc/dns2tcpc.conf; [ -e "${file}" ] && cp -n $file{,.bkup};
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
domain = dnstunnel.mydomain.com
key = password1
resources = ssh
local_port = 8000
debug_level=1
EOF
#--- Example
#dns2tcpd -F -d 1 -f /etc/dns2tcpd.conf
#dns2tcpc -f /etc/dns2tcpc.conf 178.62.206.227; ssh -C -D 8081 -p 8000 root@127.0.0.1


##### Install MinGW ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW${RESET} ~ cross compiling suite"
for FILE in mingw-w64 binutils-mingw-w64 gcc-mingw-w64 cmake mingw-w64-x86-64-dev mingw-w64-tools   gcc-mingw-w64-i686 gcc-mingw-w64-x86-64; do
  apt -y -qq install "${FILE}" 1>&2 
done


##### Install 32 bit Linux libraries
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}32 bit Linux libraries${RESET} ~ compile 32 bit Linux elfs"
apt-get -y -qq install gcc-multilib 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install gcc-multilib'${RESET} 1>&2


##### Install WINE
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
apt -y -qq install wine winetricks 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Using x64?
if [[ "$(uname -m)" == 'x86_64' ]]; then
  (( STAGE++ )); echo -e " ${GREEN}[i]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}WINE (x64)${RESET}"
  dpkg --add-architecture i386 1>&2 
  apt -qq update 1>&2 
  apt -y -qq install wine32 1>&2  \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi
#--- Run WINE for the first time
[ -e /usr/share/windows-binaries/whoami.exe ] && wine /usr/share/windows-binaries/whoami.exe &>/dev/null
#--- Setup default file association for .exe
file=~/.local/share/applications/mimeapps.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
echo -e 'application/x-ms-dos-executable=wine.desktop' >> "${file}"


##### Install MinGW (Windows) ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW (Windows)${RESET} ~ cross compiling suite"
apt -y -qq install wine 1>&2  \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
timeout 300 curl --no-progress-meter -k -L -f "http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download" > /tmp/mingw-get.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading mingw-get.zip" 1>&2       #***!!! hardcoded path!
mkdir -p ~/.wine/drive_c/MinGW/bin/
unzip -q -o -d ~/.wine/drive_c/MinGW/ /tmp/mingw-get.zip
pushd ~/.wine/drive_c/MinGW/ >/dev/null
for FILE in mingw32-base mingw32-gcc-g++ mingw32-gcc-objc; do   #msys-base
  wine ./bin/mingw-get.exe install "${FILE}" 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
done
popd >/dev/null
#--- Add to windows path
grep -q '^"PATH"=.*C:\\\\MinGW\\\\bin' ~/.wine/system.reg \
  || sed -i '/^"PATH"=/ s_"$_;C:\\\\MinGW\\\\bin"_' ~/.wine/system.reg


##### Downloading PsExec.exe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}PsExec.exe${RESET} ~ Pass The Hash 'phun'"
apt -y -qq install windows-binaries 1>&2
cp /usr/share/windows-binaries/pstools/PsExec*.exe /home/kali/toolswinall/  1>&2
cp /usr/share/windows-binaries/pstools/PsExec64.exe /home/kali/wintools/ 1>&2
echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloaded ${GREEN}PsExec.exe${RESET} ~ Pass The Hash 'phun'"


##### Install Python (Windows via WINE)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Python (Windows)${RESET}"
echo -n '[1/2]'; timeout 300 curl --no-progress-meter -k -L -f "https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi" > /tmp/python.msi \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading python.msi" 1>&2       #***!!! hardcoded path!
echo -n '[2/2]'; timeout 300 curl --no-progress-meter -k -L -f "http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download" > /tmp/pywin32.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pywin32.exe" 1>&2      #***!!! hardcoded path!
wine msiexec /i /tmp/python.msi /qb 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
pushd /tmp/ >/dev/null
rm -rf "PLATLIB/" "SCRIPTS/"
unzip -q -o /tmp/pywin32.exe
cp -rf PLATLIB/* ~/.wine/drive_c/Python27/Lib/site-packages/
cp -rf SCRIPTS/* ~/.wine/drive_c/Python27/Scripts/
rm -rf "PLATLIB/" "SCRIPTS/"
popd >/dev/null


##### Install DBeaver
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dbeaver${RESET} ~ database viewer"
apt -y -qq install dbeaver 1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install Libre Office 
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Libre Office${RESET} ~ The replacement for MSOffice"
apt -y -qq install libreoffice 1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install shellter
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellter${RESET} ~ dynamic shellcode injector"
apt -y -qq install shellter  1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install responder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Responder${RESET} ~ rogue server"
apt -y -qq install responder  1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install CrackMapExec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec${RESET} ~ Swiss army knife for Windows environments"
apt -y -qq install git \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
git clone -q -b master https://github.com/byt3bl33d3r/CrackMapExec.git /opt/crackmapexec-git/ 1>&2 \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/crackmapexec-git/ >/dev/null
git pull -q
popd >/dev/null


##### Install Empire
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}N/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
#apt -y -qq install git \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#git clone -q -b master https://github.com/PowerShellEmpire/Empire.git /opt/empire-git/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#pushd /opt/empire-git/ >/dev/null
#git pull -q
#popd >/dev/null


##### Install crowbar
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}crowbar${RESET} ~ brute force"
git clone -q -b master https://github.com/galkan/crowbar.git /opt/crowbar-git/ 1>&2 \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd /opt/crowbar-git/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
mkdir -p /usr/local/bin/
file=/usr/local/bin/crowbar-git
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd /opt/crowbar-git/ && python crowbar.py "\$@"
EOF
chmod +x "${file}"


##### Install pyftpdlib
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pytftpdlib${RESET} ~ quick ftp server"
apt -y -qq install python3-pyftpdlib 1>&2 \
  || echo -e ' '${RED}'[!] Issue with python3-pyftpdlib'${RESET} 1>&2
pip3 install pyftpdlib \
  || echo -e ' '${RED}'[!] Issue with pip3 install pyftpdlib'${RESET} 1>&2


##### Setup tftp client & server
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}N/${TOTAL}) Setting up ${GREEN}tftp client${RESET} & ${GREEN}server${RESET} ~ file transfer methods"
#apt -y -qq install tftp atftpd \
#  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure atftpd
#file=/etc/default/atftpd; [ -e "${file}" ] && cp -n $file{,.bkup}
#echo -e 'USE_INETD=false\nOPTIONS="--tftpd-timeout 300 --retry-timeout 5 --maxthread 100 --verbose=5 --daemon --port 69 /var/tftp"' > "${file}"
#mkdir -p /var/tftp/
#chown -R nobody\:root /var/tftp/
#chmod -R 0755 /var/tftp/
#--- Setup alias
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## tftp' "${file}" 2>/dev/null \
#  || echo -e '## tftp\nalias tftproot="cd /var/tftp/"\n' >> "${file}"
#--- Apply new alias
#source "${file}" || source ~/.zshrc
#--- Remove from start up
#systemctl disable atftpd
#--- Disabling IPv6 can help
#echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
#echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6


# ##### Install Pure-FTPd
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Pure-FTPd${RESET} ~ FTP server/file transfer method"
apt -y -qq install pure-ftpd 1>&2 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Setup pure-ftpd
mkdir -p /var/ftp/
groupdel ftpgroup 2>/dev/null;
groupadd ftpgroup 2>/dev/null
userdel ftp 2>/dev/null;
useradd -r -M -d /var/ftp/ -s /bin/false -c "FTP user" -g ftpgroup ftp
chown -R ftp\:ftpgroup /var/ftp/
chmod -R 0755 /var/ftp/
pure-pw userdel ftp 2>/dev/null;
echo -e '\n' | pure-pw useradd ftp -u ftp -d /var/ftp/
pure-pw mkdb
#--- Configure pure-ftpd
echo "no" > /etc/pure-ftpd/conf/UnixAuthentication
echo "no" > /etc/pure-ftpd/conf/PAMAuthentication
echo "no" > /etc/pure-ftpd/conf/NoChmod
echo "no" > /etc/pure-ftpd/conf/ChrootEveryone
echo "yes" > /etc/pure-ftpd/conf/AnonymousOnly
echo "no" > /etc/pure-ftpd/conf/NoAnonymous
echo "yes" > /etc/pure-ftpd/conf/AnonymousCanCreateDirs
echo "yes" > /etc/pure-ftpd/conf/AllowAnonymousFXP
echo "no" > /etc/pure-ftpd/conf/AnonymousCantUpload
echo "30768 31768" > /etc/pure-ftpd/conf/PassivePortRange              #cat /proc/sys/net/ipv4/ip_local_port_range
echo "/etc/pure-ftpd/welcome.msg" > /etc/pure-ftpd/conf/FortunesFile   #/etc/motd
echo "FTP" > /etc/pure-ftpd/welcome.msg
ln -sf /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
#---  MOTD
echo "------ Kali Pure-ftp Server /var/ftp ----------"  > /etc/pure-ftpd/welcome.msg
echo -e " ${YELLOW}[i]${RESET} Pure-FTPd command: service pure-ftpd start"
echo -e " ${YELLOW}[i]${RESET} Pure-FTPd directory: /var/ftp"
echo -e " ${YELLOW}[i]${RESET} Pure-FTPd username: anonymous"
echo -e " ${YELLOW}[i]${RESET} Pure-FTPd password: <anything>"
#--- Apply settings
systemctl restart pure-ftpd 2>/dev/null
#--- Remove from start up, and stop service 
systemctl disable pure-ftpd 2>/dev/null
systemctl stop pure-ftpd 2>/dev/null


# ##### Install samba
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}samba${RESET} ~ file transfer method"
# #--- Installing samba
# apt -y -qq install samba \
  # || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
# apt -y -qq install cifs-utils \
  # || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Create samba user
groupdel smbgroup 2>/dev/null;
groupadd smbgroup 2>/dev/null
userdel samba 2>/dev/null;
useradd -r -M -d /nonexistent -s /bin/false -c "Samba user" -g smbgroup samba 2>/dev/null
#--- Use the samba user
file=/etc/samba/smb.conf; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/guest account = .*/guest account = samba/' "${file}" 2>/dev/null
grep -q 'guest account' "${file}" 2>/dev/null \
  || sed -i 's#\[global\]#\[global\]\n   guest account = samba#' "${file}"
#--- Setup samba paths
grep -q '^\[shared\]' "${file}" 2>/dev/null \
  || cat <<EOF >> "${file}"

[shared]
  comment = Shared
  path = /var/samba/
  browseable = yes
  guest ok = yes
  #guest only = yes
  read only = no
  writable = yes
  create mask = 0777
  directory mask = 0777
EOF
#--- Create samba path and configure it
mkdir -p /var/samba/ 2>/dev/null
chown -R samba\:smbgroup /var/samba/ 2>/dev/null
chmod -R 0777 /var/samba/ 2>/dev/null
#--- Bug fix
touch /etc/printcap
#--- Check
systemctl restart smbd
smbclient -L \\127.0.0.1 -N
mkdir -p /mnt/smb
mount -t cifs -o guest //127.0.0.1/share /mnt/smb
#--- Disable samba at startup
systemctl stop smbd
systemctl disable smbd
echo -e " ${YELLOW}[i]${RESET} Samba command: service smbd start"
echo -e " ${YELLOW}[i]${RESET} Samba directory: /var/smb/"
echo -e " ${YELLOW}[i]${RESET} Samba username: guest"
echo -e " ${YELLOW}[i]${RESET} Samba password: <blank>"
# #--- Setup alias
# file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
# ([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
# grep -q '^## smb' "${file}" 2>/dev/null \
  # || echo -e '## smb\nalias smb="cd /var/samba/"\n#alias smbroot="cd /var/samba/"\n' >> "${file}"
# #--- Apply new alias
# source "${file}" || source ~/.zshrc


##### Setup SSH
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting up ${GREEN}SSH${RESET} ~ CLI access, may take a few minutes..."
apt -y -qq install openssh-server \
  || echo -e ' '${RED}'[!] Issue with apt install openssh-server'${RESET}
#--- Wipe current keys, but leave the host keys
rm -f /etc/ssh/ssh_host_*
find /root/.ssh/ -type f ! -name authorized_keys -delete 1>/dev/null
find /home/kali/.ssh/ -type f ! -name authorized_keys -delete 1>/dev/null
#--- Generate new keys
ssh-keygen -b 4096 -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" 1>/dev/null
ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" 1>/dev/null
ssh-keygen -b 521 -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -P "" 1>/dev/null
ssh-keygen -t rsa -f /root/.ssh/id_rsa -P "" >/dev/null
ssh-keygen -t rsa -f /home/kali/.ssh/id_rsa -P "" 1>/dev/null
chmod 600 /root/.ssh/id_rsa 1>/dev/null
chmod 600 /home/kali/.ssh/id_rsa  1>/dev/null
chown kali:kali /home/kali/.ssh/id_rsa  1>/dev/null
#--- Change MOTD
echo "-------------  Welcome to Your Kali SSH Host. -------------" > /etc/motd
sed -i 's/PrintMotd no/PrintMotd yes/g' "${file}"    # Show MOTD
#--- Change SSH settings
file=/etc/ssh/sshd_config; [ -e "${file}" ] && cp -n $file{,.bkup}
sed -i 's/^\#PermitRootLogin .*/PermitRootLogin yes/g' "${file}"      # Accept password login (overwrite Debian 8+'s more secure default option...)
sed -i 's/\#AuthorizedKeysFile /AuthorizedKeysFile /g' "${file}"    # Allow for key based logins
#--- Setup alias (handy for 'zsh: correct 'ssh' to '.ssh' [nyae]? n')
#file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
#([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#grep -q '^## ssh' "${file}" 2>/dev/null \
#  || echo -e '## ssh\nalias ssh-start="systemctl restart ssh"\nalias ssh-stop="systemctl stop ssh"\n' >> "${file}"
#--- Apply new alias
#source "${file}" || source ~/.zshrc
service ssh restart || echo -e " ${RED}[i] Problem restarting sshd service."


##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
#--- Clean package manager
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done
apt -y -qq purge $(dpkg -l | tail -n +6 | egrep -v '^(h|i)i' | awk '{print $2}')   # Purged packages
#--- Update slocate database
updatedb
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -cw 2>/dev/null
for i in $(cut -d: -f6 /etc/passwd | sort -u); do
  [ -e "${i}" ] && find "${i}" -type f -name '.*_history' -delete
done


##### Changing kali to owner and lax permissions to all files in /home/kali and subdirectories
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Changing owner to kali and lax permissions for all tools in /home/kali" 1>&2
chown -R kali:kali /home/kali
chmod -R 777 /mnt/hgfs


##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"
echo -e " ${YELLOW}[i]${RESET} Stages skipped: $(( TOTAL-STAGE ))"


#-Done-----------------------------------------------------------------#


##### Done!
echo -e "\n ${YELLOW}[i]${RESET} Don't forget to:"
echo -e " ${YELLOW}[i]${RESET} + Check the above output (Did everything install? Any errors? (${RED}HINT: What's in RED${RESET}?)"
echo -e " ${YELLOW}[i]${RESET} + Manually install: BurpSuite Pro at https://portswigger.net/users"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Change default passwords${RESET}: kali, PostgreSQL/MSF, MySQL, OpenVAS, BeEF XSS, etc..."
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Firefox${RESET}: Sign into your Firefox sync account for all your extensions and bookmarks"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Set a password for root if you want.${RESET}"
echo -e " ${YELLOW}[i]${RESET} + ${YELLOW}Reboot${RESET}"
(dmidecode | grep -iq virtual) \
  && echo -e " ${YELLOW}[i]${RESET} + Take a snapshot   (Virtual machine detected)"

echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0

