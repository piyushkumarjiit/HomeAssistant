#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

MACHINE_NAME==raspberrypi3
HA_SUPERVISED_SCRIPT="https://raw.githubusercontent.com/Kanga-Who/home-assistant/master/supervised-installer.sh"
USER_ACCOUNT="pi"
HA_IP_ADDRESS=$(hostname -I | cut -d" " -f 1)
MODEM_MGR_STATUS=$(sudo systemctl status ModemManager | grep "Active: inactive (dead)" > /dev/null 2>&1; echo $? )
PACKAGE_STATUS=$( dpkg-query -l | grep apparmor > /dev/null 2>&1; echo $? )
DEPENDENT_PACKAGES=("software-properties-common" "apparmor-utils" "apt-transport-https" "ca-certificates" "curl" "dbus" "jq" "network-manager")


for package in "${DEPENDENT_PACKAGES[@]}"
do
  echo "Checking if $package is installed."
  PACKAGE_STATUS=$( dpkg-query -l | grep $package > /dev/null 2>&1; echo $? )
  if [[ $PACKAGE_STATUS == 0 ]]
  then
  	echo "$package is installed."
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  else
  	echo "$package is not installed."
  	# sudo apt-get install -y $package
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  	echo "Dep Status changed: $DEPENDENCY_STATUS"
  	break
  fi

done

# Update and upgrade.  Reboot (optional)
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y

#Create and Add user to sudo group
sudo adduser $USER_ACCOUNT
sudo usermod -aG sudo $USER_ACCOUNT

if [[ $MODEM_MGR_STATUS != 0 && $DEPENDENCY_STATUS != 0 ]]
then
	#Install dependencies
	sudo apt-get install -y software-properties-common apparmor-utils apt-transport-https ca-certificates curl dbus jq network-manager
	# Disable modem manager
	sudo systemctl disable ModemManager
	# Stop modem manager
	sudo systemctl stop ModemManager

	echo "Dependencies installed, restarting. "
	# Reboot
	sudo reboot

	#echo "Dependencies set up. Continuing with HA Supervised install."
	# Change to root
	#sudo -i
	#Install Docker
	curl -fsSL get.docker.com | sudo /bin/bash -s
	# Add user to Docker group
	sudo usermod -aG docker $USER_ACCOUNT
	sleep 30
	#Restart Docker
	sudo systemctl restart docker

	#exit
	# Install HA Supervised
	curl -sL "$HA_SUPERVISED_SCRIPT" | sudo /bin/bash -s  -- -m $MACHINE_NAME
	echo ""
	echo -n "HA starting on $HA_IP_ADDRESS:8123. Waiting ."

	HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)

	while [[ $HA_IP_STATUS != "200"  ]]
	do
		HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)
		echo -n "."
		sleep 30
	done

	echo "HA UI up @ $HA_IP_ADDRESS:8123. Please proceed with rest of the config using your browser."

else
	echo "Dependencies set up. Continuing with HA Supervised install."
	# Change to root
	#sudo -i
	#Install Docker
	curl -fsSL get.docker.com | sudo /bin/bash -s
	# Add user to Docker group
	sudo usermod -aG docker $USER_ACCOUNT
	sleep 30
	#Restart Docker
	sudo systemctl restart docker
	#exit
	# Install HA Supervised
	curl -sL "$HA_SUPERVISED_SCRIPT" | sudo /bin/bash -s  -- -m $MACHINE_NAME
	echo ""
	echo -n "HA starting on $HA_IP_ADDRESS:8123. Waiting ."

	HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)

	while [[ $HA_IP_STATUS != "200"  ]]
	do
		HA_IP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $HA_IP_ADDRESS:8123)
		sleep 30
		echo -n "."
	done

	echo "HA UI up @ $HA_IP_ADDRESS:8123. Please proceed with rest of the config using your browser."
fi





