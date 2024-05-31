#!/bin/bash

# Update package lists (adjust for your package manager)
sudo apt update -y

# Install dependencies securely using trusted repositories
sudo apt install -y --no-install-recommends python3 python3-pip rsync

sudo apt install git -y 
# Install Flask using pip3
pip3 install Flask

git clone https://github.com/Lidlid123/terraform.git --branch website

nohup sudo -E python3 app.py 2>&1 >/dev/null &


