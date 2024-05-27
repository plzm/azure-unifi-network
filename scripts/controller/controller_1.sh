#!/bin/bash

set -eux

# Debug to let world know "this was here"
touch ~/controller_1.txt

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install fail2ban -y
sudo apt-get install debconf-utils -y
sudo apt-get install haveged -y
sudo apt-get install apache2 -y

# Unattended upgrades
sudo apt-get install unattended-upgrades apt-listchanges -y
# sudo debconf-get-selections | grep ^unattended-upgrades
echo "unattended-upgrades     unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections
sudo dpkg-reconfigure -plow unattended-upgrades -fnoninteractive

# Unifi - ref. https://lazyadmin.nl/home-network/unifi-cloud-controller/
# Add the repository
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
# Authenticate the repository
sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
# MongoDB on controller (perhaps switch to external MongoDB later?)
echo "deb http://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install unifi -y

sudo systemctl enable unifi.service
sudo systemctl enable mongodb.service
sudo systemctl enable haveged.service

sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3478/udp
sudo ufw allow 8080
sudo ufw allow 8443
sudo ufw allow 8843
sudo ufw allow 8880
