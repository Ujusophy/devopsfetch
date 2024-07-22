# Devopsfetch 
This is a monitoring tool that retrieves and logs various system activities such as active ports, Docker containers, Nginx configurations, and user information. It also supports time-based activity queries and logging to a file with rotation.

# Step-by-step guide to install and configure DevOpsFetch
1. Install Dependencies
Ensure your system has the necessary dependencies installed. These include bash, curl, and docker. 
```bash
sudo apt update
sudo apt install -y bash curl docker.io
```
3. Download and Install DevOpsFetch Script
- Save the devopsfetch.sh script to a directory where you keep executable scripts, such as /usr/local/bin. Use curl or wget to download it:
sudo curl -o /usr/local/bin/devopsfetch.sh https://example.com/devopsfetch.sh
Replace https://example.com/devopsfetch.sh with the actual URL where the script is hosted.

Make the Script Executable:

Set the executable permission for the script:

bash
Copy code
sudo chmod +x /usr/local/bin/devopsfetch.sh
3. Set Up Systemd Service
To run DevOpsFetch as a background service and ensure it starts on boot, you need to create a systemd service file.

Create Systemd Service File:

Create a new file /etc/systemd/system/devopsfetch.service with the following content:

ini
Copy code
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -p
Restart=always
User=vagrant

[Install]
WantedBy=multi-user.target
This configuration ensures that DevOpsFetch starts after the network is available and restarts automatically if it fails.

Reload Systemd and Enable Service:

After creating the service file, reload the systemd configuration and enable the service to start on boot:

bash
Copy code
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service
4. Verify the Installation
Check Service Status:

Ensure the devopsfetch service is running correctly:

bash
Copy code
sudo systemctl status devopsfetch.service
You should see an output indicating that the service is active and running.

Check for Errors:

If there are issues, you can check the logs to diagnose problems:

bash
Copy code
sudo journalctl -u devopsfetch.service
Summary
You have successfully installed DevOpsFetch and configured it to run as a systemd service. The script will now execute automatically based on the parameters you set in the service file.

If you need to update the script or change its behavior, you can edit /usr/local/bin/devopsfetch.sh and restart the service:

bash
Copy code
sudo systemctl restart devopsfetch.service
