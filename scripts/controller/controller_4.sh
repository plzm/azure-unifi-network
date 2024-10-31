#!/bin/bash

# Define the service name and timer name
SERVICE_NAME="daily_task.service"
TIMER_NAME="daily_task.timer"

# Create the service file
cat <<EOL | sudo tee /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Daily Task

[Service]
Type=oneshot
ExecStart=/path/to/your/script.sh
EOL

# Create the timer file
cat <<EOL | sudo tee /etc/systemd/system/$TIMER_NAME
[Unit]
Description=Runs daily_task.service daily

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