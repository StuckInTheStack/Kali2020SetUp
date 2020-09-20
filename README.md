<h1> Kali2020SetUp </h1>

<p>This collection of files is part of my setup script to customize a new Kali install (2020.3).  I normally run kali in a virtual machine so I transfer most of my tools from a host share.  This script deletes the Templates, Videos, Public, and Music directories by default.  It also creates directories in /home/kali/ that I use for easy access to my tools, lists, and shells as shown below.</p>
<p></p>
   /wintools      =privilege escalation tools I would always upload to a compromised windows host  
   /linuxtools    =privilege escalation tools I would always upload to a compromised linux host  
<p>   /toolslinuxall =linux tools I use, but don't want to upload every time</p>
<p>   /toolswinall   =windows tools I use, but don't want to upload every time</p>
<p>   /.local/bin    =scripts and binaries I want to incude on PATH</p>
<p>   /shells        =easy access to a collections of shell scripts and binaries</p>
<p>   /lists         =collections of custom lists for enumeration and cracking</p>
<p>   /logs          =log files for saving bash output and input</p>
<p>   /Pictures/Wallpapers =just because</p>
<p></p>
<p>I use the included aliases file to add to /home/kali/.bash_aliases if .bash_aliases isn't already present.  
I download some wallpapers I prefer.  Feel free to use the tools in the repository here, but customize the script and folders to your taste.  
The script will add about 10-12GB to your installation. It checks for enough disk space beforehand so it doesn't crash hard.</p>
<p></p>
<p>Use from root shell with  <strong>./kali2020setup.sh</strong> </p>
<p>  Possile Command line arguments:  </p>
<p>    -burp     = Deletes Burpsuite community (for Pro users) </p>
<p>    -keepdirs = Stops deletion of the Public,Videos,Templates, and Music </p>
<p>    -dns      = Use OpenDNS and locks permissions </p>
<p>    -osx      = Changes to Apple keyboard layout </p>
<p>    -keyboard <value> = Change the keyboard layout language  ( default is US ) </p>
<p>    -timezone <value> = Change the timezone location ( default is set by geolocation ) </p>
<p></p>
<p></p>
<p>This script is built on scripts from   https://github.com/g0tmi1k/os-scripts  https://github.com/blacklanternsecurity</p>
<p></p>
<p>-Cheers,</p>
<p>StuckInTheStack</p>
<p>@StuckInTheStack</p>
<p>secret.cybersaladbar.com</p>
