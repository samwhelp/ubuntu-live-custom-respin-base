#!/usr/bin/env bash


################################################################################
## Time / Start
################################################################################

TIME_START="$(date '+%Y-%m-%d %H:%M:%S')"
TIME_END=""




################################################################################
## Args / Action
################################################################################

## default value
DEFAULT_RUN_ACTION="build"

## read from environment variable (sudo RUN_ACTION=prepare do-build.sh) or (sudo env RUN_ACTION=prepare do-build.sh)
RUN_ACTION="${RUN_ACTION:=$DEFAULT_RUN_ACTION}"

## read from argument (do-build.sh prepare)
ARG_RUN_ACTION="${1}"

## determine the value of RUN_ACTION
RUN_ACTION="${ARG_RUN_ACTION:=$RUN_ACTION}"

## ensure RUN_ACTION has a value.
RUN_ACTION="${RUN_ACTION:=$DEFAULT_RUN_ACTION}"




################################################################################
## Environment
################################################################################

set -e						# exit on error
set -o pipefail				# exit on pipeline error
set -u						# treat unset variable as error


################################################################################
## Base Path
################################################################################

BASE_DIR_PATH="$(dirname "$(realpath "${0}")")"


################################################################################
## Init
################################################################################




################################################################################
## Build Environment
################################################################################

export DEBIAN_FRONTEND=noninteractive




################################################################################
## Option
################################################################################

TARGET_UBUNTU_CODENAME="resolute"
TARGET_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu"
TARGET_ARCH="amd64"
TARGET_NAME="ubuntu"
TARGET_BUSINESS_NAME="Ubuntu"
TARGET_HOSTNAME="ubuntu"
TARGET_BUILD_VERSION="26.04"
TARGET_INIT_LOCALES="C.UTF-8 en_US.UTF-8"
TARGET_DEFAULT_LOCALE="en_US.UTF-8"


#DEBOOTSTRAP_SCRIPTS_DIR_PATH="/usr/share/debootstrap/scripts"
#DEBOOTSTRAP_SCRIPT_FILE_NAME="noble"
#DEBOOTSTRAP_SCRIPT_FILE_NAME="resolute"
#DEBOOTSTRAP_SCRIPT_FILE_PATH="${DEBOOTSTRAP_SCRIPTS_DIR_PATH}/${DEBOOTSTRAP_SCRIPT_FILE_NAME}"
DEBOOTSTRAP_SCRIPT_FILE_PATH=""




################################################################################
# Path / Base
################################################################################

##
## * gear / Makefile
## * gear / build.sh
## * gear / to-build.sh
## * gear / do-build.sh
##

GEAR_DIR_PATH="${BASE_DIR_PATH}"


################################################################################
## Path / Model / Base
################################################################################

##
## * plan / template
##

PLAN_DIR_PATH="${BASE_DIR_PATH}"
TEMPLATE_DIR_PATH="${PLAN_DIR_PATH}/template"


################################################################################
## Path / Model / Tmp
################################################################################

##
## * plan / tmp
##

TMP_DIR_PATH="${PLAN_DIR_PATH}/tmp"


################################################################################
## Path / Model / Log
################################################################################

##
## * plan / tmp / log / log.txt
##

LOG_DIR_NAME="log"
LOG_DIR_PATH="${TMP_DIR_PATH}/${LOG_DIR_NAME}"

LOG_FILE_NAME="log.txt"
LOG_FILE_PATH="${LOG_DIR_PATH}/${LOG_FILE_NAME}"


################################################################################
## Path / Model / Log / Runner Id
################################################################################

##
## * plan / tmp / log / runner-uid.txt
##

RUNNER_UID_FILE_NAME="runner-uid.txt"
RUNNER_UID_FILE_PATH="${LOG_DIR_PATH}/${RUNNER_UID_FILE_NAME}"

##
## * plan / tmp / log / runner-gid.txt
##

RUNNER_GID_FILE_NAME="runner-gid.txt"
RUNNER_GID_FILE_PATH="${LOG_DIR_PATH}/${RUNNER_GID_FILE_NAME}"


################################################################################
## Path / Model / Log / Time
################################################################################

##
## * plan / tmp / log / time-start.txt
##

TIME_START_FILE_NAME="time-start.txt"
TIME_START_FILE_PATH="${LOG_DIR_PATH}/${TIME_START_FILE_NAME}"

##
## * plan / tmp / log / time-end.txt
##

TIME_END_FILE_NAME="time-end.txt"
TIME_END_FILE_PATH="${LOG_DIR_PATH}/${TIME_END_FILE_NAME}"


################################################################################
## Path / Model / Skeleton
################################################################################

##
## * plan / tmp / dist
## * plan / tmp / work
## * plan / tmp / work / img
## * plan / tmp / work / iso
##

DIST_DIR_PATH="${TMP_DIR_PATH}/dist"
WORK_DIR_PATH="${TMP_DIR_PATH}/work"

DISTRO_IMG_DIR_PATH="${WORK_DIR_PATH}/img"
DISTRO_ISO_DIR_PATH="${WORK_DIR_PATH}/iso"


################################################################################
## Path / Model / ISO
################################################################################

##
## * plan / tmp / work / distro.iso
## * plan / tmp / dist / ubuntu-26.04-amd64-20260805-201314.iso
##

TIME_STRING_FOR_ISO_NAME="$(date '+%Y%m%d-%H%M%S')"

## upper case
ISO_VOLID="UBUNTU"

ISO_OUT_FILE_MAIN_NAME="distro"
ISO_OUT_FILE_EXT_NAME="iso"
ISO_OUT_FILE_NAME="${ISO_OUT_FILE_MAIN_NAME}.${ISO_OUT_FILE_EXT_NAME}"
ISO_OUT_FILE_PATH="${WORK_DIR_PATH}/${ISO_OUT_FILE_NAME}"

ISO_DIST_FILE_MAIN_NAME="${TARGET_NAME}-${TARGET_BUILD_VERSION}-${TARGET_ARCH}-${TIME_STRING_FOR_ISO_NAME}"
ISO_DIST_FILE_EXT_NAME="iso"
ISO_DIST_FILE_NAME="${ISO_DIST_FILE_MAIN_NAME}.${ISO_DIST_FILE_EXT_NAME}"
ISO_DIST_FILE_PATH="${DIST_DIR_PATH}/${ISO_DIST_FILE_NAME}"


################################################################################
# Path / Model / Hook
################################################################################

##
## * paln / template / hook
##

HOOK_DIR_PATH="${TEMPLATE_DIR_PATH}/hook"


################################################################################
# Path / Model / Master
################################################################################

##
## * paln / template / asset
## * plan / template / asset / overlay
## * plan / template / asset / package
## * plan / template / asset / package / install
##

MASTER_ASSET_DIR_PATH="${TEMPLATE_DIR_PATH}/asset"
MASTER_OVERLAY_DIR_PATH="${MASTER_ASSET_DIR_PATH}/overlay"
MASTER_PACKAGE_DIR_PATH="${MASTER_ASSET_DIR_PATH}/package"
MASTER_PACKAGE_INSTALL_DIR_PATH="${MASTER_PACKAGE_DIR_PATH}/install"


################################################################################
# Path / Model / Installer
################################################################################

##
## * paln / template / installer
## * plan / template / installer / overlay
## * plan / template / installer / package
## * plan / template / installer / package / install
##

INSTALLER_ASSET_DIR_PATH="${TEMPLATE_DIR_PATH}/installer"
INSTALLER_OVERLAY_DIR_PATH="${INSTALLER_ASSET_DIR_PATH}/overlay"
INSTALLER_PACKAGE_DIR_PATH="${INSTALLER_ASSET_DIR_PATH}/package"
INSTALLER_PACKAGE_INSTALL_DIR_PATH="${INSTALLER_PACKAGE_DIR_PATH}/install"



################################################################################
## Util
################################################################################


################################################################################
## Util / Command
################################################################################

is_function_exist () {

	if type -p "${1}" > /dev/null; then
		return 0
	else
		return 1
	fi

}

# is_command_exist () {
# 	if command -v "${1}" > /dev/null; then
# 		return 0
# 	else
# 		return 1
# 	fi
# }

is_command_exist () {

	if [ -x "$(command -v ${1})" ]; then
		return 0
	else
		return 1
	fi

}




################################################################################
## Module
################################################################################


################################################################################
## Module / Permission
################################################################################

function core_check_permission () {

	if [ $(id -u) -ne 0 ]; then

		echo "################################################################################"
		echo "## [Warning] this script should be run as 'root'"
		echo "################################################################################"

		exit 1
	fi

}


################################################################################
## Module / Signal
################################################################################

function mod_cleanup_before_exit () {

	echo "################################################################################"
	echo "## [Event] signal caught or process ended"
	echo "################################################################################"

	##set +e
	mod_unmount_before_exit

	echo "################################################################################"
	echo "## [Result] cleanup sequence finished"
	echo "################################################################################"

}

function mod_bind_signal () {

	echo "################################################################################"
	echo "## [Init] bind signal"
	echo "################################################################################"

	echo "trap mod_cleanup_before_exit EXIT INT TERM"
	trap mod_cleanup_before_exit EXIT INT TERM

}


################################################################################
## Module / Time
################################################################################

function core_save_time_start () {

	echo "################################################################################"
	echo "## [Time] core_save_time_start"
	echo "################################################################################"

	local time_start="${TIME_START}"

	local time_start_file_path="${TIME_START_FILE_PATH}"

	echo "==== save time-start on file: ${time_start_file_path} ===="
	echo "${time_start}" | tee ${time_start_file_path}

}

function core_save_time_end () {

	echo "################################################################################"
	echo "## [Time] core_save_time_end"
	echo "################################################################################"

	TIME_END="$(date '+%Y-%m-%d %H:%M:%S')"

	local time_end="${TIME_END}"

	local time_end_file_path="${TIME_END_FILE_PATH}"

	echo "==== save time-end on file: ${time_end_file_path} ===="
	echo "${time_end}" | tee ${time_end_file_path}

}


################################################################################
## Module / Mount
################################################################################

##
## https://github.com/mvallim/live-custom-ubuntu-from-scratch/blob/master/scripts/build.sh#L46
##

function raw_mount () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	mount --bind /dev "${distro_img_dir_path}/dev"
	mount --bind /run "${distro_img_dir_path}/run"
	chroot "${distro_img_dir_path}" mount none -t proc /proc
	chroot "${distro_img_dir_path}" mount none -t sysfs /sys
	chroot "${distro_img_dir_path}" mount none -t devpts /dev/pts

}

function raw_unmount () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	chroot "${distro_img_dir_path}" umount -l /proc || true
	chroot "${distro_img_dir_path}" umount -l /sys || true
	chroot "${distro_img_dir_path}" umount -l /dev/pts || true
	umount -l "${distro_img_dir_path}/dev" || true
	umount -l "${distro_img_dir_path}/run" || true

}

function try_unmount_prototype () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	umount "${distro_img_dir_path}/proc" || umount -lf "${distro_img_dir_path}/proc" || true
	umount "${distro_img_dir_path}/sys" || umount -lf "${distro_img_dir_path}/sys" || true
	umount "${distro_img_dir_path}/dev/pts" || umount -lf "${distro_img_dir_path}/dev/pts" || true
	umount "${distro_img_dir_path}/dev" || umount -lf "${distro_img_dir_path}/dev" || true
	umount "${distro_img_dir_path}/run" || umount -lf "${distro_img_dir_path}/run" || true

	umount "${distro_iso_dir_path}/boot/efi" || umount -lf "${distro_iso_dir_path}/boot/efi" || true

}

function try_unmount () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	local node=""
	local path=""

	for node in proc sys dev/pts dev run; do

		path="${distro_img_dir_path}/${node}"

		try_unmount_node "${path}"

	done


	for node in boot/efi; do

		path="${distro_iso_dir_path}/${node}"

		try_unmount_node "${path}"

	done

}

function let_unmount () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	local node=""
	local path=""

	for node in proc sys dev/pts dev run; do

		path="${distro_img_dir_path}/${node}"

		let_unmount_node "${path}"

	done


	for node in boot/efi; do

		path="${distro_iso_dir_path}/${node}"

		let_unmount_node "${path}"

	done

}

function try_unmount_node () {

	local node="${1}"

	umount "${node}" || umount -lf "${node}" || true

}

function let_unmount_node () {

	local node="${1}"

	if mountpoint -q "${node}"; then
		umount "${node}" || umount -lf "${node}" || true
	fi

}

function sys_mount () {

	raw_mount

}

function sys_unmount () {

	try_unmount
	raw_unmount

}

function mod_mount () {

	sys_unmount
	sys_mount

}

function mod_unmount () {

	sys_unmount

}

function mod_unmount_before_exit () {

	echo "################################################################################"
	echo "## [Controller] mod_unmount_before_exit"
	echo "################################################################################"

	echo "==== unmount before exit ===="

	mod_unmount

}

function mod_mount_before_chroot () {

	echo "################################################################################"
	echo "## [Controller] mod_mount_before_chroot"
	echo "################################################################################"

	echo "==== mount before chroot ===="

	mod_mount

}

function mod_unmount_after_chroot () {

	echo "################################################################################"
	echo "## [Controller] mod_unmount_after_chroot"
	echo "################################################################################"

	echo "==== unmount after chroot ===="

	mod_unmount

}

function mod_unmount_before_archive () {

	echo "################################################################################"
	echo "## [Controller] mod_unmount_before_archive"
	echo "################################################################################"

	echo "==== unmount before archive ===="

	mod_unmount

}

function mod_unmount_before_clean () {

	echo "################################################################################"
	echo "## [Controller] mod_unmount_before_clean"
	echo "################################################################################"

	echo "==== unmount before clean ===="

	mod_unmount

}

################################################################################
## Module / Initialize
################################################################################

function sys_master_initialize () {

	local tmp_dir_path="${TMP_DIR_PATH}"
	local log_dir_path="${LOG_DIR_PATH}"

	local work_dir_path="${WORK_DIR_PATH}"
	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	mod_unmount

	mkdir -p "${tmp_dir_path}"
	mkdir -p "${log_dir_path}"

	rm -rf "${work_dir_path}"
	mkdir -p "${work_dir_path}"
	mkdir -p "${distro_img_dir_path}"

}

function mod_master_initialize () {

	echo "################################################################################"
	echo "## [Controller] mod_master_initialize"
	echo "################################################################################"

	echo "==== master process initialize ===="

	sys_master_initialize

}


################################################################################
## Module / Fulfill Scripts
################################################################################

function sys_run_fulfill_scripts_embedded_for_full_system () {

	echo "################################################################################"
	echo "## [Controller] sys_run_fulfill_scripts_embedded_for_full_system"
	echo "################################################################################"

	echo "==== run fulfill scripts embedded ===="

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

cat << __FULFILL_SCRIPT__ | chroot "${distro_img_dir_path}" /bin/bash


##
## ## Environment
##

set -e						# exit on error
set -o pipefail				# exit on pipeline error
set -u						# treat unset variable as error


##
## ## Build Environment
##

export DEBIAN_FRONTEND=noninteractive


##
## ## Option
##

TARGET_UBUNTU_CODENAME="${TARGET_UBUNTU_CODENAME}"
TARGET_UBUNTU_MIRROR="${TARGET_UBUNTU_MIRROR}"
TARGET_ARCH="${TARGET_ARCH}"
TARGET_NAME="${TARGET_NAME}"
TARGET_BUSINESS_NAME="${TARGET_BUSINESS_NAME}"
TARGET_HOSTNAME="${TARGET_HOSTNAME}"
TARGET_BUILD_VERSION="${TARGET_BUILD_VERSION}"
TARGET_INIT_LOCALES="${TARGET_INIT_LOCALES}"
TARGET_DEFAULT_LOCALE="${TARGET_DEFAULT_LOCALE}"




##
## ## Path
##

HOOK_PORTAL_MAIN_FILE_PATH="/opt/build/template/hook/main.sh"

MASTER_OVERLAY_DIR_PATH="/opt/build/template/asset/overlay"
MASTER_PACKAGE_INSTALL_DIR_PATH="/opt/build/template/asset/package/install"

INSTALLER_OVERLAY_DIR_PATH="/opt/build/template/installer/overlay"
INSTALLER_PACKAGE_INSTALL_DIR_PATH="/opt/build/template/installer/package/install"


##
## ## Core
##

function core_var_dump () {


	##
	## ## Target
	##

	echo "TARGET_UBUNTU_CODENAME=\${TARGET_UBUNTU_CODENAME}"
	echo "TARGET_UBUNTU_MIRROR=\${TARGET_UBUNTU_MIRROR}"
	echo "TARGET_ARCH=\${TARGET_ARCH}"
	echo "TARGET_NAME=\${TARGET_NAME}"
	echo "TARGET_BUSINESS_NAME=\${TARGET_BUSINESS_NAME}"
	echo "TARGET_HOSTNAME=\${TARGET_HOSTNAME}"
	echo "TARGET_BUILD_VERSION=\${TARGET_BUILD_VERSION}"
	echo "TARGET_INIT_LOCALES=\${TARGET_INIT_LOCALES}"
	echo "TARGET_DEFAULT_LOCALE=\${TARGET_DEFAULT_LOCALE}"


	##
	## ## Path
	##

	echo "HOOK_PORTAL_MAIN_FILE_PATH=\${HOOK_PORTAL_MAIN_FILE_PATH}"

	echo "MASTER_OVERLAY_DIR_PATH=\${MASTER_OVERLAY_DIR_PATH}"
	echo "MASTER_PACKAGE_INSTALL_DIR_PATH=\${MASTER_PACKAGE_INSTALL_DIR_PATH}"

	echo "INSTALLER_OVERLAY_DIR_PATH=\${INSTALLER_OVERLAY_DIR_PATH}"
	echo "INSTALLER_PACKAGE_INSTALL_DIR_PATH=\${INSTALLER_PACKAGE_INSTALL_DIR_PATH}"


}

function core_var_export () {


	##
	## ## Target
	##

	export TARGET_UBUNTU_CODENAME
	export TARGET_UBUNTU_MIRROR
	export TARGET_ARCH
	export TARGET_NAME
	export TARGET_BUSINESS_NAME
	export TARGET_HOSTNAME
	export TARGET_BUILD_VERSION
	export TARGET_INIT_LOCALES
	export TARGET_DEFAULT_LOCALE


	##
	## ## Path
	##

	export HOOK_PORTAL_MAIN_FILE_PATH

	export MASTER_OVERLAY_DIR_PATH
	export MASTER_PACKAGE_INSTALL_DIR_PATH

	export INSTALLER_OVERLAY_DIR_PATH
	export INSTALLER_PACKAGE_INSTALL_DIR_PATH


}


##
## ## Util
##

function util_load_list () {

	local file_path="\${1}"

	local trim_line=""

	cat \${file_path} | while IFS='' read -r line; do

		trim_line=\$(echo \${line}) # trim

		## https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
		## ignore leading #
		if [ "\${trim_line:0:1}" == '#' ]; then
			continue;
		fi

		## ignore empty line
		if [[ -z "\${trim_line}" ]]; then
			continue;
		fi

		echo "\${line}"

	done

}


##
## ## Module
##


##
## ## Module / Locale
##

function base_locale_init_locales () {

	echo "################################################################################"
	echo "## [Worker] base_locale_init_locales"
	echo "################################################################################"

	echo "==== init locales ===="

	local target_init_locales="\${TARGET_INIT_LOCALES}"

	echo locale-gen --lang \${target_init_locales}
	locale-gen --lang \${target_init_locales}

}

function base_locale_default_locale () {

	echo "################################################################################"
	echo "## [Worker] base_locale_default_locale"
	echo "################################################################################"

	local target_default_locale="\${TARGET_DEFAULT_LOCALE}"

	echo "==== set default locale to "\${target_default_locale}" ===="

	echo "LANG=\${target_default_locale}" > /etc/locale.conf

}


##
## ## Module / Host Name
##

function core_hostname_config () {

	echo "################################################################################"
	echo "## [Worker] core_hostname_config"
	echo "################################################################################"

	local target_hostname="\${TARGET_HOSTNAME}"

	echo "==== set hostname to "\${target_hostname}" ===="

	echo "\${target_hostname}" > "/etc/hostname"

}


##
## ## Module / Machine Id
##

function core_machine_id_config () {

	echo "################################################################################"
	echo "## [Worker] core_machine_id_config"
	echo "################################################################################"

	echo "==== crecate machine-id ===="

	dbus-uuidgen > /etc/machine-id
	ln -fs /etc/machine-id /var/lib/dbus/machine-id

}

function core_machine_id_clear () {

	echo "################################################################################"
	echo "## [Worker] core_machine_id_clear"
	echo "################################################################################"

	echo "==== clear machine-id ===="

	truncate -s 0 /etc/machine-id || true
	truncate -s 0 /var/lib/dbus/machine-id || true

}


##
## ## Module / Apt Sources
##

function core_apt_sources_config () {

	echo "################################################################################"
	echo "## [Worker] core_apt_sources_config"
	echo "################################################################################"

	echo "==== config apt soruces list using DEB822 format ===="

	local target_ubuntu_codename="\${TARGET_UBUNTU_CODENAME}"
	local target_ubuntu_mirror="\${TARGET_UBUNTU_MIRROR}"


	if [ -f /etc/apt/sources.list ]; then
		mkdir -p /etc/apt/backup
		mv /etc/apt/sources.list /etc/apt/backup/sources.list
	fi


	mkdir -p /etc/apt/sources.list.d

cat << __EOF__ > /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: \${target_ubuntu_mirror}
Suites: \${target_ubuntu_codename}
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: \${target_ubuntu_mirror}
Suites: \${target_ubuntu_codename}-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: \${target_ubuntu_mirror}
Suites: \${target_ubuntu_codename}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: \${target_ubuntu_mirror}
Suites: \${target_ubuntu_codename}-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
__EOF__

}

function core_apt_update () {

	echo "################################################################################"
	echo "## [Worker] core_apt_update"
	echo "################################################################################"

	echo "==== apt-get update ===="

	echo 'apt-get update'
	apt-get update

}

function core_apt_upgrade () {

	echo "################################################################################"
	echo "## [Worker] core_apt_upgrade"
	echo "################################################################################"

	echo "==== apt upgrade ===="

	echo 'apt-get update'
	apt-get update

	echo 'apt-get dist-upgrade -y'
	apt-get dist-upgrade -y

}

function core_no_snap_config () {

	echo "################################################################################"
	echo "## [Worker] core_no_snap_config"
	echo "################################################################################"

	echo "==== config apt soruces preferences: /etc/apt/preferences.d/no-snap.pref ===="

cat << __EOF__ | tee /etc/apt/preferences.d/no-snap.pref > /dev/null 2>&1
Package: snapd
Pin: release a=*
Pin-Priority: -10
__EOF__


}


##
## ## Module / Systemd
##

function core_systemd_package_install () {

	echo "################################################################################"
	echo "## [Worker] core_systemd_package_install"
	echo "################################################################################"

	echo "==== install systemd as init ===="

	local run_cmd="apt-get install -y --install-recommends
		systemd-sysv
	"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Kernel
##

function kernel_main_package_install () {

	echo "################################################################################"
	echo "## [Worker] kernel_main_package_install"
	echo "################################################################################"

	echo "==== install kernel package ===="

	local run_cmd="apt-get install -y --no-install-recommends
		linux-generic
		linux-firmware
		thermald
		zstd
	"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Kernel / Initramfs
##

function kernel_initramfs_package_install () {

	echo "################################################################################"
	echo "## [Worker] kernel_initramfs_package_install"
	echo "################################################################################"

	echo "==== install initramfs-tools package ===="

	local run_cmd="apt-get install -y --no-install-recommends
		initramfs-tools
		zstd
	"

	echo \${run_cmd}
	\${run_cmd}

}

function kernel_initramfs_create () {

	echo "################################################################################"
	echo "## [Worker] kernel_initramfs_create"
	echo "################################################################################"

	echo "==== initramfs create ===="

	local run_cmd="update-initramfs -c -k all"

	echo \${run_cmd}
	\${run_cmd}

}

function kernel_initramfs_update () {

	echo "################################################################################"
	echo "## [Worker] kernel_initramfs_update"
	echo "################################################################################"

	echo "==== initramfs update ===="

	local run_cmd="update-initramfs -u -k all"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Boot Loader
##

function core_bootloader_package_install () {

	echo "################################################################################"
	echo "## [Worker] core_bootloader_package_install"
	echo "################################################################################"

	echo "==== install grub as bootloader ===="

	local run_cmd="apt-get install -y --install-recommends
		os-prober
		grub-common
		grub-gfxpayload-lists
		grub-pc
		grub-pc-bin
		grub2-common
		grub-efi-amd64-signed
		shim-signed
		efibootmgr
	"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Casper
##

function live_casper_package_install () {

	echo "################################################################################"
	echo "## [Worker] live_casper_package_install"
	echo "################################################################################"

	echo "==== install casper as live boot system ===="

	local run_cmd="apt-get install -y --no-install-recommends
		casper
		discover
		laptop-detect
		os-prober
		keyutils
	"

	echo \${run_cmd}
	\${run_cmd}

}

function live_casper_config_install () {

	echo "################################################################################"
	echo "## [Worker] live_casper_config_install"
	echo "################################################################################"

	echo "==== config /etc/casper.conf ===="

	local target_name="\${TARGET_NAME}"
	local target_business_name="\${TARGET_BUSINESS_NAME}"
	local target_hostname="\${TARGET_HOSTNAME}"


	##
	## https://git.launchpad.net/ubuntu/+source/casper/tree/casper.conf
	##

cat << __EOF__ | tee /etc/casper.conf > /dev/null 2>&1
# This file should go in /etc/casper.conf
# Supported variables are:
# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM, FLAVOUR

export USERNAME="live"
export USERFULLNAME="\${target_business_name} Live session user"
export HOST="\${target_hostname}"
export BUILD_SYSTEM="Ubuntu"

# USERNAME and HOSTNAME as specified above won't be honoured and will be set to
# flavour string acquired at boot time, unless you set FLAVOUR to any
# non-empty string.

export FLAVOUR="\${target_business_name}"
__EOF__

}


##
## ## Module / Network
##

function base_network_package_install () {

	echo "################################################################################"
	echo "## [Worker] base_network_package_install"
	echo "################################################################################"

	echo "==== install base network package ===="

	local run_cmd="apt-get install -y --install-recommends
		network-manager
		net-tools
		resolvconf
		iputils-ping
		iproute2
		iw
	"

	echo \${run_cmd}
	\${run_cmd}

}

function base_network_config_install () {

	echo "################################################################################"
	echo "## [Worker] base_network_config_install"
	echo "################################################################################"

	echo "==== config networking ===="

	sys_network_config_network_manager
	sys_network_config_netplan

}

function sys_network_config_network_manager () {

	echo "==== config /etc/NetworkManager/NetworkManager.conf ===="

	mkdir -p "/etc/NetworkManager"

cat << __EOF__ > "/etc/NetworkManager/NetworkManager.conf"
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
__EOF__

}

function sys_network_config_netplan () {

	echo "==== config /etc/netplan/01-network-manager-all.yaml ===="

	mkdir -p "/etc/netplan"

cat << __EOF__ > "/etc/netplan/01-network-manager-all.yaml"
network:
  version: 2
  renderer: NetworkManager
__EOF__

}


##
## ## Module / Gsettings and Dconf
##

function base_dconf_package_install () {

	echo "################################################################################"
	echo "## [Worker] base_dconf_package_install"
	echo "################################################################################"

	echo "==== install dconf-cli package ===="

	local run_cmd="apt-get install -y --install-recommends
		dconf-cli
	"

	echo \${run_cmd}
	\${run_cmd}

}

function base_dconf_db_update () {

	echo "################################################################################"
	echo "## [Worker] base_dconf_db_update"
	echo "################################################################################"

	echo "==== dconf update db ===="

	local run_cmd="dconf update"

	echo \${run_cmd}
	\${run_cmd}

}

function base_gsettings_schema_compile () {

	echo "################################################################################"
	echo "## [Worker] base_gsettings_schema_compile"
	echo "################################################################################"

	echo "==== gsettings compile schemas ===="

	local run_cmd="glib-compile-schemas /usr/share/glib-2.0/schemas"

	echo \${run_cmd}
	\${run_cmd}

}




##
## ## Module / Extend
##


##
## ## Module / Extend / Master / Install Packages
##

function sys_master_find_package_install_list_via_loader () {

	local package_install_list=""
	local list_dir_path="\${MASTER_PACKAGE_INSTALL_DIR_PATH}"

	mkdir -p "\${list_dir_path}"

	local item_file_path=""

	for item_file_path in \${list_dir_path}/*.txt; do

		if [[ -f "\${item_file_path}" ]]; then
			util_load_list "\${item_file_path}"
		fi

	done

}

function sys_master_find_package_install_list () {

	local package_install_list=\$(sys_master_find_package_install_list_via_loader)

	echo \${package_install_list}

}

function sys_master_package_install_list_is_not_exists () {

	local master_package_install_dir_path="\${MASTER_PACKAGE_INSTALL_DIR_PATH}"

	ls "\${master_package_install_dir_path}"/*.txt > /dev/null 2>&1

	local result="\${?}"

	if [[ "\${result}" == "0" ]]; then
		return 1
	else
		return 0
	fi

}

function extend_master_package_install () {

	echo "################################################################################"
	echo "## [Worker] extend_master_package_install"
	echo "################################################################################"

	if sys_master_package_install_list_is_not_exists; then
		return 0;
	fi

	echo "==== master install packages ===="

	local package_install_list=\$(sys_master_find_package_install_list)
	local run_cmd="apt-get install -y --install-recommends \${package_install_list}"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Extend / Master / Install Files
##

function extend_master_file_install () {

	echo "################################################################################"
	echo "## [Worker] extend_master_file_install"
	echo "################################################################################"

	local master_overlay_dir_path="\${MASTER_OVERLAY_DIR_PATH}"

	if ! [ -d "\${master_overlay_dir_path}" ]; then
		return 0;
	fi

	echo "==== master install files ===="

	local run_cmd="cp -rfT \${master_overlay_dir_path} /"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Extend / Hook
##

function extend_hook_main_script_run () {

	##
	## ## Run hook script before cleenup.
	##

	echo "################################################################################"
	echo "## [Worker] extend_hook_main_script_run"
	echo "################################################################################"

	local hook_portal_main_file_path="\${HOOK_PORTAL_MAIN_FILE_PATH}"

	local run_cmd="\${hook_portal_main_file_path}"

	if [ -x "\${run_cmd}" ]; then

		echo "==== run hook script ===="

		core_var_export

		echo \${run_cmd}
		\${run_cmd}

	fi

}


##
## ## Module / Extend / Installer / Install Packages
##

function sys_installer_find_package_install_list_via_loader () {

	local installer_package_install_dir_path="\${INSTALLER_PACKAGE_INSTALL_DIR_PATH}"

	local package_install_list=""
	local list_dir_path="\${installer_package_install_dir_path}"

	mkdir -p "\${list_dir_path}"

	local item_file_path=""

	for item_file_path in \${list_dir_path}/*.txt; do

		if [[ -f "\${item_file_path}" ]]; then
			util_load_list "\${item_file_path}"
		fi

	done

}

function sys_installer_find_package_install_list () {

	local package_install_list=\$(sys_installer_find_package_install_list_via_loader)

	echo \${package_install_list}

}

function sys_installer_package_install_list_is_not_exists () {

	local installer_package_install_dir_path="\${INSTALLER_PACKAGE_INSTALL_DIR_PATH}"

	ls "\${installer_package_install_dir_path}"/*.txt > /dev/null 2>&1

	local result="\${?}"

	if [[ "\${result}" == "0" ]]; then
		return 1
	else
		return 0
	fi

}

function extend_installer_package_install () {

	echo "################################################################################"
	echo "## [Worker] extend_installer_package_install"
	echo "################################################################################"

	if sys_installer_package_install_list_is_not_exists; then
		return 0;
	fi

	echo "==== installer install packages ===="

	local package_install_list=\$(sys_installer_find_package_install_list)
	local run_cmd="apt-get install -y --install-recommends \${package_install_list}"

	echo \${run_cmd}
	\${run_cmd}

}


##
## ## Module / Extend / Installer / Install Files
##

function extend_installer_file_install () {

	echo "################################################################################"
	echo "## [Worker] extend_installer_file_install"
	echo "################################################################################"

	local installer_overlay_dir_path="\${INSTALLER_OVERLAY_DIR_PATH}"

	if ! [ -d "\${installer_overlay_dir_path}" ]; then
		return 0;
	fi

	echo "==== installer install files ===="

	local run_cmd="cp -rfT \${installer_overlay_dir_path} /"

	echo \${run_cmd}
	\${run_cmd}

}




##
## ## Module / Cleanup
##

function cleanup_task () {

	echo "################################################################################"
	echo "## [Worker] cleanup_task"
	echo "################################################################################"

	echo "==== run cleanup task ===="

	echo apt-get autoremove -y --purge
	apt-get autoremove -y --purge

	echo apt-get clean
	apt-get clean

	echo 'rm -rf /tmp/* /var/lib/apt/lists/*'
	rm -rf /tmp/* /var/lib/apt/lists/*

}




##
## ## Model
##

function model_do_fulfill_scripts () {

	echo "################################################################################"
	echo "## [Chroot] model_do_fulfill_scripts"
	echo "################################################################################"

	echo "==== Head: fulfill process start ===="

	base_locale_init_locales


	core_hostname_config
	core_machine_id_config


	core_apt_sources_config
	core_no_snap_config
	core_apt_upgrade


	core_systemd_package_install
	kernel_main_package_install
	kernel_initramfs_package_install
	kernel_initramfs_create
	core_bootloader_package_install


	live_casper_package_install
	live_casper_config_install


	base_network_package_install
	base_network_config_install


	extend_master_package_install
	extend_master_file_install


	extend_installer_package_install
	extend_installer_file_install


	base_locale_default_locale


	extend_hook_main_script_run


	#base_dconf_package_install
	#base_dconf_db_update
	#base_gsettings_schema_compile


	kernel_initramfs_update


	core_machine_id_clear
	cleanup_task

	echo "==== Tail: fulfill process end ===="

}


##
## ## Portal
##

function portal_do_fulfill_scripts () {

	model_do_fulfill_scripts

}


##
## ## Main
##

function __main__ () {

	portal_do_fulfill_scripts

}

__main__

__FULFILL_SCRIPT__


}

function sys_run_fulfill_scripts_embedded () {

	local target="${1}"
	local delegate="sys_run_fulfill_scripts_embedded_for_${target}"

	"${delegate}"

}


################################################################################
## Module / Create System
################################################################################

function sys_copy_fulfill_scripts_to_chroot () {

	echo "################################################################################"
	echo "## [Controller] sys_copy_fulfill_scripts_to_chroot"
	echo "################################################################################"

	echo "==== Head: prepare chroot script asset start ===="


	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local template_dir_path="${TEMPLATE_DIR_PATH}"

	mkdir -p "${distro_img_dir_path}/opt/build"

	[ -d "${template_dir_path}" ] && cp -rfT "${template_dir_path}" "${distro_img_dir_path}/opt/build/template" || true


	echo "==== Tail: prepare chroot script asset end ===="

	return 0
}

function sys_run_fulfill_scripts_for_full_system () {

	sys_run_fulfill_scripts_embedded "full_system"

}

################################################################################
## Module / Create Base System
################################################################################

function core_create_skeleton_dir () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	mkdir -p "${distro_img_dir_path}"

}

function sys_create_core_system () {

	echo "################################################################################"
	echo "## [Controller] sys_create_core_system"
	echo "################################################################################"

	echo "==== create core system via debootstrap ===="

	local target_arch="${TARGET_ARCH}"
	local target_ubuntu_codename="${TARGET_UBUNTU_CODENAME}"
	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local target_ubuntu_mirror="${TARGET_UBUNTU_MIRROR}"
	local debootstrap_script_file_path="${DEBOOTSTRAP_SCRIPT_FILE_PATH}"


	local run_cmd="debootstrap
		--arch=${target_arch}
		--variant=minbase
		--components=main,universe,restricted,multiverse
		--include=ca-certificates,openssl,console-setup-linux,console-setup,locales,tzdata,whiptail,wget,dbus,gnupg
		${target_ubuntu_codename}
		${distro_img_dir_path}
		${target_ubuntu_mirror}
		${debootstrap_script_file_path}
	"

	echo ${run_cmd}
	${run_cmd}

}


################################################################################
## Module / Create Full System
################################################################################

function mod_create_full_system () {

	##
	## ## create skeleton dir
	##

	core_create_skeleton_dir


	##
	## ## debootstrap
	##

	sys_create_core_system

	sys_copy_fulfill_scripts_to_chroot


	##
	## ## chroot
	##

	mod_mount_before_chroot

	sys_run_fulfill_scripts_for_full_system

	mod_unmount_after_chroot


	return 0
}

################################################################################
## Module / Archive
################################################################################

function sys_construct_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_construct_isodir"
	echo "################################################################################"

	echo "==== create base iso folder structure ===="

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	mkdir -p "${distro_iso_dir_path}/casper"
	mkdir -p "${distro_iso_dir_path}/boot/grub"
	mkdir -p "${distro_iso_dir_path}/.disk"

}

function sys_archive_initialize () {

	sys_construct_isodir

}

function sys_archive_system_to_iso () {

	mod_create_disk_info_to_isodir

	mod_create_extra_file_to_isodir

	mod_copy_system_kernel_to_isodir

	mod_archive_systemdir_to_systemfile

	mod_archive_isodir_to_isofile

}

function mod_archive_system_to_iso () {

	echo "################################################################################"
	echo "## [Session] mod_archive_system_to_iso"
	echo "################################################################################"

	echo "==== Head: create iso process start ===="

	sys_archive_initialize

	mod_unmount_before_archive

	sys_archive_system_to_iso

	echo "==== Tail: create iso process end ===="

}


################################################################################
## Module / Archive / create disk info to isodir
################################################################################

function sys_create_disk_info_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_disk_info_to_isodir"
	echo "################################################################################"

	echo "==== create disk info to isodir ===="

	##
	## ## Create file: [iso/.disk/info]
	##

	local disk_info_file_path="${DISTRO_ISO_DIR_PATH}/.disk/info"
	local target_arch="${TARGET_ARCH}"
	local target_name="${TARGET_NAME}"
	local target_business_name="${TARGET_BUSINESS_NAME}"
	local target_build_version="${TARGET_BUILD_VERSION}"
	local release_date="$(date '+%Y%m%d')"

	echo "==== create file ${disk_info_file_path} ===="
	echo "${target_business_name} ${target_build_version} | ${target_arch} | (${release_date}) Release" | tee "${disk_info_file_path}"

}

function mod_create_disk_info_to_isodir () {

	sys_create_disk_info_to_isodir

}


################################################################################
## Module / Archive / copy system kernel to isodir
################################################################################

function sys_system_kernel_is_not_exists () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	ls "${distro_img_dir_path}/boot"/vmlinuz-* > /dev/null 2>&1

	local result="${?}"

	if [[ "${result}" == "0" ]]; then
		return 1
	else
		return 0
	fi

}

function sys_system_kernel_version () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	local kernel_version=$(ls "${distro_img_dir_path}/boot"/vmlinuz-* 2>/dev/null | head -n 1 | sed 's/.*vmlinuz-//')

	echo ${kernel_version}
}

function sys_copy_system_kernel_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_copy_system_kernel_to_isodir"
	echo "################################################################################"

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	if sys_system_kernel_is_not_exists; then

		echo "################################################################################"
		echo "## [Error] no kernel found in ${distro_img_dir_path}/boot"
		echo "################################################################################"

		echo "==== please install kernel first ===="

		exit;
	fi

	local kernel_version=$(sys_system_kernel_version)

	if [ -z "${kernel_version}" ]; then

		echo "################################################################################"
		echo "## [Error] no kernel found in ${distro_img_dir_path}/boot"
		echo "################################################################################"

		echo "==== please install kernel first ===="

		exit 1
	fi

	echo "==== copy system kernel to iso ===="

	echo cp -f "${distro_img_dir_path}/boot/vmlinuz-${kernel_version}" "${distro_iso_dir_path}/casper/vmlinuz"
	cp -f "${distro_img_dir_path}/boot/vmlinuz-${kernel_version}" "${distro_iso_dir_path}/casper/vmlinuz"

	echo cp -f "${distro_img_dir_path}/boot/initrd.img-${kernel_version}" "${distro_iso_dir_path}/casper/initrd"
	cp -f "${distro_img_dir_path}/boot/initrd.img-${kernel_version}" "${distro_iso_dir_path}/casper/initrd"

}

function mod_copy_system_kernel_to_isodir () {

	sys_copy_system_kernel_to_isodir

}


################################################################################
## Module / Archive / system folder to squashfs
################################################################################

function sys_archive_systemdir_to_squashfs () {

	##
	## ## Manpage
	##
	## * https://manpages.ubuntu.com/manpages/resolute/man1/mksquashfs.1.html
	## * https://manpages.debian.org/trixie/squashfs-tools/mksquashfs.1.en.html
	##

	echo "################################################################################"
	echo "## [Controller] sys_archive_systemdir_to_squashfs"
	echo "################################################################################"

	echo "==== archive systemdir to squashfs ===="

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	##mksquashfs "${distro_img_dir_path}" "${distro_iso_dir_path}/casper/filesystem.squashfs" -comp xz -b 1M -noappend

	mksquashfs "${distro_img_dir_path}" "${distro_iso_dir_path}/casper/filesystem.squashfs" \
		-noappend -no-duplicates -no-recovery \
		-wildcards -b 1M \
		-comp zstd -Xcompression-level 19 \
		-e "var/cache/apt/archives/*" \
		-e "tmp/*" \
		-e "tmp/.*" \
		-e "swapfile"

}

function mod_archive_systemdir_to_systemfile () {

	sys_archive_systemdir_to_squashfs

	sys_create_filesystem_size_to_isodir

}

function sys_create_filesystem_size_to_isodir () {

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	printf "%s" "$(du -sx --block-size=1 "${distro_img_dir_path}" | cut -f1)" | tee "${distro_iso_dir_path}/casper/filesystem.size" > /dev/null

}



################################################################################
## Module / Archive / archive isodir to isofile
################################################################################

function sys_archive_isodir_to_isofile_via_xorriso () {

	##
	## ## Manpage
	##
	## * https://manpages.ubuntu.com/manpages/resolute/man1/xorrisofs.1.html
	## * https://manpages.debian.org/trixie/xorriso/xorrisofs.1.en.html
	##

	echo "################################################################################"
	echo "## [Controller] sys_archive_isodir_to_isofile_via_xorriso"
	echo "################################################################################"

	echo "==== archive isodir to isofile via xooriso ===="

	local iso_out_file_path="${ISO_OUT_FILE_PATH}"

	## let iso_volid to upper case
	local iso_volid="${ISO_VOLID^^}"

	local iso_publisher="ubuntu-live-custom-template"


	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	pushd "${distro_iso_dir_path}" > /dev/null


	xorriso -as mkisofs \
		-output "${iso_out_file_path}" \
		-volid "${iso_volid}" \
		-publisher "${iso_publisher}" \
		-iso-level 3 \
		-full-iso9660-filenames \
		-rock \
		-joliet \
		-joliet-long \
		-partition_offset 16 \
		-eltorito-boot boot/grub/i386-pc/bios.img \
			-eltorito-catalog boot/boot.catalog \
			-no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
		--efi-boot boot/efi.img \
			-efi-boot-part --efi-boot-image \
	"."


	popd > /dev/null

}

function sys_archive_isodir_to_isofile () {

	##
	## ## process
	##

	sys_archive_isodir_to_isofile_via_xorriso


	##
	## ## extra process
	##

	sys_move_isofile_to_distdir

	sys_create_isofile_checksum

}

function mod_archive_isodir_to_isofile () {

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	pushd "${distro_iso_dir_path}" > /dev/null

	echo "################################################################################"
	echo "## [Master] mod_archive_isodir_to_isofile"
	echo "################################################################################"

	echo "==== Head: archive isodir to isofile start ===="


	echo
	echo "##"
	echo "## [Work Dir] $(pwd)"
	echo "##"
	echo

	##
	## ## essential
	##

	mod_create_grub_cfg_to_isodir

	mod_create_bios_boot_image_to_isodir

	mod_create_uefi_boot_image_to_isodir


	##
	## ## last step before core process
	##

	mod_create_md5sum_txt_to_isodir


	##
	## ## core process
	##

	sys_archive_isodir_to_isofile


	echo "==== Tail: archive isodir to isofile end ===="

	popd > /dev/null

}

function sys_move_isofile_to_distdir () {

	local des_dir_path="${DIST_DIR_PATH}"

	local src_file_path="${ISO_OUT_FILE_PATH}"
	local des_file_path="${ISO_DIST_FILE_PATH}"

	if [ -e ${src_file_path} ]; then
		echo "==== move iso file to dist folder ===="
		mkdir -p "${des_dir_path}"
		echo mv "${src_file_path}" "${des_file_path}"
		mv "${src_file_path}" "${des_file_path}"
	fi

}

function sys_create_isofile_checksum () {

	local iso_dist_file_path="${ISO_DIST_FILE_PATH}"

	if ! [ -e "${iso_dist_file_path}" ]; then
		return 0
	fi


	echo "==== create iso checksum ===="

	local dist_dir_path="${DIST_DIR_PATH}"

	local iso_dist_file_main_name="${ISO_DIST_FILE_MAIN_NAME}"
	local iso_dist_file_name="${ISO_DIST_FILE_NAME}"

	local checksum_dist_file_ext_name="sha256"
	local checksum_dist_file_name="${iso_dist_file_main_name}.${checksum_dist_file_ext_name}"

	pushd "${dist_dir_path}" > /dev/null

	sha256sum "${iso_dist_file_name}" | tee "${checksum_dist_file_name}"

	popd > /dev/null

}


################################################################################
## Module / Archive / create grub.cfg to isodir
################################################################################

function sys_create_grub_cfg_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_grub_cfg_to_isodir"
	echo "################################################################################"


	##
	## ## Create grub.cfg
	##

	echo "==== create grub.cfg on boot/grub/grub.cfg ===="

	local target_arch="${TARGET_ARCH}"
	local target_name="${TARGET_NAME}"
	local target_business_name="${TARGET_BUSINESS_NAME}"
	local target_build_version="${TARGET_BUILD_VERSION}"


	##
	## ## touch /ubuntu
	## ## for search --set=root --file /ubuntu
	##


	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	touch "${distro_iso_dir_path}/${target_name}"

cat << __EOF__ > "${distro_iso_dir_path}/boot/grub/grub.cfg"

search --set=root --file /${target_name}

set default="0"
set timeout=5

insmod all_video
insmod gfxterm

menuentry "${target_business_name} ${target_build_version} (${target_arch})" {
	set gfxpayload=keep
	linux /casper/vmlinuz boot=casper nopersistent ---
	initrd /casper/initrd
}

__EOF__

}

function mod_create_grub_cfg_to_isodir () {

	sys_create_grub_cfg_to_isodir

}

################################################################################
## Module / Archive / create bios boot image
################################################################################

function sys_create_bios_boot_image_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_bios_boot_image_to_isodir"
	echo "################################################################################"

	echo "==== create bios boot image to isodir ===="

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	##
	## ## Create BIOS boot image
	##

	mkdir -p "${distro_iso_dir_path}/boot/grub/i386-pc"

	echo "==== copy grub i386-pc modules into isodir ===="
	cp -f /usr/lib/grub/i386-pc/*.mod "${distro_iso_dir_path}/boot/grub/i386-pc/"
	cp -f /usr/lib/grub/i386-pc/*.lst "${distro_iso_dir_path}/boot/grub/i386-pc/"

	##
	## Create core.img / Way 1
	##

	#grub-mkimage -o "${DISTRO_ISO_DIR_PATH}/boot/grub/i386-pc/core.img" -O i386-pc -p /boot/grub biosdisk ext2 fat iso9660 search


	##
	## ## Create core.img / Way 2
	##

	grub-mkstandalone \
		--format="i386-pc" \
		--output="${distro_iso_dir_path}/boot/grub/i386-pc/core.img" \
		--install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls font gfxterm all_video" \
		--modules="linux16 linux normal iso9660 biosdisk search font gfxterm all_video" \
		--locales="" \
		--fonts="" \
		"boot/grub/grub.cfg=boot/grub/grub.cfg"


	##
	## ## Create bios.img
	##

	echo "==== create bios boot image on iso/boot/grub/i386-pc/bios.img ===="
	cat /usr/lib/grub/i386-pc/cdboot.img "${distro_iso_dir_path}/boot/grub/i386-pc/core.img" > "${distro_iso_dir_path}/boot/grub/i386-pc/bios.img"

}

function mod_create_bios_boot_image_to_isodir () {

	sys_create_bios_boot_image_to_isodir

}


################################################################################
## Module / Archive / create uefi boot image
################################################################################

function sys_create_uefi_boot_image_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_uefi_boot_image_to_isodir"
	echo "################################################################################"

	echo "==== create bios uefi image to isodir ===="

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	##
	## ## Create EFI boot image
	##

	echo "==== copy grub x86_64-efi modules into isodir ===="
	mkdir -p "${distro_iso_dir_path}/boot/grub/x86_64-efi"
	cp -f /usr/lib/grub/x86_64-efi/*.mod "${distro_iso_dir_path}/boot/grub/x86_64-efi/"
	cp -f /usr/lib/grub/x86_64-efi/*.lst "${distro_iso_dir_path}/boot/grub/x86_64-efi/"


	##
	## ## Create BOOTX64.EFI
	##

	rm -f "/tmp/BOOTX64.EFI"

	grub-mkstandalone \
		--format="x86_64-efi" \
		--output="/tmp/BOOTX64.EFI" \
		--install-modules="efi_gop normal linux iso9660 search" \
		"boot/grub/grub.cfg=boot/grub/grub.cfg"

	##
	## ## make a small FAT image (/boot/efi.img) to use as the EFI system partition
	##

	echo "==== create uefi boot image on /boot/efi.img ===="
	rm -f "${distro_iso_dir_path}/boot/efi.img"
	dd if=/dev/zero of="${distro_iso_dir_path}/boot/efi.img" bs=1M count=64 status=none || true
	mkfs.vfat -n EFI "${distro_iso_dir_path}/boot/efi.img"


	##
	## ## mount /boot/efi.img and populate, then unmount
	##

	local tmpdir="${distro_iso_dir_path}/boot/efi"
	umount "${tmpdir}" || umount -lf "${tmpdir}" || true
	rm -rf "${tmpdir}"
	mkdir -p "${tmpdir}"
	mount -o loop "${distro_iso_dir_path}/boot/efi.img" "${tmpdir}"
	mkdir -p "${tmpdir}/EFI/BOOT" "${tmpdir}/boot/grub"
	cp -f /tmp/BOOTX64.EFI "${tmpdir}/EFI/BOOT/BOOTX64.EFI"
	cp -rfT "${distro_iso_dir_path}/boot/grub" "${tmpdir}/boot/grub"
	sync
	umount "${tmpdir}" || umount -lf "${tmpdir}" || true
	rm -rf "${tmpdir}"
	rm -f /tmp/BOOTX64.EFI

}

function mod_create_uefi_boot_image_to_isodir () {

	sys_create_uefi_boot_image_to_isodir

}


################################################################################
## Module / Archive / create md5sum.txt
################################################################################

function sys_create_md5sum_txt_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_md5sum_txt_to_isodir"
	echo "################################################################################"

	echo "==== create md5sum.txt ===="

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	##
	## ## Generate md5sum.txt (exclude md5sum.txt itself)
	##

	pushd "${distro_iso_dir_path}" > /dev/null


	find . -type f -print0 \
		| xargs -0 md5sum \
		| sed 's|^\./||' \
		| grep -v -E '(^md5sum.txt$|/boot/grub/i386-pc/eltorito.img$)' \
		> "${distro_iso_dir_path}/md5sum.txt"


	popd > /dev/null

}

function mod_create_md5sum_txt_to_isodir () {

	sys_create_md5sum_txt_to_isodir

}

################################################################################
## Module / Archive / create extra file
################################################################################

function sys_create_extra_file_to_isodir () {

	sys_create_filesystem_manifest_to_isodir

	sys_create_filesystem_manifest_desktop_to_isodir

}

function mod_create_extra_file_to_isodir () {

	sys_create_extra_file_to_isodir

}

function sys_create_filesystem_manifest_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_filesystem_manifest_to_isodir"
	echo "################################################################################"

	echo "==== create filesystem.manifest ===="

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"
	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	chroot "${distro_img_dir_path}" dpkg-query -W --showformat='${Package} ${Version}\n' \
		> "${distro_iso_dir_path}/casper/filesystem.manifest"

}

function sys_create_filesystem_manifest_desktop_to_isodir () {

	echo "################################################################################"
	echo "## [Controller] sys_create_filesystem_manifest_desktop_to_isodir"
	echo "################################################################################"

	echo "==== create filesystem.manifest-desktop ===="

	local distro_iso_dir_path="${DISTRO_ISO_DIR_PATH}"

	if ! [ -e "${distro_iso_dir_path}/casper/filesystem.manifest" ]; then
		return 0
	fi

	cp -f "${distro_iso_dir_path}/casper/filesystem.manifest" "${distro_iso_dir_path}/casper/filesystem.manifest-desktop"

	sed -i -E '/(casper|ubiquity|live|calamares|cloud-init)/Id' "${distro_iso_dir_path}/casper/filesystem.manifest-desktop" || true

}




################################################################################
## Model and Portal
################################################################################




################################################################################
## Model / model_do_create_full_system
################################################################################

function model_do_create_full_system () {

	echo "################################################################################"
	echo "## [Main] model_do_create_full_system"
	echo "################################################################################"

	echo "==== create_full_system ===="



	##
	## ## create folder
	##

	mod_master_initialize


	##
	## ## create system
	##

	mod_create_full_system

}


################################################################################
## Portal / protal_do_create_full_system
################################################################################

function portal_do_create_full_system () {

	core_check_permission

	mod_bind_signal

	model_do_create_full_system

}




################################################################################
## Model / model_do_archive_system_to_iso
################################################################################

function model_do_archive_system_to_iso () {

	echo "################################################################################"
	echo "## [Main] model_do_archive_system_to_iso"
	echo "################################################################################"

	echo "==== archive_system_to_iso ===="

	##
	## ## archive
	##

	mod_archive_system_to_iso

}


################################################################################
## Portal / protal_do_archive_system_to_iso
################################################################################

function portal_do_archive_system_to_iso () {

	core_check_permission

	mod_bind_signal

	model_do_archive_system_to_iso

}




################################################################################
## Model / model_do_mount
################################################################################

function model_do_mount () {

	echo "################################################################################"
	echo "## [Main] model_do_mount"
	echo "################################################################################"

	echo "==== mount ===="

	mod_mount

}


################################################################################
## Portal / protal_do_mount
################################################################################

function portal_do_mount () {

	core_check_permission

	model_do_mount

}




################################################################################
## Model / model_do_unmount
################################################################################

function model_do_unmount () {

	echo "################################################################################"
	echo "## [Main] model_do_unmount"
	echo "################################################################################"

	echo "==== unmount ===="

	mod_unmount

}


################################################################################
## Portal / protal_do_unmount
################################################################################

function portal_do_unmount () {

	core_check_permission

	model_do_unmount

}




################################################################################
## Model / model_do_chroot
################################################################################

function sys_chroot () {

	echo "################################################################################"
	echo "## [Controller] sys_chroot"
	echo "################################################################################"

	echo "==== real chroot ===="

	local distro_img_dir_path="${DISTRO_IMG_DIR_PATH}"

	local run_cmd="chroot ${distro_img_dir_path}"

	echo ${run_cmd}
	${run_cmd}

}

function mod_chroot () {

	mod_mount_before_chroot

	sys_chroot

	mod_unmount_after_chroot

}

function model_do_chroot () {

	echo "################################################################################"
	echo "## [Main] model_do_chroot"
	echo "################################################################################"

	echo "==== chroot ===="

	mod_chroot

}


################################################################################
## Portal / protal_do_chroot
################################################################################

function portal_do_chroot () {

	core_check_permission

	mod_bind_signal

	model_do_chroot

}




################################################################################
## Model / model_do_clean
################################################################################

function sys_clean () {

	echo "################################################################################"
	echo "## [Controller] sys_clean"
	echo "################################################################################"


	local tmp_dir_path="${TMP_DIR_PATH}"

	local run_cmd=""


	echo "==== remove tmp dir ===="

	run_cmd="rm -rf ${tmp_dir_path}"

	echo ${run_cmd}
	${run_cmd}


	echo "==== remove wget-log ===="

	rm -f ./wget-log*


}

function mod_clean () {

	mod_unmount_before_clean

	sys_clean

}

function model_do_clean () {

	echo "################################################################################"
	echo "## [Main] model_do_clean"
	echo "################################################################################"

	echo "==== clean ===="

	mod_clean

}


################################################################################
## Portal / protal_do_clean
################################################################################

function portal_do_clean () {

	core_check_permission

	mod_bind_signal

	model_do_clean

}




################################################################################
## Model / model_do_prepare
################################################################################

function sys_prepare_package_for_build () {

	local run_cmd="apt-get install -y --install-recommends
		binutils
		curl
		debootstrap
		gnupg
		squashfs-tools
		xorriso
		grub-pc-bin
		grub-efi-amd64
		grub2-common
		mtools
		dosfstools
	"

	echo ${run_cmd}
	${run_cmd}

}

function mod_prepare () {

	sys_prepare_package_for_build

}

function model_do_prepare () {

	echo "################################################################################"
	echo "## [Main] model_do_prepare"
	echo "################################################################################"

	echo "==== prepare ===="

	mod_prepare

}


################################################################################
## Portal / protal_do_prepare
################################################################################

function portal_do_prepare () {

	core_check_permission

	model_do_prepare

}




################################################################################
## Model / model_do_build
################################################################################

function model_do_build () {

	echo "################################################################################"
	echo "## [Main] model_do_build"
	echo "################################################################################"

	echo "==== Head: domain process start ===="


	##
	## ## create folder
	##

	mod_master_initialize


	##
	## ## create system
	##

	mod_create_full_system


	##
	## ## archive
	##

	mod_archive_system_to_iso


	echo "==== Tail: domain process end ===="

}

function mod_finish_task () {

	##
	## ## finish task
	##

	echo "==== finish task ===="

	sys_copy_logfile_to_distdir
	sys_chown_product_to_runer_user

}

function sys_copy_logfile_to_distdir () {

	local src_log_file_path="${LOG_FILE_PATH}"

	if ! [ -e "${src_log_file_path}" ]; then
		return 0;
	fi


	echo "==== copy log.txt to distdir ===="

	local iso_dist_file_main_name="${ISO_DIST_FILE_MAIN_NAME}"

	local des_log_file_ext_name="log.txt"
	local des_log_file_name="${iso_dist_file_main_name}.${des_log_file_ext_name}"


	local des_dir_path="${DIST_DIR_PATH}"
	local des_log_file_path="${des_dir_path}/${des_log_file_name}"

	mkdir -p "${des_dir_path}"
	cp "${src_log_file_path}" "${des_log_file_path}"

}

function sys_chown_product_to_runer_user () {

	##
	## ## load runner-uid
	##

	local runner_uid_file_path="${RUNNER_UID_FILE_PATH}"

	if ! [ -e "${runner_uid_file_path}" ]; then
		return 0;
	fi

	local runner_uid="$(cat "${runner_uid_file_path}")"

	if [ -z "${runner_uid}" ]; then
		return 0;
	fi

	##
	## ## load runner-gid
	##

	local runner_gid_file_path="${RUNNER_GID_FILE_PATH}"

	if ! [ -e "${runner_gid_file_path}" ]; then
		return 0;
	fi

	local runner_gid="$(cat "${runner_gid_file_path}")"

	if [ -z "${runner_gid}" ]; then
		return 0;
	fi


	##
	## ## change owner
	##

	echo "==== change owner ===="

	local des_dir_path=""
	local run_cmd=""

	des_dir_path="${DIST_DIR_PATH}"
	run_cmd="chown -R ${runner_uid}:${runner_gid} ${des_dir_path}"

	echo ${run_cmd}
	${run_cmd}


	des_dir_path="${LOG_DIR_PATH}"
	run_cmd="chown -R ${runner_uid}:${runner_gid} ${des_dir_path}"

	echo ${run_cmd}
	${run_cmd}

}


################################################################################
## Portal / portal_do_build
################################################################################

function portal_do_build () {

	core_check_permission

	core_save_time_start

	mod_bind_signal

	#model_do_prepare

	model_do_build

	core_save_time_end

	mod_finish_task

}




################################################################################
## Model / model_do_test
################################################################################

function sys_test () {

	echo "################################################################################"
	echo "## [Controller] sys_test"
	echo "################################################################################"

	echo "==== develop test ===="


}

function mod_test () {

	#mod_unmount_before_test

	sys_test

}

function model_do_test () {

	echo "################################################################################"
	echo "## [Main] model_do_test"
	echo "################################################################################"

	echo "==== test ===="

	mod_test

}


################################################################################
## Portal / protal_do_test
################################################################################

function portal_do_test () {

	core_check_permission

	#mod_bind_signal

	model_do_test

}




################################################################################
## Action
################################################################################

function action_create_full_system () {

	portal_do_create_full_system

}

function action_archive_system_to_iso () {

	portal_do_archive_system_to_iso

}

function action_mount () {

	portal_do_mount

}

function action_unmount () {

	portal_do_unmount

}

function action_chroot () {

	portal_do_chroot

}

function action_prepare () {

	portal_do_prepare

}

function action_clean () {

	portal_do_clean

}

function action_build () {

	portal_do_build

}

function action_test () {

	portal_do_test

}


################################################################################
## Action / Main
################################################################################

function main_run_action () {

	local run_action="${RUN_ACTION}"

	local delegate="action_${run_action}"

	if ! is_function_exist "${delegate}"; then

		echo "################################################################################"
		echo "## [Warning] Action Not Exist: ${delegate}"
		echo "################################################################################"

		echo "==== Run Action Example ===="
		echo "sudo ./do-build.sh prepare"
		echo "sudo ./do-build.sh build"
		echo "sudo ./do-build.sh clean"

		exit 1

	fi


	"${delegate}"
}

################################################################################
## Main
################################################################################

function __main__ () {

	main_run_action

}

__main__


################################################################################
## Test
################################################################################

function __test__ () {

	echo "__test__"

	mod_test

}

##__test__
