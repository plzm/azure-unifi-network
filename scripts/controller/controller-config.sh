sudo apt update -y
sudo apt upgrade -y

sudo apt install fail2ban -y
sudo apt install debconf-utils -y
sudo apt install haveged -y
sudo apt install apache2 -y

# Unattended upgrades
sudo apt install unattended-upgrades apt-listchanges -y
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

sudo apt update -y
sudo apt upgrade -y

sudo apt install unifi -y

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

# TLS Certificate
# Ensure DNS CNAME record already exists
# sudo apt install certbot python3-certbot-apache -y
sudo apt install snapd -y
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Request certfificate
# ################### AUTOMATE FQDN ###################
sudo certbot --apache -d ui000.alfaadin.com -m support@alfaadin.com --agree-tos -n

# Install certificate
# ################### MODIFY SCRIPT AFTER DOWNLOAD - PUT CORRECT FQDN
sudo wget https://raw.githubusercontent.com/plzm/azure-unifi-network/main/scripts/controller/unifi_ssl_import.sh -O /usr/local/bin/unifi_ssl_import.sh

sudo chmod +x /usr/local/bin/unifi_ssl_import.sh
sudo /usr/local/bin/unifi_ssl_import.sh

sudo apt shutdown -r now
