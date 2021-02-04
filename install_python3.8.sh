#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

#Abort installation if any of the commands fail
#set -e

PYTHON_VERSION="Python-3.8.7"
PYTHON_COMMAND_VERSION="python3.8.7"
PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/3.8.7/Python-3.8.7.tgz"

CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Defult python version before update: $CURRENT_PYTHON_VERSION while requested Python version is : $PYTHON_VERSION"
CURRENT_PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Defult python3 version before update: $CURRENT_PYTHON_VERSION while requested Python version is : $PYTHON_VERSION"

#Update everything
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y

#Install Python
echo "Installed Python version: $CURRENT_PYTHON_VERSION. $PYTHON_VERSION is not present. Installing."
#Install Python 3.8
sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev tar wget vim

wget "$PYTHON_DOWNLOAD_URL"
tar zxf "$PYTHON_VERSION.tgz"
cd "$PYTHON_VERSION"
No_Of_Processors=$(cat /proc/cpuinfo|egrep -c "^processor")
#--prefix=/usr
sudo ./configure --prefix=/usr/local --enable-optimizations
sudo make -j $No_Of_Processors
sudo make altinstall
#sudo make install
#sudo update-alternatives --install /usr/bin/python python /usr/local/bin/$PYTHON_COMMAND_VERSION 1
#sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/$PYTHON_COMMAND_VERSION 1
#sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/$PYTHON_COMMAND_VERSION 1

#sudo update-alternatives --config python
#sudo update-alternatives --config python3

echo "Updated Python version: $($PYTHON_COMMAND_VERSION -V)"
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" >> ~/.bashrc
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/pi/.bashrc
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/homeassistant/.bashrc
#echo "alias python3=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/pi/.bashrc
#echo "alias python3=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/homeassistant/.bashrc
source ~/.bashrc

#sudo ln -s -f /usr/local/bin/python3.8 /usr/local/bin/python3
#sudo ln -s -f /usr/local/python3.8 /usr/bin/python3

#source /home/homeassistant/.bashrc
CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Defult python version after update: $CURRENT_PYTHON_VERSION"
CURRENT_PYTHON_VERSION=`/usr/local/bin/python3.8.7 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "New python3 version after update: $CURRENT_PYTHON_VERSION"
cd ~
sudo rm -f "$PYTHON_VERSION.tgz"
sudo rm -Rf "$PYTHON_VERSION"

sudo apt-get autoremove -y

echo "Python installation script complete."