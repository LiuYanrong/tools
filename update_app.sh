#!/bin/bash

#######################################
# Update system application
#######################################

die() {
	echo ERROR: "$@"
	exit 1
}
	USER=`whoami`
	echo $USER	
	
	# update app list
	if [ "root" == $USER ]; then
		apt-get update || die "apt updae Failed!"
	else
		sudo apt-get update || die "apt updae Failed!"
	fi
	echo "Update app list ok."

	# download and install app
	if [ "root" == $USER ]; then
		apt-get dist-upgrade -y || die "download or install Failed!"
	else
		sudo apt-get dist-upgrade -y || die "download or install Failed!"
	fi
	echo "Update app ok."

	# auto remove not used app
	if [ "root" == $USER ]; then
		apt-get autoremove -y || die "Auto remove Failed!"
	else
		sudo apt-get autoremove -y || die "Auto remove Failed!"
	fi
	echo "Auto remove ok."

	# auto clean
	if [ "root" == $USER ]; then
		apt-get autoclean -y || die "Auto clean Failed!"
	else
		sudo apt-get autoclean -y || die "Auto clean Failed!"
	fi
	echo "Auto clean ok."
	
