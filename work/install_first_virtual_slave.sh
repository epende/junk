#!/bin/sh

if [ $# -eq 0 ] ; then
    echo 'Usage:  <script> IP_address hostname ssh_key'
    exit 0
fi

#set -e

export domain="domain"
export ip=$1

# hostname only, not fqdn
export hostname=$2
export key=$3
export fqdn="${hostname}.${domain}"
export user="devuser"
echo "fqdn:  $fqdn"
echo "user:  $user"
echo "key:  $key"

# Add the user to passwordless sudoers
# sshpass -p 'devuser' ssh -o StrictHostKeyChecking=no "echo 'ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers"
echo "$ip $user@$fqdn $key"
echo "ssh -i $key ${user}@${fqdn} \"exit\""
ssh -i $key ${user}@${fqdn} "exit"

echo "scp -i $key hosts ${user}@${fqdn}:"
scp -i $key hosts ${user}@${fqdn}:
ssh -i $key ${user}@${fqdn} "sudo cp hosts /etc/hosts"
ssh -i $key ${user}@${fqdn} "sudo sed -i -- 's/xxx/'${ip}'/g' /etc/hosts"
ssh -i $key ${user}@${fqdn} "sudo sed -i -- 's/yyy/'${hostname}'/g' /etc/hosts"

scp -i $key install_puppet.sh ${user}@${ip}:
ssh -i $key ${user}@${fqdn} "sudo apt-get update && sudo ./install_puppet.sh"

scp -i $key puppet.conf ${user}@${ip}:
ssh -i $key ${user}@${fqdn} "sudo mkdir -p /etc/puppet; sudo cp puppet.conf /etc/puppet/puppet.conf"
ssh -i $key ${user}@${fqdn} "sudo sed -i -- 's/yyy/'${hostname}'/g' /etc/puppet/puppet.conf; sudo rm -rf /var/lib/puppet/ssl"

ssh puppetmaster "sudo puppet cert clean ${fqdn}"

ssh -i $key ${user}@${fqdn} "sudo puppet agent --enable; sudo puppet agent --test; sudo echo 'options kvm_intel nested=1' >> /etc/modprobe.d/qemu-system-x86.conf"
