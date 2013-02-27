import command

installer_version = "3.0.0"

debug = True

debug_log = "logs/debug.log"
error_log = "logs/error.log"
info_log = "logs/info.log"

home_directory = command.run("echo $HOME").replace("\n", "")+'/'
xbmc_user = home_directory.split("/")[2].replace("\n", "")
temp_directory = home_directory+ "temp/"
environment_file = "/etc/environment"

xbmc_home_dir = home_directory+ ".xbmc/"
xbmc_addons_dir = xbmc_home_dir+ "addons/"
xbmc_userdata_dir = xbmc_home_dir+ "userdata/"
xbmc_keymaps_dir = xbmc_home_dir+ "addons/"
xbmc_backups_dir = 'static/backups/'
xbmc_backups_url_path = 'backups/'

xbmc_initd_file = "/etc/init.d/xbmc"
xbmc_advancedsettings_file = xbmc_userdata_dir+ "advancedsettings.xml"
xbmc_upstart_config_file = "/etc/init/xbmc.conf"
xbmc_upstart_xsession_file = home_directory+ ".xsession"
xbmc_upstart_job_file = "/lib/init/upstart-job"
xbmc_custom_exec = "/usr/bin/runXBMC"

xwrapper_config_file = "/etc/X11/Xwrapper.config"
grub_config_file = "/etc/default/grub"
grub_header_file = "/etc/grub.d/00_header"
system_limits_file = "/etc/security/limits.conf"
modules_file = "/etc/modules"
remote_wakeup_riles_file = "/etc/udev/rules.d/90-enable-remote-wakeup.rules"
automount_rules_file = "/etc/udev/rules.d/media-by-label-auto-mount.rules"
sysctl_conf_file = "/etc/sysctl.conf"
rsyslog_conf_file = "/etc/init/rsyslog.conf"
powermanagement_dir = "/var/lib/polkit-1/localauthority/50-local.d/"
initramfs_splash_file = "/etc/initramfs-tools/conf.d/splash"
initramfs_modules_file = "/etc/initramfs-tools/modules"

github_download_url = "https://github.com/Bram77/xbmc-ubuntu-minimal/raw/master/{{ ubuntu_version }}/download/"

xbmc_ppa = "ppa:team-xbmc/ppa"
xbmc_unstable_ppa = "ppa:team-xbmc/unstable"
wsnipex_xbmc_daily_ppa = "ppa:wsnipex/xbmc-xvba"
wsnipex_xbmc_frodo_ppa = "ppa:wsnipex/xbmc-xvba-frodo"
hts_tvheadend_ppa = "ppa:jabbors/hts-stable"
oscam_ppa = "ppa:oscam/ppa"

installation_database = "xbmc_installation.db"
log_database = "xbmc_installation_log.db"

xbmc_repositories_url = "http://wiki.xbmc.org/index.php?title=Unofficial_add-on_repositories"
