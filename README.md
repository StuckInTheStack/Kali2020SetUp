<h1> Kali2020SetUp </h1>

<p>This collection of files is part of my setup script to customize a new Kali install (2020.3).  I normally run kali in a virtual machine so I transfer most of my tools from a host share.  This script deletes the Templates, Videos, Public, and Music directories by default.  It also creates directories in /home/kali/ that I use for easy access to my tools, lists, and shells as shown below.</p>
<p></p>
   /wintools      =privilege escalation tools I would always upload to a compromised windows host  <br>
   /linuxtools    =privilege escalation tools I would always upload to a compromised linux host  <br>
   /toolslinuxall =linux tools I use, but don't want to upload every time  <br>
   /toolswinall   =windows tools I use, but don't want to upload every time  <br>
   /.local/bin    =scripts and binaries I want to incude on PATH  <br>
   /shells        =easy access to a collections of shell scripts and binaries  <br>
   /lists         =collections of custom lists for enumeration and cracking  <br>
   /logs          =log files for saving bash output and input  <br>
   /Pictures/Wallpapers =just because  <br>
<p></p>
<p>I use the included aliases file to add to /home/kali/.bash_aliases if .bash_aliases isn't already present.  
I download some wallpapers I prefer.  Feel free to use the tools in the repository here, but customize the script and folders to your taste.  
The script will add about 10-12GB to your installation. It checks for enough disk space beforehand so it doesn't crash hard.</p>
<p></p>
<p>Use from root shell with  <strong>./kali2020setup.sh</strong>  ( at the start, you will need to enter a password or blank to access your host share ) <br>
  Possile Command line arguments:  <br>
    -burp     = Deletes Burpsuite community (for Pro users)  <br>
    -keepdirs = Stops deletion of the Public,Videos,Templates, and Music  <br>
    -dns      = Use OpenDNS and locks permissions  <br>
    -osx      = Changes to Apple keyboard layout  <br>
    -keyboard <value> = Change the keyboard layout language  ( default is US )  <br>
    -timezone <value> = Change the timezone location ( default is set by geolocation )  <br>
<p></p>
<p></p>
<p>This script is built on scripts from   https://github.com/g0tmi1k/os-scripts  https://github.com/blacklanternsecurity</p>
<p></p>
Cheers,  <br>
StuckInTheStack  <br>
@StuckInTheStack  <br>
secret.cybersaladbar.com
