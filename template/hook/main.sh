#!/usr/bin/env bash


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
## Option
################################################################################




################################################################################
# Path / Base
################################################################################

##
## * gear / main.sh
##

GEAR_DIR_PATH="${BASE_DIR_PATH}"


################################################################################
## Path / Model / Base
################################################################################

##
## * plan
##

PLAN_DIR_PATH="${BASE_DIR_PATH}"


################################################################################
## Path / Model / Skeleton
################################################################################

##
## * plan / subs
## * plan / mods
##

SUBS_DIR_PATH="${PLAN_DIR_PATH}/subs"
MODS_DIR_PATH="${PLAN_DIR_PATH}/mods"




################################################################################
## Core
################################################################################

function core_var_dump () {


	##
	## ## Target
	##

	echo "TARGET_UBUNTU_CODENAME=${TARGET_UBUNTU_CODENAME}"
	echo "TARGET_UBUNTU_MIRROR=${TARGET_UBUNTU_MIRROR}"
	echo "TARGET_ARCH=${TARGET_ARCH}"
	echo "TARGET_NAME=${TARGET_NAME}"
	echo "TARGET_BUSINESS_NAME=${TARGET_BUSINESS_NAME}"
	echo "TARGET_HOSTNAME=${TARGET_HOSTNAME}"
	echo "TARGET_BUILD_VERSION=${TARGET_BUILD_VERSION}"
	echo "TARGET_INIT_LOCALES=${TARGET_INIT_LOCALES}"
	echo "TARGET_DEFAULT_LOCALE=${TARGET_DEFAULT_LOCALE}"


	##
	## ## Path
	##

	echo "HOOK_PORTAL_MAIN_FILE_PATH=${HOOK_PORTAL_MAIN_FILE_PATH}"

	echo "MASTER_OVERLAY_DIR_PATH=${MASTER_OVERLAY_DIR_PATH}"
	echo "MASTER_PACKAGE_INSTALL_DIR_PATH=${MASTER_PACKAGE_INSTALL_DIR_PATH}"

	echo "INSTALLER_OVERLAY_DIR_PATH=${INSTALLER_OVERLAY_DIR_PATH}"
	echo "INSTALLER_PACKAGE_INSTALL_DIR_PATH=${INSTALLER_PACKAGE_INSTALL_DIR_PATH}"


}




################################################################################
## Util
################################################################################

function util_load_list () {
	local file_path="${1}"
	cat $file_path  | while IFS='' read -r line; do
		trim_line=$(echo $line) # trim

		## https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
		## ignore leading #
		if [ "${trim_line:0:1}" == '#' ]; then
			continue;
		fi

		## ignore empty line
		if [[ -z "$trim_line" ]]; then
			continue;
		fi

		echo "$line"
	done
}




################################################################################
## Module
################################################################################


################################################################################
## Module / Mods / Rundwn / Option
################################################################################

DEFAULT_MODS_RUNDOWN_FILE_NAME="rundown.txt"
MODS_RUNDOWN_FILE_NAME="${MODS_RUNDOWN_FILE_NAME:=$DEFAULT_MODS_RUNDOWN_FILE_NAME}"
MODS_RUNDOWN_FILE_PATH="${MODS_DIR_PATH}/${MODS_RUNDOWN_FILE_NAME}"

DEFAULT_MODS_INSTALL_FILE_NAME="install.sh"
MODS_INSTALL_FILE_NAME="${MODS_INSTALL_FILE_NAME:=$DEFAULT_MODS_INSTALL_FILE_NAME}"


################################################################################
## Module / Mods / Rundwn / Main
################################################################################

##
## The mods/rundown.txt file is used to control which modules are executed and their execution order.
##

function mod_mods_find_rundown_via_loader () {

	local rundown_file_path="${MODS_RUNDOWN_FILE_PATH}"

	util_load_list "${rundown_file_path}"

}

function mod_mods_find_rundown_via_cat () {

	local rundown_file_path="${MODS_RUNDOWN_FILE_PATH}"

	cat "${rundown_file_path}"

}

function mod_mods_find_rundown () {

	##local mods_list=$(mod_mods_find_rundown_via_cat)
	local mods_list=$(mod_mods_find_rundown_via_loader)

	echo ${mods_list}

}

function mod_mods_exec_by_rundown () {

	echo "################################################################################"
	echo "## [Controller] mod_mods_exec_by_rundown"
	echo "################################################################################"

	echo "==== run mods ===="

	local rundown_file_path="${MODS_RUNDOWN_FILE_PATH}"

	if ! [ -e "${rundown_file_path}" ]; then

		echo "################################################################################"
		echo "## [Warning] mods rundown file not exist"
		echo "################################################################################"

		echo "==== file not exist: ${rundown_file_path} ===="

		return 0
	fi


	echo "==== run mods by mods/rundown.txt ===="

	local install_file_name="${MODS_INSTALL_FILE_NAME}"
	local mods_dir_path="${MODS_DIR_PATH}"
	local mods_list=$(mod_mods_find_rundown)
	local mod_name
	local mod_dir_path
	local mod_install_file_path

	for mod_name in ${mods_list}; do

		mod_dir_path="${mods_dir_path}/${mod_name}"
		mod_install_file_path="${mod_dir_path}/${install_file_name}"

		if [[ -d "${mod_dir_path}" && -x "${mod_install_file_path}" ]]; then

			echo "################################################################################"
			echo "## [Mods] exec mod"
			echo "################################################################################"

			echo "==== mod: ${mod_name} ===="

			pushd "${mod_dir_path}" > /dev/null

			"${mod_install_file_path}"

			popd > /dev/null

		fi

	done

}




################################################################################
## Module / Hook
################################################################################

function mod_hook_subs () {

	##mod_subs_exec_by_rundown

	return 0

}

function mod_hook_mods () {

	mod_mods_exec_by_rundown

}


################################################################################
## Model / Hook
################################################################################

function model_hook_main () {

	##core_var_dump

	mod_hook_subs

	mod_hook_mods


}


################################################################################
## Portal
################################################################################

function portal_hook_main () {

	model_hook_main

}


################################################################################
## Main
################################################################################

echo "################################################################################"
echo "## [Hook] run: ${0} "
echo "################################################################################"

echo "==== args:" ${@} "===="

function __main__ () {

	portal_hook_main "${@}"

}

__main__ "${@}"


################################################################################
## Test
################################################################################

function __test__ () {

	echo "__test__"

}

##__test__
