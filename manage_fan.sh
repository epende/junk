#!/bin/bash

# Turn fan on/off depending on temp

WX_IP="10.0.0.96"
ON_TEMP=68
OFF_TEMP=71
LOW_OFF_TEMP=50
FAN_IP="10.0.0.71"
re='^[0-9]+([.][0-9]+)?$'

DATA=$(wget -q "http://${WX_IP}/newtemps.json" -O - | head -1)
echo $DATA

OVERRIDE_FILE="/home/pi/button_override.txt"
OVERRIDE_DELAY=3600

OUTTEMP=$(echo $DATA | head -1 | jq ".outside.temp2" | tr -d '"')
echo $OUTTEMP
if [[ -e $OVERRIDE_FILE ]]
then
    override_value=$(tail -1 $OVERRIDE_FILE)
    if [[ $override_value =~ $re ]]
    then
        override_on=$(echo "($(date +%s) - $(tail -1 $OVERRIDE_FILE)) < $OVERRIDE_DELAY" | bc -l)
    else
        echo "Override value not a number, skipping"
    fi
    echo "override file exists, override_on: $override_on"
    date_value=$(date +%s)
    echo "override_value: $override_value, date: $date_value"
    if [[ $override_on -eq 1 ]]
    then
        echo "Override file $OVERRIDE_FILE in effect"
        exit 0
    else
        echo "No override"
    fi
else
    echo "Override file not found"
fi

if [[ $OUTTEMP =~ $re ]] ; then
    OUTTEMP=$(printf "%.0f" "$OUTTEMP")
    echo "out: $OUTTEMP"
    if [[ $OUTTEMP =~ "185" ]]; then
        echo "Sensor malfunction"
        exit 1
    fi
    echo "outtemp:  $OUTTEMP"
    echo "ontemp:  $ON_TEMP"
    echo "lowtemp:  $LOW_OFF_TEMP"
    if [[ "$OUTTEMP" -le "$ON_TEMP" && $OUTTEMP -gt $LOW_OFF_TEMP ]]; then
        echo "on temp: $ON_TEMP"
        echo "out temp: $OUTTEMP"
        override_on=0
        ~/junk/tplink-smartplug.py -t $FAN_IP -c on
    elif [[ "$OUTTEMP" -ge "$OFF_TEMP" ]]; then
        echo "off"
        ~/junk/tplink-smartplug.py -t $FAN_IP -c off
    else
        echo "No action."
    fi
fi
