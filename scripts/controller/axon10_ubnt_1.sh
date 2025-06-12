#!/bin/bash

set -eux

# Debug to let world know "this was here"
touch ~/axon10_ubnt_1.txt

sudo apt-get update -y
sudo apt-get upgrade -y

# Enable firewall and configure ports for Unifi
echo "y" | sudo ufw enable
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3478/udp
sudo ufw allow 8080
sudo ufw allow 8443
sudo ufw allow 8843
sudo ufw allow 8880

sudo apt-get install ca-certificates -y
sudo apt-get install apt-listchanges -y
sudo apt-get install apt-transport-https -y
sudo apt-get install fail2ban -y
sudo apt-get install debconf-utils -y
sudo apt-get install haveged -y
sudo apt-get install apache2 -y

sudo systemctl enable haveged.service
sudo systemctl enable apache2.service

# Unifi - ref. https://lazyadmin.nl/home-network/unifi-cloud-controller/
# Add the repository
echo 'deb [ arch=amd64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
# Authenticate the repository
sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

# MongoDB 8.0 - ref. https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
# Add the MongoDB repository and import the public key
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
# Create the list file for Ubuntu 24.04 (noble)
echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
# Create the list file for Ubuntu 22.04 (jammy)
#echo "deb [ arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y mongodb-org
sudo systemctl enable mongod.service

sudo apt-get install unifi -y
sudo systemctl enable unifi.service
