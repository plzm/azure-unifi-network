#!/bin/bash

# Debug to let world know "this was here"
touch ~/axon10_ubnt_2.txt

# TLS Certificate
# Ensure DNS CNAME record already exists
# sudo apt install certbot python3-certbot-apache -y
sudo apt-get install snapd -y
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

# Request certfificate
sudo certbot --apache -d {{VM_FQDN}} -m {{CONTACT_EMAIL}} --agree-tos -n
