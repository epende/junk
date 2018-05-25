#!/bin/bash

# Turn fan on/off depending on temp

WX_IP="10.0.0.96"
ON_TEMP=68
FAN_IP="10.0.0.71"
re='^[0-9]+([.][0-9]+)?$'

DATA=$(wget -q "http://${WX_IP}/newtemps.json" -O - | head -1)
echo $DATA

OUTTEMP=$(echo $DATA | head -1 | jq ".outside.temp1" | tr -d '"')
echo $OUTTEMP
if [[ $OUTTEMP =~ $re ]] ; then
    OUTTEMP=$(printf "%.0f" "$OUTTEMP")
    echo $OUTTEMP
    if [[ "$OUTTEMP" -le "$ON_TEMP" ]]; then
        echo "on"
        ~/junk/tplink-smartplug.py -t $FAN_IP -c on
    fi
fi
