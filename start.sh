#!/bin/bash

PORT="${PORT:-7500}"

_update() {
	echo "Updating Pavlov VR";
        cd ~/Steam && ./steamcmd.sh +login anonymous +force_install_dir /home/steam/pavlovserver +app_update 622970 +exit
}

_run() {
	echo "Running Pavlov VR Server";
        cd ~/pavlovserver && ./PavlovServer.sh -PORT="${PORT}"
}

case $1 in
"update")
	_update
	;;
	
"run")
	_run
	;;

*)
	_update
	_run
	;;
esac

