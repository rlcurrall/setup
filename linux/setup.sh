#!/bin/bash

# ##############################################################################
# setup.sh
#
# This script is used to setup a new Ubuntu machine with all the necessary
# software and configurations.
#
# ##############################################################################

set -eux

# ------------------------------------------------------------------------------

printf "\nSetting up your machine...\n\n"

# Configure Third Party Repositories
sudo add-apt-repository universe -y &> /dev/null
sudo add-apt-repository ppa:neovim-ppa/unstable -y &> /dev/null
sudo add-apt-repository ppa:agornostal/ulauncher -y &> /dev/null

# Update the package list
printf "Updating package list...\n"
sudo apt -qq update -y &> /dev/null
sudo apt -qq upgrade -y &> /dev/null
sudo apt -qq autoremove -y &> /dev/null
sudo snap refresh &> /dev/null

# ------------------------------------------------------------------------------

# Install libraries and tools
printf "Installing libraries and tools...\n"
# Development Tools
sudo apt -qq install -y \
    build-essential gcc make clang pkg-config autoconf bison &> /dev/null
# Libraries
sudo apt -qq install -y \
    libwebkit2gtk-4.1-dev libxdo-dev libayatana-appindicator3-dev \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses5-dev \
    libffi-dev libgdbm-dev libjemalloc2 libmagickwand-dev &> /dev/null
# Utilities
sudo apt -qq install -y \
    file xclip neovim dconf-cli uuid-runtime curl git jq unzip wget \
    fzf ripgrep bat eza plocate btop fd-find tldr &> /dev/null
# Image Processing
sudo apt -qq install -y \
    libvips imagemagick mupdf mupdf-tools &> /dev/null
# Databases
sudo apt -qq install -y \
    sqlite3 libsqlite3-0 &> /dev/null
# GNOME Shell Integration
sudo apt -qq install -y \
    chrome-gnome-shell &> /dev/null
# Fonts
sudo apt -qq install -y \
    fonts-firacode &> /dev/null
# X Tools
sudo apt -qq install -y \
    xdotool &> /dev/null
# Miscellaneous
sudo apt -qq install -y \
    software-properties-common &> /dev/null

# Setup Flatpak
printf "Setting up Flatpak...\n"
sudo apt -qq install -y flatpak gnome-software-plugin-flatpak &> /dev/null
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ------------------------------------------------------------------------------

# Setup Oh My Bash
if [[ -d $OSH ]]; then
    printf "Oh My Bash is already installed.\n"
else
    printf "Setting up Oh My Bash...\n"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended \
      &> /dev/null
fi

# ------------------------------------------------------------------------------

printf "\nSetting up launcher...\n\n"

ln -s ~/.setup/config/ulauncher ~/.config/ulauncher

sudo apt update -y
sudo apt install -y ulauncher

mkdir -p ~/.config/autostart/
cp /usr/share/applications/ulauncher.desktop ~/.config/autostart/ulauncher.desktop
gtk-launch ulauncher.desktop >/dev/null 2>&1
sleep 2 # ensure enough time for ulauncher to set defaults

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'ulauncher-toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ulauncher-toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>space'


# ------------------------------------------------------------------------------

printf "\nInstalling applications...\n\n"

# Install applications
sudo apt -qq install -y \
    alacritty \
    flameshot \
    gnome-sushi \
    gnome-tweak-tool \
    obs-studio \
    vlc \
    cheese \
    &> /dev/null

sudo snap install discord &> /dev/null4
sudo snap install pinta &> /dev/null
sudo snap install localsend &> /dev/null

# Install WezTerm
if ! command -v wezterm &> /dev/null
then
    printf "Installing WezTerm\n"
    ln -s ~/.setup/config/wezterm ~/.config/wezterm
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt -qq update
    sudo apt qq install wezterm -y &> /dev/null
fi

# Install VSCode
if ! command -v code &> /dev/null
then
    printf "Installing Visual Studio Code...\n"
    cd /tmp
    wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    sudo apt -qq install -y ./code.deb
    rm code.deb
    cd -
fi

# Install Zed
if ! command -v zed &> /dev/null
then
    printf "Installing Zed...\n"
    curl https://zed.dev/install.sh | sh
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
fi

# Install Mise Language & Runtime Manager
if ! command -v mise &> /dev/null
then
    printf "Installing Mise...\n"
    sudo install -dm 755 /etc/apt/keyrings
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt -qq update
    sudo apt -qq install -y mise &> /dev/null
fi

# Install Rust
bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y

# Install .NET
if ! command -v dotnet &> /dev/null
then
    printf "Installing .NET...\n"
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh
    rm dotnet-install.sh
fi

# Install Azure CLI
if ! command -v az &> /dev/null
then
    printf "Installing Azure CLI...\n"
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Install 1Password
if ! command -v op &> /dev/null
then
    printf "Installing 1Password...\n"

    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    # Add apt repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
    sudo tee /etc/apt/sources.list.d/1password.list

    # Add the debsig-verify policy
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    # Install 1Password & 1password-cli
    sudo apt -qq update && sudo apt -qq install -y 1password 1password-cli

    # Allow Custom Browsers
    if [ ! -d /etc/1password ]; then
        sudo mkdir /etc/1password
    fi
    echo vivaldi-bin | sudo tee /etc/1password/custom_allowed_browsers
fi

# Install Spotify
if ! command -v spotify &> /dev/null
then
    printf "Installing Spotify..."
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt -qq update -y
    sudo apt -qq install -y spotify-client
fi

# Install Steam
cd /tmp
wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb
sudo apt install -y ./steam.deb
rm steam.deb
cd -

# Configure Neovim
ln -s ~/.setup/config/nvim ~/.config/nvim

