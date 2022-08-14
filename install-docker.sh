#!/bin/sh

# Should run as sudo this script to install docker

ccend=$(tput sgr0)
ccbold=$(tput bold)
ccgreen=$(tput setaf 2)
ccso=$(tput smso)

# Check Ubuntu or CentOS
if [  -n "$(uname -a | grep Ubuntu)" ]; then
  # open network to any
  # ufw allow out from any to any proto tcp port 80 comment "Repository"
  # ufw allow out from any to any proto tcp port 443 comment "Repository"

  # Set up the Repository
  echo ""
  echo "$ccso --> Set up the Repository $ccend"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release software-properties-common

  # Add official docker GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  # Set up the stable docker Repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install docker engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


else
  # Set up the Repository
  echo ""
  echo "$ccso --> Set up the Repository $ccend"
  sudo yum install -y yum-utils

  # Set up the stable docker Repository
  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

  # Install docker engine
  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

echo ""
echo "$ccso --> Start docker $ccend"
sudo systemctl start docker

echo ""
echo "$ccso --> add group & user permission docker $ccend"
# add group & user permission docker
sudo groupadd docker
sudo usermod -aG docker $USER

sudo chmod 666 /var/run/docker.sock

newgrp docker
