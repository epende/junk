#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'USAGE:  $0 <IP> <camera password>'
    exit 0
fi

DIR="/home/nginx/html/cam1/images"
IP=$1
PASS=$2
URL="http://${IP}/cgi-bin/api.cgi?cmd=Snap&channel=0&user=camuser&password=${PASSWORD}"
TZ="America/Denver"

COUNTER=0
while [ "$COUNTER" -lt 59 ];
do
    FILENAME=cam-$(date +"%Y%m%d%H%M%S").jpg
    DATE_STR=$(date +"%Y%m%d")
    HOUR=$(date +"%H")
    FULL_PATH=${DIR}/${DATE_STR}/${HOUR}
    FULL_FN=${DIR}/${DATE_STR}/${HOUR}/${FILENAME}
    echo $FULL_PATH
    if [ ! -e ${FULL_PATH} ];
    then
        mkdir -p ${FULL_PATH}
    fi
    wget "${URL}" -O ${FULL_FN}
    /home/pendergr/overlay_wx.sh ${FULL_FN}
    cp ${FULL_FN} ${DIR}/latest.jpg
    sleep 1
    let "COUNTER++"
done
