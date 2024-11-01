#!/bin/bash

# Define the service name and timer name
SERVICE_NAME="ubnt_import_updated_certbot_cert.service"
TIMER_NAME="ubnt_import_updated_certbot_cert.timer"

# Create the service file
cat <<EOL | sudo tee /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Daily Task for UBNT to import updated certbot cert

[Service]
Type=oneshot
ExecStart=/path/to/your/script.sh
EOL

# Create the timer file
cat <<EOL | sudo tee /etc/systemd/system/$TIMER_NAME
[Unit]
Description=Runs $SERVICE_NAME daily

[Timer]
OnCalendar=*-*-* 11:00:00 UTC
Persistent=true

[Install]
WantedBy=timers.target
EOL

# Reload systemd to recognize the new service and timer
sudo systemctl daemon-reload

# Enable and start the timer
sudo systemctl enable --now $TIMER_NAME

echo "Daily systemctl task created and started successfully."