#!/bin/bash

set -e

echo "Updating package list and installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl vim logrotate

if [[ -f "devopsfetch.sh" ]]; then
    echo "Copying devopsfetch.sh to /usr/local/bin..."
    sudo cp devopsfetch.sh /usr/local/bin/devopsfetch.sh
    sudo chmod +x /usr/local/bin/devopsfetch.sh
else
    echo "Error: devopsfetch.sh not found. Exiting."
    exit 1
fi

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
        # Restarting service only if necessary
        if systemctl is-active --quiet devopsfetch.service; then
            systemctl reload devopsfetch.service > /dev/null 2>/dev/null || true
        fi
    endscript
}
EOF

echo "Installation complete."
