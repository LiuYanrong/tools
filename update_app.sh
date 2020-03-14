#!/bin/bash

#######################################
# Update system application
#######################################

die() {
	echo ERROR: "$@"
	exit 1
}

	# update app list
	sudo apt-get update || die "apt updae Failed!"
	echo "Update app list ok."

	# download and install app
	sudo apt-get dist-upgrade -y || die "download or install Failed!"
	echo "Update app ok."

	# auto remove not used app
	sudo apt-get autoremove || die "Auto remove Failed!"
	echo "Auto remove ok."

	# auto clean
	sudo apt-get autoclean || die "Auto clean Failed!"
	echo "Auto clean ok."
	
