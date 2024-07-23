#!/bin/bash

echo "Updating package list and installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl vim logrotate
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch.sh
sudo chmod +x /usr/local/bin/devopsfetch.sh

echo "Creating systemd service file..."
sudo tee /etc/systemd/system/devopsfetch.service <<EOF
[Unit]
Description=DevOpsFetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -p
Restart=always
RestartSec=10
StandardOutput=append:/var/log/devopsfetch.log
StandardError=append:/var/log/devopsfetch.log

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd and enabling the service..."
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

echo "Creating logrotate configuration for devopsfetch.log..."
sudo tee /etc/logrotate.d/devopsfetch <<EOF
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl reload devopsfetch.service > /dev/null 2>/dev/null || true
    endscript
}
EOF

echo "Installation complete."
