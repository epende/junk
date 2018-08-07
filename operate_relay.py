#!/usr/bin/env python

# Script to operate 8 channel relay device

from lxml import html
import argparse
import json
import re
import time
import sys

import requests

IP="10.0.0.77"

PARSER = argparse.ArgumentParser(description='Operate 8 channel relay device')
PARSER.add_argument('-i', '--ip', metavar='ip',
                    help='IP address of relay device (defaults to 10.0.0.77)')
PARSER.add_argument('-a', '--alias', metavar='alias',
                    help='Relay alias (ex: garage or 0')
PARSER.add_argument('-c', '--command', metavar='command',
                    help='Command (ex: on/off/0/1/status)')

ARGS = PARSER.parse_args()

if ARGS.ip:
    IP = ARGS.ip

if ARGS.command is None:
    raise ValueError("Must provide command")

if ARGS.alias is None:
    raise ValueError("Must provide relay alias")

COMMAND=ARGS.command
ALIAS=ARGS.alias

page = requests.get(observer_url, verify=False)

# Device to standard name translation
name_table = {'garage':  6,
              'ac':  5,
              'zone1':  1,
              'zone2':  2,
              'zone3':  3,
              'zone4':  4,
              'reserved7':  7,
              'reserved8':  8,
              'status':  None,
              }

pairs = {}


for name in name_table.keys():
    if name == alias:
        relay = name_table[name]

try:
    relay = int(alias)
except: ValueError:
    pass



for name, value in zip(names, values):
    # Use fuzzy matching on names in case they change
    if re.search('temp', name, re.I):
        pairs[name_table[name]] = value

    if re.search('curr', name, re.I) and re.search('time', name, re.I):
        pairs[name_table[name]] = value

    if re.search('pres', name, re.I):
        pairs[name] = value

    if re.search('humi', name, re.I):
        pairs[name_table[name]] = value

    if re.search('uv', name, re.I):
        pairs[name] = value

    if re.search('solar', name, re.I):
        pairs[name] = value

    if re.search('rain', name, re.I) and re.search('of', name, re.I):
        pairs[name_table[name]] = value

    if re.search('gust', name, re.I) or re.search('wind', name, re.I):
        if name in name_table:
            pairs[name_table[name]] = value
        else:
            pairs[name] = value

for name, value in pairs.iteritems():
    if re.search(r'--', value):
        pairs[name] = None

print json.dumps(weather)
