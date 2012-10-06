#!/bin/sh
#
# @author   Bram van Oploo
# @date     2012-10-06
# @version  1.0
#
# 0 */2 * * * /etc/cron.d/dist-upgrade.sh >> /var/log/updates.log; # 2 hour interval
# 0 */4 * * * /etc/cron.d/dist-upgrade.sh >> /var/log/updates.log; # 4 hour interval
#

echo "\nUpdate on: $(date)\n"
echo '- Update packages list...\n'
sudo apt-get -y update > /dev/null 2>&1
echo '\n- Upgrade to latest package versions...\n'
sudo apt-get -y dist-upgrade
echo '\n- Cleanup...\n'
sudo apt-get -y autoremove
sudo apt-get -y autoclean
sudo apt-get -y clean
