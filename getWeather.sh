#!/bin/sh
if [[ $# -eq 1 ]] ; then
    echo 'USAGE:  $0 <IP> <Wunderground password>'
    exit 0
fi

IP=$1
PASSWORD=$2
STATION_ID="KCOFORTC310"

IFS=$'\n'
for f in $(wget http://${IP}/livedata.htm -O - | grep "input name" | grep -v "efault" | grep -i "temp\|hum\|wind\|press\|gust\|rain" | awk -F'"' '{print $4"="$14}'); 
do 
    val=$(echo $f | grep -i outhumi | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        humidity=$val
    fi
    val=$(echo $f | grep -i outTemp | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        tempf=$val
    fi
    val=$(echo $f | grep -i outHumi | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        outhumi=$val
    fi
    val=$(echo $f | grep -i abspres | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        baromin=$val
    fi
    val=$(echo $f | grep -i windir | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        winddir=$val
    fi
    val=$(echo $f | grep -i avgwind | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        windspeedmph=$val
    fi
    val=$(echo $f | grep -i gustspeed | awk -F"=" '{print $2}')
    if [ ! -z $val ];
    then
        windgustmph=$val
    fi
done

echo "humidity: $humidity"
echo "tempf: $tempf"
echo "windspeedmph: $windspeedmph"
echo "windgustmph: $windgustmph"
echo "winddir: $winddir"
echo "baromin: $baromin"
dateutc=$(date -u +%F+%T | sed s/:/\%3A/g)

url="https://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?ID=${STATION_ID}&PASSWORD=${PASSWORD}&dateutc=${dateutc}&winddir=${winddir}&windspeedmph=${windspeedmph}&windgustmph=${windgustmph}&tempf=${tempf}&baromin=${baromin}&humidity=${humidity}&softwaretype=custom&action=updateraw"

#echo "$url"
echo $(wget "${url}" -O -)


#curl https://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KCOFORTC310&PASSWORD=${PASSWORD}&winddir=${winddir}&windspeedmph=${windspeedmph}&windgustmph=${windgustmph}&tempf=${tempf}&baromin=${baromin}&humidity=${humidity}&action=updateraw&realtime=1&rtfreq=2.5
#https://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?ID=KCASANFR5&PASSWORD=XXXXXX&dateutc=2000-01-01+10%3A32%3A35&winddir=230&windspeedmph=12&windgustmph=12&tempf=70&rainin=0&baromin=29.1&dewptf=68.2&humidity=90&weather=&clouds=&softwaretype=vws%20versionxx&action=updateraw

#curl https://rtupdate.wunderground.com/weatherstation/updateweatherstation.php?ID=KCOFORTC310&PASSWORD=${PASSWORD}&winddir=${winddir}&windspeedmph=${windspeedmph}&windgustmph=${windgustmph}&tempf=${tempf}&baromin=${baromin}&humidity=${humidity}&action=updateraw&realtime=1&rtfreq=2.5
