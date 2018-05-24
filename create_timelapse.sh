#!/bin/bash

DIR="/home/nginx/html/cam1/images/$(date +%Y%m%d)/$(date +%H)"
FN=${DIR}/_timelapse.mp4

echo "dir: $DIR"
echo "fn: $FN"
echo "1: $1"

if [ $1 == "-p" ] ; then
    FN=${DIR}/_partial.mp4
fi
if [ $1 == "-pd" ]; then
    DIR="/home/nginx/html/cam1/images/$(date +%Y%m%d)"
    FN=${DIR}/_partial_daily.mp4
    cat $(ls -1rt $(find ${DIR} -name "*.jpg")) | /usr/bin/ffmpeg -y -f image2pipe  -i - -vcodec mpeg4 ${FN}
    exit
fi
if [ $1 == "-d" ] ; then
    DIR="/home/nginx/html/cam1/images/$(date +%Y%m%d)"
    FN=${DIR}/_daily.mp4
    cat $(ls -1rt $(find ${DIR} -name "*.jpg")) | /usr/bin/ffmpeg -y -f image2pipe  -i - -vcodec mpeg4 ${FN}
    exit
fi
echo "fn: $FN"

# Create timelapse at end of hour
cat ${DIR}/*.jpg | /usr/bin/ffmpeg -y -f image2pipe  -i - -vcodec mpeg4 ${FN}
