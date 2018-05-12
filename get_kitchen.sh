#!/bin/bash 

# Install bc

PORT_KITCHEN=9000
PORT_BASEMENT=8000
if [ $# -eq 0 ] ; then
    echo 'USAGE:  $0 <IP of ambient server>'
    exit 0
fi
IP_AMBIENT=$1

KTEMP=$(wget --quiet http://10.0.0.74:${PORT_KITCHEN}/uncached/text/7E.B92E00001000/EDS0068/temperature -O - | awk '{print $2}' | tr -d '\r' | tr -d '\n') 
KHUM=$(wget --quiet http://10.0.0.74:${PORT_KITCHEN}/uncached/text/7E.B92E00001000/EDS0068/humidity -O - | awk '{print $2}' | tr -d '\n' | tr -d '%' | tr -d '\r') 
GTEMP=$(wget --quiet http://10.0.0.74:${PORT_KITCHEN}/uncached/text/28.FF9A706A1403/temperature -O - | awk '{print $2}' | tr -d '\n' | tr -d '%' | tr -d '\r') 
OUTTEMP=$(wget --quiet http://10.0.0.96:${PORT_BASEMENT}/uncached/text/10.193E4D010800/temperature -O - | awk '{print $2}' | tr -d '\n' | tr -d '%' | tr -d '\r')
OUTHUM=$(wget --quiet http://10.0.0.96:${PORT_BASEMENT}/uncached/text/26.80E4A8000000/humidity -O - | awk '{print $2}' | tr -d '\n' | tr -d '%' | tr -d '\r')
TZ=America/Denver
DT=$(TZ=America/Denver date +%F" "%X" "%s | tr -d '\r' | tr -d '\n') 
WIND_SPEED_THRESHOLD=20
WIND_GUST_THRESHOLD=30

AMBIENT_LINE=$(wget http://${IP_AMBIENT}/livedata.htm -O - | grep "input name" | grep -v "efault" | grep -i "temp\|hum\|wind\|press\|gust\|rain" | awk -F'"' '{print $4" "$14}')

AMBIENT_IN_TEMP=$(echo $AMBIENT_LINE | grep -i inTemp | awk '{print $2}')
AMBIENT_IN_TEMP=$(echo $AMBIENT_LINE | perl -ne 'while(/inTemp (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_OUT_TEMP=$(echo $AMBIENT_LINE | perl -ne 'while(/outTemp (\d+(\.\d+){0,1})/ig){print "$1";}')

AMBIENT_IN_HUMI=$(echo $AMBIENT_LINE | perl -ne 'while(/inHumi (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_OUT_HUMI=$(echo $AMBIENT_LINE | perl -ne 'while(/outHum (\d+(\.\d+){0,1})/ig){print "$1";}')

AMBIENT_ABS_PRES=$(echo $AMBIENT_LINE | perl -ne 'while(/AbsPress (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_REL_PRES=$(echo $AMBIENT_LINE | perl -ne 'while(/RelPress (\d+(\.\d+){0,1})/ig){print "$1";}')

AMBIENT_WIND_DIR=$(echo $AMBIENT_LINE | perl -ne 'while(/windir (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_AVG_WIND=$(echo $AMBIENT_LINE | perl -ne 'while(/avgwind (\d+(\.\d+){0,1})/ig){print "$1";}')

AMBIENT_GUST=$(echo $AMBIENT_LINE | perl -ne 'while(/gustspeed (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_DAILY_GUST=$(echo $AMBIENT_LINE | perl -ne 'while(/dailygust (\d+(\.\d+){0,1})/ig){print "$1";}')

AMBIENT_HOURLY_RAIN=$(echo $AMBIENT_LINE | perl -ne 'while(/rainofhourly (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_DAILY_RAIN=$(echo $AMBIENT_LINE | perl -ne 'while(/rainofdaily (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_WEEKLY_RAIN=$(echo $AMBIENT_LINE | perl -ne 'while(/rainofweekly (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_MONTHLY_RAIN=$(echo $AMBIENT_LINE | perl -ne 'while(/rainofmontly (\d+(\.\d+){0,1})/ig){print "$1";}')
AMBIENT_YEARLY_RAIN=$(echo $AMBIENT_LINE | perl -ne 'while(/rainofyearly (\d+(\.\d+){0,1})/ig){print "$1";}')

# If wind speed or gust exceeds threshold, turn on the led

high_wind=$(echo "$AMBIENT_AVG_WIND >= $WIND_SPEED_THRESHOLD" | bc -l)
high_gust=$(echo "$AMBIENT_GUST >= $WIND_GUST_THRESHOLD" | bc -l)
echo "wind:  $AMBIENT_AVG_WIND"
echo "high wind:  $high_wind"
echo "high gust:  $high_gust"

# If wind speed or gusts exceed threshold
# turn on the LED
if [[ "$high_wind" -ne 0 || "$high_gust" -ne 0 ]];
then
    echo "Turning on LED"
    wget --quiet "http://10.0.0.74:${PORT_KITCHEN}/uncached/7E.B92E00001000/EDS0068/LED?control=2"
else
    echo "Turning off LED"
    wget --quiet "http://10.0.0.74:${PORT_KITCHEN}/uncached/7E.B92E00001000/EDS0068/LED?control=0"
fi


echo "{\"date\": \"$DT\", \"kitchen\": {\"temp\": \"$KTEMP\", \"hum\": \"$KHUM\"}, \"garage\": {\"temp\": \"$GTEMP\"}, \"outside\": {\"temp\": \"$OUTTEMP\", \"temp2\": \"$AMBIENT_OUT_TEMP\", \"hum\": \"$OUTHUM\", \"hum2\": \"$AMBIENT_OUT_HUMI\", \"pressure\": \"$AMBIENT_ABS_PRES\", \"wind\": \"$AMBIENT_AVG_WIND\", \"dir\": \"$AMBIENT_WIND_DIR\", \"gust\": \"$AMBIENT_GUST\", \"dailygust\": \"$AMBIENT_DAILY_GUST\", \"rain\": \"$AMBIENT_DAILY_RAIN\",}}," >> /var/www/html/wx/kitchen.txt
tac /var/www/html/wx/kitchen.txt > /var/www/html/wx/temps.json
