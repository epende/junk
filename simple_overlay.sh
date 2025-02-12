#!/bin/bash

# Overlay text on an image

OVR_STRING=$(/home/pendergr/wx_scraper/collect.py -i wx.dammitly.net | jq | tr -d '"')
echo $OVR_STRING

mogrify -fill white -font Courier -undercolor '#00000080' -pointsize 42 -gravity SouthWest -annotate +10+10 "$OVR_STRING" $1
