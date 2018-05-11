#!/bin/sh
if [ $# -eq 0 ] ; then
    echo 'Usage:  <script> [IP address] [host name (not fqdn)]'
    exit 0
fi

export ip=$1
export hostname=$2


#sed -i -- 's/yyy/${hostname}/g' *
cp /media/cdrom/em1.cfg /etc/network/interfaces.d
sed -i -- 's/xxx/'${ip}'/g' /etc/network/interfaces.d/em1.cfg
sed -i -- 's/yyy/'${hostname}'/g' /etc/network/interfaces.d/em1.cfg
cp /media/cdrom/hosts /etc/hosts
sed -i -- 's/xxx/'${ip}'/g' /etc/hosts
sed -i -- 's/yyy/'${hostname}'/g' /etc/hosts
cp /media/cdrom/resolv.conf /etc/resolv.conf
sed -i -- 's/xxx/'${ip}'/g' /etc/resolv.conf
sed -i -- 's/yyy/'${hostname}'/g' /etc/resolv.conf
cp /media/cdrom/interfaces /etc/network/interfaces
dpkg -i /media/cdrom/vlan_1.9-3ubuntu10_amd64.deb
