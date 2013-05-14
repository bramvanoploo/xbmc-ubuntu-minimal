xbmc-ubuntu-minimal
===================

* Install Ubuntu minimal 12.04LTS on your HTPC machine...

i386: http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/mini.iso

x64: http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso

* Make sure you installed your Ubuntu with xbmc user or create xbmc user after installation 
  and add user to sudo group

* On INTEL systems it is recommended to upgrade to kernel 3.9 (inclusive firmware update)

* ...and run the following on the machine afterwards to install and configure XBMC (NVIDIA, ATI and Intel video cards supported):

```
cd ~ 
wget https://github.com/uNiversaI/xbmc-ubuntu-minimal/blob/master/12.04/prepinstall_2_6_2.sh
bash ./prepinstall_2_6_2.sh
```
[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
