#!/bin/bash

# Overlay text on an image

BASE_DIR="/home/nginx/html/cam1/images/$(date +%Y%m%d)/$(date +%H)"
LATEST_FN="${BASE_DIR}/../../latest.jpg"

WX_IP="10.0.0.96"

DATA=$(wget -q "http://${WX_IP}/newtemps.json" -O - | head -1)
echo $DATA

INTEMP=$(echo $DATA | head -1 | jq ".kitchen.temp1" | tr -d '"')
UPTEMP=$(echo $DATA | head -1 | jq ".upstairs.temp2" | tr -d '"')
OUTTEMP=$(echo $DATA | head -1 | jq ".outside.temp1" | tr -d '"')
WIND=$(echo $DATA | head -1 | jq ".outside.windgustmph" | tr -d '"')
HUM=$(echo $DATA | head -1 | jq ".outside.hum1" | tr -d '"')
FAN=$(echo $DATA | head -1 | jq ".upstairs.fan" | tr -d '"')
INHUM=$(echo $DATA | head -1 | jq ".kitchen.hum1" | tr -d '"')
COFFEE=$(echo $DATA | head -1 | jq ".kitchen.coffee" | tr -d '"')
RAIN=$(echo $DATA | head -1 | jq ".outside.hourlyrainin" | tr -d '"')

OVR_STRING="out: $OUTTEMP"
OVR_STRING="out: $OUTTEMP\nhum: $HUM\nin: $INTEMP\nhum: $INHUM\nupstairs: $UPTEMP\nwind: $WIND\nrain: $RAIN\nfan: $FAN\ncoffee: $COFFEE"

FN=$(find $BASE_DIR -type f -name "*.jpg" | sort -n | tail -2 | head -1)
COUNTER=0

# Only overlay on the one file specified on the command line
if [ ! -z $1 ]
then
    mogrify -fill white -undercolor '#00000080' -pointsize 42 -gravity NorthWest -annotate +10+10 "$OVR_STRING" $1
    exit 0
fi

while [ "$COUNTER" -lt 59 ]; do 
    mogrify -fill white -undercolor '#00000080' -pointsize 42 -gravity NorthWest -annotate +10+10 "$OVR_STRING" $FN
    cp $FN $LATEST_FN
    echo "cp $FN $LATEST_FN"
    mogrify -fill white -undercolor '#00000080' -pointsize 42 -gravity NorthWest -annotate +10+10 "$OVR_STRING" $LATEST_FN
    sleep 1
    FN=$(find $BASE_DIR -type f -name "*.jpg" | sort -n | tail -2 | head -1)
    echo $FN
    echo $LATEST_FN
    let "COUNTER++"
done
