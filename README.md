xbmc-ubuntu-minimal
===================

* Install Ubuntu minimal 12.10 on your HTPC machine...

x64: http://archive.ubuntu.com/ubuntu/dists/quantal/main/installer-amd64/current/images/netboot/mini.iso

i386: http://archive.ubuntu.com/ubuntu/dists/quantal/main/installer-i386/current/images/netboot/mini.iso

* ...and run the following on the machine afterwards to install and configure XBMC (NVIDIA, ATI and Intel video cards supported):

* ...This is my personal repo for the Bramm77 xbmc-ubuntu-minimal install scripts. I have added additional scripts, appended with "_frodo" for the install of Frodo Stable from the wsnipex PPA. Scripts 2.6 and 2.6.1 have been adjusted for this purpose.


For 2.6
```
cd ~ 
wget https://github.com/markfknight/xbmc-ubuntu-minimal/raw/master/12.10/prepare_install_2_6_frodo.sh
bash ./prepare_install_2_6_frodo.sh
```

For 2.6.1
```
cd ~ 
wget https://github.com/markfknight/xbmc-ubuntu-minimal/raw/master/12.10/prepare_install_2_6_1_frodo.sh
bash ./prepare_install_2_6_1_frodo.sh
```

[![lgplv3](https://f.cloud.github.com/assets/3521959/153710/2745bbea-7601-11e2-8b61-c8ff3ef97d32.png)](http://www.gnu.org/licenses/lgpl.txt)
