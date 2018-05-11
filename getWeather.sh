#!/bin/sh
if [[ $# -eq 0 ]] ; then
    echo 'USAGE:  $0 <IP>'
    exit 0
fi

IP=$1

IFS=$'\n'
for f in $(wget http://${IP}/livedata.htm -O - | grep "input name" | grep -v "efault" | grep -i "temp\|hum\|wind\|press\|gust\|rain" | awk -F'"' '{print $4" = "$14}'); 
do 
    echo $f
done
