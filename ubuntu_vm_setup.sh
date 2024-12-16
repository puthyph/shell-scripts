#!/bin/bash

# Updating apt
sudo apt update -y

# Git installation
sudo apt install -y git-all

# Cron installation
sudo apt install -y cron

# Docker installation (https://docs.docker.com/engine/install/ubuntu/)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
