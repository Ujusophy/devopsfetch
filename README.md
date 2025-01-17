# Devopsfetch 
This is a monitoring tool that retrieves and logs various system activities such as active ports, Docker containers, Nginx configurations, and user information. It also supports time-based activity queries and logging to a file with rotation.

# Installation and configuration of DevOpsFetch
1. Ensure your system has the necessary dependencies installed. These include bash, curl, and docker. 
```bash
sudo apt update
sudo apt install -y bash curl docker.io
```
2. Download and Install DevOpsFetch Script
- Save the devopsfetch.sh script to a directory where you keep executable scripts, such as /usr/local/bin. Use curl or wget to download it.
```
sudo curl -o /usr/local/bin/devopsfetch.sh https://example.com/devopsfetch.sh
```
- Replace https://example.com/devopsfetch.sh with the actual URL where the script is hosted.

3. Run the Installation Script 'install.sh'
```bash
sudo ./install.sh
```
This script performs the following actions:

- Updates the package list and installs essential dependencies (curl, vim, and logrotate).
- Copies the devopsfetch.sh script to /usr/local/bin and makes it executable.
- Creates a systemd service for devopsfetch, ensuring it starts on boot and restarts if it fails.
- Configures log rotation for devopsfetch logs to ensure they are managed effectively.
4. Verify the Installation
```bash
sudo systemctl status devopsfetch.service
```
5. Verify Log Files:
- Log files are located at /var/log/devopsfetch.log.
6. Check for Errors:
- If there are issues, you can check the logs to diagnose problems:

```bash
sudo journalctl -u devopsfetch.service
```
You have successfully installed DevOpsFetch and configured it to run as a systemd service. 

--------------------------------------------------------------------------------------------------------------------------------------------------------

# Usage Examples for Each Command-Line Flag
-  -p, --port          List active ports and services
-  -d, --docker         List Docker images and containers
-  -n, --nginx          List Nginx domains and ports
-  -u, --users          List users and their last login times
-  -t, --time           Display activities within a specified time range
-  -h, --help           Show this help message
List Active Ports and Services:
```bash
devopsfetch -p
```
For detailed information about a specific port:
```bash
devopsfetch -p <port_number>
```
List Docker Images and Containers:
```bash
devopsfetch -d
```
List Nginx Domains and Configurations:
```bash
devopsfetch -n <domain>
```
List Users and Their Details:
```bash
devopsfetch -u <username>
```
Display Activities Within a Time Range:
```bash
devopsfetch -t <date>
```
- format: YYYY-MM-DD
Show Help Message:
```bash
devopsfetch -h
```
---------------------------------------------------------------------------------------------------------------------------------------------------------

# Logging Mechanism and How to Retrieve Logs
The devopsfetch script includes a logging mechanism that logs activities and outputs to a log file located at /var/log/devopsfetch.log. This log file records each time a command is run, capturing the output of the script and any errors that occur during its execution. The log rotation is handled using the logrotate utility to ensure that the log file does not grow too large and remains manageable.The configuration file for logrotate is typically found at /etc/logrotate.d/devopsfetch.

- View the Latest Logs
```bash
tail -f /var/log/devopsfetch.log
```
- View the Entire Log File
```bash
cat /var/log/devopsfetch.log
```
- Search for Specific Entries
```bash
grep "keyword" /var/log/devopsfetch.log
```
