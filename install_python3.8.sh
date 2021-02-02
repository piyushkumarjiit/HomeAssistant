#!/bin/bash
#Author: piyushkumar.jiit@gmail.com

#Abort installation if any of the commands fail
set -e

PYTHON_VERSION="Python-3.8.0"
PYTHON_COMMAND_VERSION="python3.8"
PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz"

CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Python version returned: $CURRENT_PYTHON_VERSION while requested Python version is : $PYTHON_VERSION"

#Update everything
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y

#Install Python
echo "Installed Python version: $CURRENT_PYTHON_VERSION. $PYTHON_VERSION is not present. Installing."
#Install Python 3.8
sudo apt-get install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libffi-dev tar wget vim
wget "$PYTHON_DOWNLOAD_URL"
sudo tar zxf "$PYTHON_VERSION.tgz"
cd "$PYTHON_VERSION"
sudo ./configure --enable-optimizations
sudo make -j 4
sudo make altinstall
sudo update-alternatives --install /usr/bin/python python /usr/local/bin/$PYTHON_COMMAND_VERSION 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/$PYTHON_COMMAND_VERSION 1
#update-alternatives --install /usr/bin/python python /usr/local/bin/$PYTHON_COMMAND_VERSION 1
#update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/$PYTHON_COMMAND_VERSION 1
sudo update-alternatives --config python
sudo update-alternatives --config python3

echo "Updated Python version: $($PYTHON_COMMAND_VERSION -V)"
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" >> ~/.bashrc
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/pi/.bashrc
#echo "alias python=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/homeassistant/.bashrc
#echo "alias python3=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/pi/.bashrc
#echo "alias python3=/usr/local/bin/$PYTHON_COMMAND_VERSION" | sudo tee -a /home/homeassistant/.bashrc
#source ~/.bashrc
#source /home/homeassistant/.bashrc
CURRENT_PYTHON_VERSION=`python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Defult python version after update: $CURRENT_PYTHON_VERSION"
CURRENT_PYTHON_VERSION=`python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))'`
echo "Defult python3 version after update: $CURRENT_PYTHON_VERSION"
sudo rm -rf "$PYTHON_VERSION.tgz"
sudo rm -rf "$PYTHON_VERSION"

echo "Python installation script complete."