#!/bin/bash
# Simple bash script for install and configure PhpMyAdmin
# URL: https://github.com/zevilz/PhpMyAdminInstaller
# Author: Alexandr "zEvilz" Emshanov
# License: MIT
# Version: 1.1.0

# Main Vars
PMA_VERSION="latest"
PMA_TEMP_DIR=""

# Check for sudo if not root
if [[ $UID != 0 ]]; then
	echo
	$SETCOLOR_FAILURE
	echo "Please run this script with sudo!"
	$SETCOLOR_NORMAL
	echo
	exit 1
fi

# Script Vars
BLOWFISH_SECRET=$(tr -dc 'A-Za-z0-9' < /dev/urandom | dd bs=1 count=32 2>/dev/null)
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
PMA_ISSET=0

# Install
echo
echo -n "Checking for installed version... "
if [ -d "/usr/share/phpmyadmin" ]; then
	PMA_ISSET=1
	$SETCOLOR_SUCCESS
	echo "Found"
	$SETCOLOR_NORMAL
else
	$SETCOLOR_SUCCESS
	echo "Not found"
	$SETCOLOR_NORMAL
fi
if [ $PMA_ISSET -eq 1 ]; then
	echo -n "Creating backup... "
	CUR_TIME=$(date +%s)
	tar -zcvf /usr/share/phpmyadmin_$CUR_TIME.tar.gz /usr/share/phpmyadmin >/dev/null 2>/dev/null
	if [ -f "/usr/share/phpmyadmin_$CUR_TIME.tar.gz" ]; then
		rm -rf /usr/share/phpmyadmin
		$SETCOLOR_SUCCESS
		echo -n "Created"
		$SETCOLOR_NORMAL
		echo " (/usr/share/phpmyadmin_$CUR_TIME.tar.gz)"
	else
		$SETCOLOR_FAILURE
		echo "Not created"
		$SETCOLOR_NORMAL
		echo
		exit 1
	fi
fi
cd /usr/share/
echo -n "Downloading new version... "
if [ $PMA_VERSION = "latest" ]; then
	wget -c https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz >/dev/null 2>/dev/null
else
	wget -c https://files.phpmyadmin.net/phpMyAdmin/$PMA_VERSION/phpMyAdmin-$PMA_VERSION-all-languages.tar.gz >/dev/null 2>/dev/null
fi
if [ -f "/usr/share/phpMyAdmin-$PMA_VERSION-all-languages.tar.gz" ]; then
	$SETCOLOR_SUCCESS
	echo "Done"
	$SETCOLOR_NORMAL
else
	$SETCOLOR_FAILURE
	echo "Unable to download!"
	$SETCOLOR_NORMAL
	echo
	exit 1
fi
echo -n "Installing... "
tar xzf phpMyAdmin-$PMA_VERSION-all-languages.tar.gz >/dev/null 2>/dev/null
mv phpMyAdmin-*-all-languages phpmyadmin >/dev/null 2>/dev/null
rm phpMyAdmin-$PMA_VERSION-all-languages.tar.gz* >/dev/null 2>/dev/null
if [ -d "/usr/share/phpmyadmin" ]; then
	$SETCOLOR_SUCCESS
	echo "Done"
	$SETCOLOR_NORMAL
else
	$SETCOLOR_FAILURE
	echo "Can't install!"
	$SETCOLOR_NORMAL
	echo
	exit 1
fi

# Configure
echo -n "Configuring... "
if [ -z "$PMA_TEMP_DIR" ]; then
	PMA_TEMP_DIR="'./tmp/'"
	mkdir /usr/share/phpmyadmin/tmp
	chmod -R 777 /usr/share/phpmyadmin/tmp
fi
sed -i "s|define('TEMP_DIR',.*;|define('TEMP_DIR', $PMA_TEMP_DIR);|" /usr/share/phpmyadmin/libraries/vendor_config.php
sed -i "s|define('CONFIG_DIR',.*;|define('CONFIG_DIR', '/usr/share/phpmyadmin/');|" /usr/share/phpmyadmin/libraries/vendor_config.php
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sed -i "s|\$cfg\['blowfish_secret'\].*;|\$cfg['blowfish_secret'] = '$BLOWFISH_SECRET';|" /usr/share/phpmyadmin/config.inc.php
$SETCOLOR_SUCCESS
echo "Done"
$SETCOLOR_NORMAL
echo
exit 0
