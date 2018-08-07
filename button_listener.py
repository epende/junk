#!/usr/bin/env python

# Wait for arp request from dash button

import subprocess
import socket
import struct
import binascii
rawSocket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(0x0003))
while True:
    packet = rawSocket.recvfrom(2048)
    ethernet_header = packet[0][0:14]
    ethernet_detailed = struct.unpack("!6s6s2s", ethernet_header)
    arp_header = packet[0][14:42]
    if len(arp_header) < 28:
        arp_detailed = struct.unpack("2s2s1s1s2s6s4s6s2s", arp_header)
    else:
        arp_detailed = struct.unpack("2s2s1s1s2s6s4s6s4s", arp_header)

    # skip non-ARP packets
    ethertype = ethernet_detailed[2]

    if ethertype != '\x08\x06':
       continue
    source_mac = binascii.hexlify(arp_detailed[5])
    dest_ip = socket.inet_ntoa(arp_detailed[8])

    #print "Source mac:  %s, dest ip: %s" % (source_mac, dest_ip)
    if source_mac == '78e1031490b5':
        print "Battry button pressed, IP = " + dest_ip
        state = subprocess.check_output("/home/pi/junk/tplink-smartplug.py -t 10.0.0.71 -c info | tail -1 | cut -c 12- | jq '.system.get_sysinfo.relay_state'", shell=True)
        print state
        if state > 0:
            # It's on
            state = subprocess.check_output("/home/pi/junk/tplink-smartplug.py -t 10.0.0.71 -c off", shell=True)
        else:
            state = subprocess.check_output("/home/pi/junk/tplink-smartplug.py -t 10.0.0.71 -c on", shell=True)
        print state
