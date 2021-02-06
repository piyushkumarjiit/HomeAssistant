#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

MACHINE_NAME==raspberrypi3
HA_SUPERVISED_SCRIPT="https://raw.githubusercontent.com/Kanga-Who/home-assistant/master/supervised-installer.sh"
USER_ACCOUNT="pi"
HA_IP_ADDRESS=$(hostname -I | cut -d" " -f 1)
MODEM_MGR_STATUS=$(sudo systemctl status ModemManager | grep "Active: inactive (dead)" > /dev/null 2>&1; echo $? )
APPARMOR_STATUS=$( dpkg-query -l | grep apparmor > /dev/null 2>&1; echo $? )

# Update and upgrade.  Reboot (optional)
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

#Create and Add user to sudo group
adduser $USER_ACCOUNT
usermod -aG sudo $USER_ACCOUNT


if [[ $MODEM_MGR_STATUS != 0 && $APPARMOR_STATUS != 0 ]]
then
	# Change to root
	sudo -i
	#Install dependencies
	apt-get install -y software-properties-common apparmor-utils apt-transport-https ca-certificates curl dbus jq network-manager
	# Disable modem manager
	systemctl disable ModemManager
	# Stop modem manager
	systemctl stop ModemManager
	# Reboot
	sudo reboot
else
	# Change to root
	sudo -i
	#Install Docker
	curl -fsSL get.docker.com | sh
	# Add user to Docker group
	sudo usermod -aG docker $USER_ACCOUNT
	exit
	# Install HA Supervised
	sudo -H -u homeassistant -s /bin/bash -c curl -sL "$HA_SUPERVISED_SCRIPT" | bash -s  -- -m $MACHINE_NAME
	echo ""
	echo -n "HA starting on $HA_IP_ADDRESS:8123. Waiting ."

	HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)

	while [[ $HA_IP_STATUS != "200"  ]]
	do
		HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)
		echo -n "."
	done

	echo "HA UI up @ $HA_IP_ADDRESS:8123. Please proceed with rest of the config using your browser."
fi




