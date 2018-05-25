#!/bin/bash

# Watch the nginx access log for a particular url
# and flip the device state if it's detected

if [ $# -lt 2 ] ; then
    echo 'USAGE:  $0 <IP of device> <device name>'
    exit 0
fi

IP=$1
NAME=$2

# If this is set, just power on
ON=$3

FILE="/var/log/nginx/access.log"

tail -n0 -F $FILE | \
while read LINE
do
  if echo "$LINE" | grep "$NAME" 1>/dev/null 2>&1
  then
    STATE=$(~/junk/tplink-smartplug.py -t $IP -c info | tail -1 | cut -c 12- | jq '.system.get_sysinfo.relay_state')

    # We just want it on
    if [[ ! -z $ON ]];
    then
        echo "Powering on"
        ~/junk/tplink-smartplug.py -t $IP -c on
        continue
    fi

    if [[ "$STATE" -eq 0 ]];
    then
        echo "Device is off, powering on"
        ~/junk/tplink-smartplug.py -t $IP -c on
    else
        echo "Device is on, powering off"
        ~/junk/tplink-smartplug.py -t $IP -c off
    fi
  fi
done
