xbmc-ubuntu-minimal
===================

* Install Ubuntu minimal 12.04LTS on your HTPC machine...

i386: http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/mini.iso

x64: http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso

* Make sure you installed your Ubuntu minimal with xbmc user creating after running script is a BAD idea.

* ...and run the following on the machine afterwards to install and configure XBMC (NVIDIA supported, and some Intel video cards probably wont work, ATI is now not supported (see below)

```
cd ~ 
wget https://github.com/uNiversaI/xbmc-ubuntu-minimal/blob/master/12.04/xbmcinstall.sh
bash ./xbmcinstall.sh
```

####Note

* ATI Video cards Not supported anymore atm since XVBA has been abandoned and not developed anymore.
Instead this is used now [Linux Radeon OSS with vdpau how-to](http://forum.xbmc.org/showthread.php?tid=174854 "Linux Radeon OSS with vdpau how-to")

* On INTEL systems it is recommended to upgrade to kernel 3.11rc1 (inclusive firmware update) It probably wont work anymore for some intel stuff anyway.
[Linux vaapi-sse4: Deinterlacing Testing] (http://forum.xbmc.org/showthread.php?tid=165707 "Linux vaapi-sse4: Deinterlacing Testing")

Both of that needs adding to script for options for each ATI and Intel without breaking nvidia.

###Contributions
Your contributions to this script are welcome make PR's to Master and shall be merged.
Loads of cleanup required for unused functions ad make all intel and ATI work without breaking existing.
Anyones help will be greatly apprecciated by anyone using this.

[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
