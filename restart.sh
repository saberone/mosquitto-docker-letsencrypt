#!/bin/bash
ps cax | grep mosquitto > /dev/null
if [ $? -eq 0 ]; then
        echo "Mosquitto is running."
        pkill -f "mosquitto"
        sleep 1
        /usr/sbin/mosquitto -c /mosquitto/conf/mosquitto.conf&
else
        echo "Mosquitto is not running."
fi
