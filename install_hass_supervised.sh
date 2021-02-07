#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

MACHINE_NAME=raspberrypi3
HA_SUPERVISED_SCRIPT="https://raw.githubusercontent.com/Kanga-Who/home-assistant/master/supervised-installer.sh"
USER_ACCOUNT="pi"
HA_IP_ADDRESS=$(hostname -I | cut -d" " -f 1)
MODEM_MGR_STATUS=$(sudo systemctl status ModemManager | grep "Active: inactive (dead)" > /dev/null 2>&1; echo $? )
DEPENDENT_PACKAGES=("software-properties-common" "apparmor-utils" "apt-transport-https" "ca-certificates" "curl" "dbus" "jq" "network-manager")
DOCKER_STATUS=$(sudo systemctl status docker > /dev/null 2>&1; echo $? )

for package in "${DEPENDENT_PACKAGES[@]}"
do
  echo -n "Checking if $package is installed: "
  PACKAGE_STATUS=$( dpkg-query -l | grep $package > /dev/null 2>&1; echo $? )
  if [[ $PACKAGE_STATUS == 0 ]]
  then
  	echo "Yes"
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  else
  	echo "No"
  	# sudo apt-get install -y $package
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  	echo "Dep Status changed: $DEPENDENCY_STATUS. Proceeding with dependency installation."
  	break
  fi
done

# Update and upgrade.  Reboot (optional)
sudo apt-get update -q -y && sudo apt-get upgrade -q -y && apt-get dist-upgrade -q -y && sudo apt-get autoremove -q -y
echo "Update complete."

#Create and Add user to sudo group
sudo adduser $USER_ACCOUNT
sudo usermod -aG sudo $USER_ACCOUNT

if [[ $MODEM_MGR_STATUS != 0 && $DEPENDENCY_STATUS != 0 ]]
then
	#Install dependencies
	sudo apt-get -q install -y software-properties-common apparmor-utils apt-transport-https ca-certificates curl dbus jq network-manager
	echo "Dependencies insta complete."
	# Disable modem manager
	sudo systemctl disable ModemManager
	# Stop modem manager
	sudo systemctl stop ModemManager
	sudo systemctl --system daemon-reload
	echo "ModemManager stopped and disabled."

	echo "Dependencies installed, restarting. Please rerun the script upon restart."
	if [[ $DOCKER_STATUS != 0 ]]
	then
		#Install Docker
		curl -fsSL get.docker.com | sudo /bin/bash -s
		# Add user to Docker group
		sudo usermod -aG docker $USER_ACCOUNT
		sleep 30
		sudo systemctl --system daemon-reload
		#Restart Docker
		sudo systemctl restart docker
	else
		echo "Docker already installed. Proceeding with HA installation."
	fi

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
	echo "."
	echo "HA UI up @ $HA_IP_ADDRESS:8123. Please proceed with rest of the config using your browser."
	# Reboot
	#sudo reboot
else
	echo "Dependencies set up. Continuing with HA Supervised install."
	if [[ $DOCKER_STATUS != 0 ]]
	then
		#Install Docker
		curl -fsSL get.docker.com | sudo /bin/bash -s
		# Add user to Docker group
		sudo usermod -aG docker $USER_ACCOUNT
		sleep 30
		sudo systemctl --system daemon-reload
		#Restart Docker
		sudo systemctl restart docker
	else
		echo "Docker already installed. Proceeding with HA installation."
	fi

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
	echo "."
	echo "HA UI up @ $HA_IP_ADDRESS:8123. Please proceed with rest of the config using your browser."
fi





