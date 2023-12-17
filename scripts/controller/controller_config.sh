set -eux

touch ~/1.txt

sudo apt update -y
sudo apt upgrade -y

touch ~/2.txt

sudo apt install fail2ban -y
sudo apt install debconf-utils -y
sudo apt install haveged -y
sudo apt install apache2 -y

touch ~/3.txt

# Unattended upgrades
sudo apt install unattended-upgrades apt-listchanges -y
# sudo debconf-get-selections | grep ^unattended-upgrades
echo "unattended-upgrades     unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections
sudo dpkg-reconfigure -plow unattended-upgrades -fnoninteractive

touch ~/4.txt

# Unifi - ref. https://lazyadmin.nl/home-network/unifi-cloud-controller/
# Add the repository
echo 'deb http://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
# Authenticate the repository
sudo wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
# MongoDB on controller (perhaps switch to external MongoDB later?)
echo "deb http://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

touch ~/5.txt

sudo apt update -y
sudo apt upgrade -y

touch ~/6.txt

sudo apt install unifi -y

touch ~/7.txt

sudo systemctl enable unifi.service
sudo systemctl enable mongodb.service
sudo systemctl enable haveged.service

touch ~/8.txt

sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3478/udp
sudo ufw allow 8080
sudo ufw allow 8443
sudo ufw allow 8843
sudo ufw allow 8880

touch ~/9.txt

# TLS Certificate
# Ensure DNS CNAME record already exists
# sudo apt install certbot python3-certbot-apache -y
sudo apt install snapd -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

touch ~/10.txt

# Request certfificate
sudo certbot --apache -d {{VM_FQDN}} -m {{CONTACT_EMAIL}} --agree-tos -n
