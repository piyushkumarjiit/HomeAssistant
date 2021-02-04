#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

#Abort installation if any of the commands fail
#set -e
INSTALL_PYTHON="false"
PYTHON_VERSION="Python-3.8.0"
PYTHON_COMMAND_VERSION="python3.8"

source ~/.bashrc
#source /home/homeassistant/.bashrc

#Update everything
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y

CURRENT_PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Python version returned: $CURRENT_PYTHON_VERSION while requested Python version is : $PYTHON_VERSION"
if [[ "Python-$CURRENT_PYTHON_VERSION" == "$PYTHON_VERSION" || "$INSTALL_PYTHON" == "false" ]]
then
	echo "$PYTHON_VERSION already available. Proceeding with HA install."
else
	echo "Installed Python version: $CURRENT_PYTHON_VERSION. $PYTHON_VERSION is not present. Installing."
	#Install Python 3.8
	wget "https://raw.githubusercontent.com/piyushkumarjiit/HomeAssistant/main/install_python3.8.sh"
	chmod 755 install_python3.8.sh
	./install_python3.8.sh
	echo "Python installed."
fi

source ~/.bashrc
HA_SERVICE_STATUS=$(sudo systemctl status home-assistant@pi > /dev/null 2>&1; echo $?)

if [[ $HA_SERVICE_STATUS -gt 0 ]]
then

	#Start Home Assistant install

	#Add necessary packages
	echo "Verifying required packages are present."
	sudo apt-get install -y python3 python3-dev python3-venv python3-pip 
	#sudo apt-get install python3.8-dev python3.8-venv python3.8-pip  -y 
	#sudo apt-get install -y install python3.8 python3.8-dev python3.8-venv
	sudo apt-get install libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5  -y 

	#Create User and add to relevant groups
	echo "Creating HA user and adding him to necessary groups."
	sudo useradd -rm homeassistant -G dialout,gpio,i2c

	#Create srv direcotry and change its ownership
	cd /srv
	sudo mkdir -p homeassistant
	sudo chown -R homeassistant:homeassistant homeassistant
	echo "HA directory created and permissions updated."
	#Browse to HA directory and activate python3.8
	cd /srv/homeassistant
	# run default shell for user (homeassistant) in user's home directory
	#sudo -u homeassistant -H -s
	#sudo -H -u homeassistant -s /bin/bash <<- EOF
	sudo -H -u homeassistant -s /bin/bash -c '/usr/local/bin/python3.8 -m venv . '
	#sudo -H -u homeassistant -s /bin/bash -c 'python3.8 -m venv --without-pip .'
	#sudo -H -u homeassistant -s /bin/bash -c 'python3.8 -m ensurepip --upgrade'
	#sudo -H -u homeassistant -s /bin/bash -c 'pip3 install --upgrade pip'
	sudo -H -u homeassistant -s /bin/bash -c 'echo "Python 3 virtual env setup."'
	sudo -H -u homeassistant -s /bin/bash -c 'source /srv/homeassistant/bin/activate'
	sudo -H -u homeassistant -s /bin/bash -c 'echo "Virtual environment activated."'
	sudo -H -u homeassistant -s /bin/bash -c '/srv/homeassistant/bin/python3.8 -m pip install wheel'
	sudo -H -u homeassistant -s /bin/bash -c 'echo "Wheel installed."'
	sudo -H -u homeassistant -s /bin/bash -c '/srv/homeassistant/bin/pip3.8 install pillow --global-option="build_ext" --global-option="--enable-zlib" --global-option="--enable-jpeg" --global-option="--enable-tiff" --global-option="--enable-freetype" --global-option="--enable-webp" --global-option="--enable-webpmux" --global-option="--enable-jpeg2000"'
	sudo -H -u homeassistant -s /bin/bash -c '/srv/homeassistant/bin/pip3.8 install homeassistant'
	sudo -H -u homeassistant -s /bin/bash -c 'echo "Home Assistant installed"'
	
	#exit
	#EOF
	
	#Add to bash
	#echo "source /srv/homeassistant/bin/activate" | sudo tee -a /home/homeassistant/.bashrc
	#echo "source /srv/homeassistant/bin/activate" | sudo tee -a /home/pi/.bashrc

	echo "Back in $(pwd) as $(whoami)"

	cd ~

	wget 'https://raw.githubusercontent.com/piyushkumarjiit/HomeAssistant/main/home-assistant@homeassistant.service'
	echo "Service file downlaoded."
	sudo cp 'home-assistant@homeassistant.service' '/etc/systemd/system/home-assistant@homeassistant.service'
	rm -f "home-assistant@homeassistant"

	sudo systemctl --system daemon-reload
	sudo systemctl enable home-assistant@homeassistant
	#sudo systemctl start home-assistant@homeassistant
	echo "Starting Home Assistant."
	sudo -H -u homeassistant -s /bin/bash -c '/srv/homeassistant/bin/hass'

else

	echo "HA Service running. Skipping installation."
	sudo systemctl status home-assistant@homeassistant -l
	sudo journalctl -f -u home-assistant@homeassistant

fi

echo "Script complete."