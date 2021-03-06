#!/bin/bash

source $BIN_DIR/functions.sh

export ID=$(getId)
export VERSION=$(getVersion)

BANNER="$ID:$VERSION"

figlet -m smushmode $BANNER

echo

if [ -z "$ETCD_LISTEN_CLIENT_URLS" ] && [ ! -z "$SETTINGS_URL" ]; then
	echo "Gathering the service settings..."
	
	SETTINGS=$(getSettings)
	PORT=
	
	if [ ! -z "$SETTINGS" ]; then
		PORT=`echo $SETTINGS | jq -r .port.value`
		
		if [ $PORT == "null" ]; then
			unset PORT
		fi
	fi
	
	echo "Service settings were gathered!"
fi

export SETTINGS
export PORT

$BIN_DIR/install.sh

echo "Starting the service..."

if [ ! -z "$1" ]; then
	eval $1
fi

if [ ! -z "$PORT" ]; then
	while [ true ];
	do
		RESULT=`netstat -an|grep $PORT|grep LISTEN`
		
		if [ -z "$RESULT" ]; then
			sleep 1
		else
			break
		fi
	done
fi

echo "Service started!"

crond -f -l 0