#!/bin/bash
#Author: Piyush Kumar (piyushkumar.jiit@.com)

FIRMWARE_URL="https://github.com/Koenkk/Z-Stack-firmware/raw/master/coordinator/Z-Stack_Home_1.2/bin/default/CC2531_DEFAULT_20201127.zip"
BINARY_NAME="CC2531ZNP-Prod.hex"

# Dependent packages
DEPENDENT_PACKAGES=("git" "wiringpi")

#Check dependencies (wiringpi, git )if WiringPi is installed

for package in "${DEPENDENT_PACKAGES[@]}"
do
  echo -n "Checking if $package is installed: "
  PACKAGE_STATUS=$( dpkg-query -l | grep $package > /dev/null 2>&1; echo $? )
  if [[ $PACKAGE_STATUS == 0 ]]
  then
  	echo "$package is installed."
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  else
  	# Install Dependencies
  	echo "Need to install $package."
  	sudo apt-get install -y $package
  	let "DEPENDENCY_STATUS = $DEPENDENCY_STATUS + $PACKAGE_STATUS"
  	echo "Dep Status changed: $DEPENDENCY_STATUS. Proceeding with dependency installation."
  	break
  fi
done


# Clone CC2531 flash
git clone https://github.com/jmichault/flash_cc2531.git

# CD to cloned directory
cd flash_cc2531
echo "$(pwd)"
# Test connection
CONNECTION_OK=$(./cc_chipid)

if [[ $CONNECTION_OK == '  ID = b524.' ]]
then
	echo "Connection seems to be OK, proceeding with firmware update."
	# Download firmware for cc2531
	wget -q -O CC2531.zip "$FIRMWARE_URL"
	unzip CC2531.zip
	echo "Start flashing."
	./cc_erase
	./cc_write "$BINARY_NAME"
	echo "Flashing complete."

else
	echo "Connection not OK $CONNECTION_OK. Please connect wires correctly. Aborting firmware update."
	sleep 5
fi
echo "All done."
