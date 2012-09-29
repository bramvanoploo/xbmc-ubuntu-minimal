xbmc-ubuntu-minimal
===================

* Install Ubuntu minimal 12.10 on your HTPC machine...

x64: http://archive.ubuntu.com/ubuntu/dists/quantal/main/installer-amd64/current/images/netboot/mini.iso

i386: http://archive.ubuntu.com/ubuntu/dists/quantal/main/installer-i386/current/images/netboot/mini.iso

* ...and run the follwing on the machine afterwards to install and configure XBMC:


cd ~/ && wget https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/12.04/prepare_install.sh
 
 
* ...for NVIDIA video cards...
 
bash prepare_install.sh nvidia
 
 
* ...for ATI video cards...
 
bash prepare_install.sh ati
 
 
* ...for Intel video cards...
 
bash prepare_install.sh intel
