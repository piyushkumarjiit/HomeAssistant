#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

#Abort installation if any of the commands fail
#set -e

PYTHON_VERSION="Python-3.8.0"
PYTHON_COMMAND_VERSION="python3.8"
PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz"

#Update everything
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y

CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`

if [[ "$CURRENT_PYTHON_VERSION" == "$PYTHON_VERSION" ]]
then
	echo "$PYTHON_VERSION already available. Proceeding with HA install."
else
	echo "Installed Python version: $CURRENT_PYTHON_VERSION. $PYTHON_VERSION is not present. Installing."
	#Install Python 3.8
	sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev tar wget vim
	wget "$PYTHON_DOWNLOAD_URL"
	sudo tar zxf "$PYTHON_VERSION.tgz"
	cd "$PYTHON_VERSION"
	sudo ./configure --enable-optimizations
	sudo make -j 4
	sudo make altinstall
	echo "Updated Python version: $($PYTHON_COMMAND_VERSION -V)"
	echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" >> ~/.bashrc
	source ~/.bashrc
	CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
	echo "Defult python version after update: $CURRENT_PYTHON_VERSION"
	sudo rm -rf "$PYTHON_VERSION.tgz"
	sudo rm -rf "$PYTHON_VERSION"
fi

#Start Home Assistant install

#Add necessary packages
echo "Verifying required packages are present."
sudo apt-get install python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev libjpeg-dev zlib1g-dev autoconf build-essential libopenjp2-7 libtiff5 -y

#Create User and add to relevant groups
echo "Creating HA user and adding him to necessary groups."
sudo useradd -rm homeassistant -G dialout,gpio,i2c

#Create srv direcotry and change its ownership
cd /srv
sudo mkdir homeassistant
sudo chown homeassistant:homeassistant homeassistant
echo "HA directory created and permissions updated."
# run default shell for user (homeassistant) in user's home directory
sudo -u homeassistant -H -s
#sudo su -s /bin/bash homeassistant
#Browse to HA directory and activate python3.8
cd /srv/homeassistant
python3.8 -m venv .
source /srv/homeassistant/bin/activate
exit
source /srv/homeassistant/bin/activate
#Add to bash
#sudo $(echo "source /srv/homeassistant/bin/activate" >> /home/homeassistant/.bashrc)

#sudo -u homeassistant -H -s
sudo su -s /bin/bash homeassistant
source /srv/homeassistant/bin/activate
# Install wheel
python3 -m pip install wheel

# Install Home Assistant
pip3 install homeassistant

#Start Home Assistant service
#hass

exit

wget "https://raw.githubusercontent.com/piyushkumarjiit/HomeAssistant/main/home-assistant%40pi.service"
mv home-assistant@pi.service /etc/systemd/system/home-assistant@pi.service

sudo systemctl --system daemon-reload
sudo systemctl enable home-assistant@pi
sudo systemctl start home-assistant@pi

#sudo systemctl status home-assistant@pi -l
#sudo journalctl -f -u home-assistant@pi

