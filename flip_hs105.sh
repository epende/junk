#!/bin/bash

# Power cycle the HS105 controlling
# POE router

source /home/pi/py3env/bin/activate
# turn it off
/home/pi/pyHS100/example.py

# turn it back on
/home/pi/pyHS100/example.py

