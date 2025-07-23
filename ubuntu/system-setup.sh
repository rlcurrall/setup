#!/bin/bash

# System-level packages and configurations for Ubuntu setup

set -eux

printf "\nSetting up system packages...\n\n"

# Configure repositories
sudo add-apt-repository universe -y

# Update packages
printf "Updating package list...\n"
sudo apt -qq update -y
sudo apt -qq upgrade -y
sudo apt -qq autoremove -y

# Install system libraries
printf "Installing system libraries and development tools...\n"
sudo apt -qq install -y \
    build-essential gcc make clang pkg-config autoconf bison \
    libwebkit2gtk-4.1-dev libxdo-dev libayatana-appindicator3-dev \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses5-dev \
    libffi-dev libgdbm-dev libjemalloc2 libmagickwand-dev \
    dconf-cli uuid-runtime \
    libvips mupdf mupdf-tools \
    sqlite3 libsqlite3-0 \
    xdotool \
    software-properties-common \
    wl-clipboard

# Setup Flatpak
printf "Setting up Flatpak...\n"
sudo apt -qq install -y flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Docker
printf "Installing Docker...\n"
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -qq update -y
sudo apt -qq install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
sudo usermod -aG docker ${USER}
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

printf "\nSystem setup complete! Now run 'home-manager switch --flake .#robb' to apply Nix configuration.\n"
