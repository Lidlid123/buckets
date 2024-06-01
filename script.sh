#!/bin/bash

# Update package lists (adjust for your package manager)
sudo apt update -y

# Install dependencies securely using trusted repositories
sudo apt install -y  python3 python3-pip

sudo apt install git -y 
sudo apt install python3-setuptools -y

# Install Flask using pip3
pip3 install Flask

git clone https://github.com/Lidlid123/terraform.git --branch loadbalancer

nohup sudo -E python3 app.py 2>&1 >/dev/null &


