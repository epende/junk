#!/bin/sh

DIR=/home/nginx/html/cam2
TZ="America/Denver"
FILENAME=cam-$(date +"%Y%m%d%H%M%S").mp4


/usr/bin/ffmpeg -y -rtsp_transport tcp -i rtsp://10.0.0.34:554/stream1 -vcodec copy -an -t 850 ${DIR}/${FILENAME}
ln -s ${DIR}/${FILENAME} latest.mp4
