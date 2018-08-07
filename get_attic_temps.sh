#!/bin/sh

# Get temperature from attic sensors

URL="http://10.0.0.69"
TRIES=10

data=$(wget --tries=10 -q $URL -O -)
if [ $? -ne 0 ]; then
    exit 1
fi

datesec=$(date -u +%s)
dateloc=$(date +%F' '%r)

ac=$(echo $data | awk -F',' '{print $1}' | awk -F':' '{print $2}' | tr -d "'")
temp1=$(echo $data | awk -F',' '{print $3}' | awk -F':' '{print $2}' | tr -d '}' | tr -d "'")
hum=$(echo $data | awk -F',' '{print $2}' | awk -F':' '{print $2}' | tr -d '}' | tr -d "'")

echo "{\"dateutc\": \"$dateloc\", \"datesec\": $datesec, \"attic\": {\"ac\": $ac, \"temp1\": $temp1, \"hum\": $hum}}"
