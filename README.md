<h1> Kali2020SetUp </h1>

<p>This collection of files is part of my setup script to customize a new Kali install (2020.3). It updates kali and the kernel, and it installs many privesctools for windows and linux, useful aliases, seclists, global logging, Autorecon, Impacket, MinGW(64/32), 32bit linux libraries, wine, MinGW(windows), pywin32.exe, Libre Office, responder, CrackMapExec, shellter, dbeaver, crowbar, pytftpdlib, pure-ftpd, samba config, ssh keys config, among other tools.  After you're done, you will still need to sign into Firefox to transfer over your extensions and bookmarks, and update default passwords.</p>
<p></p>
<p>I normally run kali in a virtual machine so I transfer many of my non-updating tools from a host share.  </p>
<p></p>
<p>This script deletes the Templates, Videos, Public, and Music directories by default.  It also creates directories in /home/kali/ that I use for easy access to my tools, lists, and shells as shown below.</p>
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
<p>The sctipt uses the included aliases file to add to /home/kali/.bash_aliases if .bash_aliases isn't already present. 
I download some wallpapers I prefer.  Feel free to use the tools in the repository here, but customize the script and folders to your taste.  
The script will add about 25GB to your installation ( 10Gb with the -noteverything argument). It checks for enough disk space beforehand so it doesn't crash hard.</p>
<p></p>
<p>Use from root shell with  <strong>./kali2020setup.sh -noteverything -keepdirs</strong>  ( at the start, you will need to enter a password or -enter- to access your host share )<br>
  Possile Command line arguments:  <br>
    <strong>-noteverything</strong> = Prevents default action of loading every Kali package ( Script will only use about 10Gb instead of 25Gb )<br>
    <strong>-keepdirs</strong> = Stops deletion of the Public,Videos,Templates, and Music  <br>
    <strong>-burp</strong>     = Deletes Burpsuite community (for Pro users)  <br>
    <strong>-dns</strong>      = Use OpenDNS and locks permissions  <br>
    <strong>-osx</strong>      = Changes to Apple keyboard layout  <br>
    <strong>-keyboard \<value\></strong> = Change the keyboard layout language  ( default is US )  <br>
    <strong>-timezone \<value\></strong> = Change the timezone location ( default is set by geolocation )  <br>
<p></p>
<p></p>
<p>This script is built on scripts from   https://github.com/g0tmi1k/os-scripts  https://github.com/blacklanternsecurity</p>
<p></p>
Cheers,  <br>
StuckInTheStack  <br>
@StuckInTheStack  <br>
secret.cybersaladbar.com
