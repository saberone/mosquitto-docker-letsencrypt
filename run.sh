#!/bin/bash

# Check and if needed install/renew certs
# 	Note that this script (certbot.sh) is also
# 	run weekely from /etc/periodic/weekly/croncert.sh
#
#	WARNING: 
#		Duing the weekly check, if certs are renewed, 
#		the mosquitto process is restarted, causing
#		a brief (few second) unavoidable service disruption
#
/certbot.sh

# This script assumes a standard persistent directory and file layout of:
#	/mosquitto/
#		conf/
#			mosquitto.conf	- the main configuation file
#			passwd		- the password file
#		log/
#
#	The presense and location of mosquitto.conf isn't optional.
#       (We could allow user definition via environment var, but honestly why bother)
#
#	The location of the log directory and passwd file can be
#	mapped differently in mosquitto.conf.  If so, this script will
#	simply generate warnings, but continue to function.
#
if [ ! -d "/mosquitto/log" ]; then
	echo "WARNING: missing /mosquitto/log directory"
	echo "WARNING: ignore if your mosquitto.conf has a non-standard configuration" 
fi

# create blank passwd if it doesn't exist
if [ -d "/mosquitto/conf" ]; then
	if [ ! -f "/mosquitto/conf/passwd" ]; then
		echo "Creating blank passwd file at /mosquitto/conf/passwd"
		touch /mosquitto/conf/passwd
	fi
else
	echo "WARNING: /mosquitto/conf should be mapped to persistent docker volume"
	echo "WARNING: ignore if your mosquitto.conf has a non-standard configuration" 
fi

# execute any pre-exec scripts, useful for customization of images
if [ -d "/scripts" ]; then
	echo "Looking for user scripts to execute..."
	for i in /scripts/*sh
	do
    	if [ -e "${i}" ]; then
        	echo "Found user script - processing $i"
        	. "${i}"
    	fi
	done
fi

echo "Starting mosquitto process (daemon)..."
if [ -f "/mosquitto/conf/mosquitto.conf" ]; then
	# Note that this method of starting mosquitto results in the process
	# not receiving the SIGTERM signal from Docker on shutdown.  This is
	# nessary because mosquitto must be restarted automatically when
	# certificates are renewed. In other words, we need the container to
	# continue running beyond the life of the mosquitto process. 
	#
	# A possible enhancement would be to include an "is alive" check
	# for mosquitto to restart it if required or exit the container.
	/usr/sbin/mosquitto -c /mosquitto/conf/mosquitto.conf&
	echo "Going to sleep..."
	# sleep infinity not available, so 9999d should be an acceptable substitute :-)
	sleep 9999d
else
	echo "ERROR: missing /mosquitto/conf/mosquitto.conf"
	echo "ERROR: check your Docker volume mappings"
	echo "Exiting..."
fi
