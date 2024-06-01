#!/bin/bash

# Update package lists
sudo apt update -y

# Install dependencies securely using trusted repositories
sudo apt install -y python3 python3-pip git python3-setuptools

# Install Flask using pip3
pip3 install Flask

# Clone the repository
git clone https://github.com/Lidlid123/terraform.git --branch loadbalancer

# Change directory to the cloned repository
cd terraform

# Logging setup
LOGFILE="/var/log/flask_app.log"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

log "Starting Flask app setup..."

# Change permissions for script
log "Setting executable permissions for script.sh..."
sudo chmod +x script.sh

# Start the Flask app in the background and log output
log "Starting Flask app..."
nohup python3 app.py > $LOGFILE 2>&1 &

log "Flask app started. Check the log file at $LOGFILE for details."

# Confirmation message
log "Setup completed."
