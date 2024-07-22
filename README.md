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
- Save the devopsfetch.sh script to a directory where you keep executable scripts, such as /usr/local/bin. Use curl or wget to download it.
```
sudo curl -o /usr/local/bin/devopsfetch.sh https://example.com/devopsfetch.sh
```
- Replace https://script.com/devopsfetch.sh with the actual URL where the script is hosted.

4. Make the Script Executable

- Set the executable permission for the script:

``bash
sudo chmod +x /usr/local/bin/devopsfetch.sh
```
5. Set Up Systemd Service
- Create a new file /etc/systemd/system/devopsfetch.service with the following content
```bash
[Unit]
Description=DevOpsFetch Monitoring Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch.sh -p
Restart=always
User=vagrant

[Install]
WantedBy=multi-user.target
```
This configuration ensures that DevOpsFetch starts after the network is available and restarts automatically if it fails.

6. Reload Systemd and Enable Service:

- After creating the service file, reload the systemd configuration and enable the service to start on boot:

```bash
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service
```
7. Verify the Installation
- Check Service Status
```bash
sudo systemctl status devopsfetch.service
```
You should see an output indicating that the service is active and running.

8. Check for Errors:

- If there are issues, you can check the logs to diagnose problems:

```bash
sudo journalctl -u devopsfetch.service
```
You have successfully installed DevOpsFetch and configured it to run as a systemd service. 
