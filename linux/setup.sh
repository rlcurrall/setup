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
sudo add-apt-repository universe -y
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo add-apt-repository ppa:agornostal/ulauncher -y

# Update the package list
printf "Updating package list...\n"
sudo apt -qq update -y
sudo apt -qq upgrade -y
sudo apt -qq autoremove -y
sudo snap refresh

# ------------------------------------------------------------------------------

# Install libraries and tools
printf "Installing libraries and tools...\n"
# Development Tools
sudo apt -qq install -y \
    build-essential gcc make clang pkg-config autoconf bison
# Libraries
sudo apt -qq install -y \
    libwebkit2gtk-4.1-dev libxdo-dev libayatana-appindicator3-dev \
    libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses5-dev \
    libffi-dev libgdbm-dev libjemalloc2 libmagickwand-dev
# Utilities
sudo apt -qq install -y \
    file xclip dconf-cli uuid-runtime curl git jq unzip wget \
    fzf ripgrep bat eza plocate fd-find tldr
# Image Processing
sudo apt -qq install -y \
    libvips imagemagick mupdf mupdf-tools
# Databases
sudo apt -qq install -y \
    sqlite3 libsqlite3-0
# GNOME Shell Integration
sudo apt -qq install -y \
    chrome-gnome-shell
# Fonts
sudo apt -qq install -y \
    fonts-firacode
# X Tools
sudo apt -qq install -y \
    xdotool
# Miscellaneous
sudo apt -qq install -y \
    software-properties-common

# Setup Flatpak
printf "Setting up Flatpak...\n"
sudo apt -qq install -y flatpak gnome-software-plugin-flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ------------------------------------------------------------------------------

# Install Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

# ------------------------------------------------------------------------------

printf "\nSetting up launcher...\n\n"

ln -snf ~/.setup/config/ulauncher ~/.config/ulauncher

sudo apt -qq update -y
sudo apt -qq install -y ulauncher

mkdir -p ~/.config/autostart/
cp /usr/share/applications/ulauncher.desktop ~/.config/autostart/ulauncher.desktop
gtk-launch ulauncher.desktop >/dev/null 2>&1

# ------------------------------------------------------------------------------

printf "\nInstalling applications...\n\n"

# Install applications
sudo apt -qq install -y \
    flameshot \
    gnome-sushi \
    gnome-tweak-tool \
    dconf-editor \
    obs-studio \
    vlc \
    cheese \
    wl-clipboard

sudo snap install discord
sudo snap install pinta
sudo snap install localsend

###> Install Docker ###
# Add the official Docker repo
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -qq update -y

# Install Docker engine and standard plugins
sudo apt -qq install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# Limit log size to avoid running out of disk
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
###< Install Docker ###

###> Install lazydocker ###
cd /tmp
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
tar -xf lazydocker.tar.gz lazydocker
sudo install lazydocker /usr/local/bin
rm lazydocker.tar.gz lazydocker
cd -
###< Install lazydocker ###

###> Install lazygit ###
cd /tmp
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit
cd -
###< Install lazygit ###

###> Install WezTerm ###
ln -snf ~/.setup/config/wezterm ~/.config/wezterm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt -qq update
sudo apt -qq install wezterm -y
###< Install WezTerm ###

###> Install VSCode ###
cd /tmp
wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
sudo apt -qq install -y ./code.deb
rm code.deb
cd -
###< Install VSCode ###

###> Install Zed ###
curl https://zed.dev/install.sh | sh
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
###< Install Zed ###

###> Install Mise ###
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt -qq update
sudo apt -qq install -y mise
###< Install Mise ###

###> Install Rust ###
bash -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)" -- -y
###< Install Rust ###

###> Install .NET ###
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh
rm dotnet-install.sh
###< Install .NET ###

###> Install Azure CLI ###
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
###< Install Azure CLI ###

###> Install 1Password ###
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

sudo apt -qq update && sudo apt -qq install -y 1password 1password-cli

# Allow Custom Browsers
if [ ! -d /etc/1password ]; then
    sudo mkdir /etc/1password
fi
echo vivaldi-bin | sudo tee /etc/1password/custom_allowed_browsers
###< Install 1Password ###

###> Install Spotify ###
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt -qq update -y
sudo apt -qq install -y spotify-client
###< Install Spotify ###

###> Install Steam ###
cd /tmp
wget https://cdn.akamai.steamstatic.com/client/installer/steam.deb
sudo apt -qq install -y ./steam.deb
rm steam.deb
cd -
###< Install Steam ###

###> Install Vivaldi ###
cd /tmp
wget https://downloads.vivaldi.com/stable/vivaldi-stable_6.8.3381.55-1_amd64.deb
sudo apt -qq install -y ./vivaldi-stable_6.8.3381.55-1_amd64.deb
rm vivaldi-stable_6.8.3381.55-1_amd64.deb
cd -
###< Install Vivaldi ###

###> Install Neovim ###
sudo apt install neovim
ln -snf ~/.setup/config/nvim ~/.config/nvim
###< Install Neovim ###

###< Install btop ###
sudo apt -qq install -y btop
ln -snf ~/.setup/config/btop/btop.conf ~/.config/btop/btop.conf
###> Install btop ###

# ------------------------------------------------------------------------------

# Setup Extensions
sudo apt -qq install -y gnome-shell-extension-manager pipx
pipx install gnome-extensions-cli --system-site-packages
pipx ensurepath

gnome-extensions disable ubuntu-dock@ubuntu.com
gnome-extensions disable ding@rastersoft.com

# Install new extensions
gext install just-perfection-desktop@just-perfection
gext install blur-my-shell@aunetx
gext install undecorate@sun.wxg@gmail.com

# Compile gsettings schemas in order to be able to set them
sudo cp ~/.local/share/gnome-shell/extensions/just-perfection-desktop\@just-perfection/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml /usr/share/glib-2.0/schemas/
sudo cp ~/.local/share/gnome-shell/extensions/blur-my-shell\@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# Configure Just Perfection
gsettings set org.gnome.shell.extensions.just-perfection animation 2
gsettings set org.gnome.shell.extensions.just-perfection dash-app-running true
gsettings set org.gnome.shell.extensions.just-perfection workspace true
gsettings set org.gnome.shell.extensions.just-perfection workspace-popup false
gsettings set org.gnome.shell.extensions.just-perfection theme true
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0

# Configure Blur My Shell
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.lockscreen blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.screenshot blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.window-list blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur false
gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.overview pipeline 'pipeline_default'
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 0.6
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock static-blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock style-dash-to-dock 0

# ------------------------------------------------------------------------------

# Alt+F4 is very cumbersome
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>w']"

# Make it easy to maximize like you can fill left/right
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"

# Make it easy to resize undecorated windows
gsettings set org.gnome.desktop.wm.keybindings begin-resize "['<Super>BackSpace']"

# Configure touchpad to use fingers for secondary click
gsettings set org.gnome.desktop.peripherals.touchpad click-method "fingers"

# Use 6 fixed workspaces instead of dynamic mode
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# Use alt for pinned apps
gsettings set org.gnome.shell.keybindings switch-to-application-1 "['<Alt>1']"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "['<Alt>2']"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "['<Alt>3']"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "['<Alt>4']"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "['<Alt>5']"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "['<Alt>6']"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "['<Alt>7']"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "['<Alt>8']"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "['<Alt>9']"

# Use super for workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

# Reserve slots for custom keybindings
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

# Set ulauncher to Super+Space
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'ulauncher-toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ulauncher-toggle'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>space'

# Set flameshot (with the sh fix for starting under Wayland) on alternate print screen key
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Flameshot'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'sh -c -- "flameshot gui"'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Control>Print'

# Favorite apps for dock
apps=(
	"vivaldi-stable.desktop"
	"org.wezfurlong.wezterm.desktop"
	"code.desktop"
	"spotify.desktop"
	"steam.desktop"
	"pinta_pinta.desktop"
	"1password.desktop"
	"localsend_app.desktop"
)

# Array to hold installed favorite apps
installed_apps=()

# Directory where .desktop files are typically stored
desktop_dirs=(
	"/var/lib/flatpak/exports/share/applications"
	"/usr/share/applications"
	"/usr/local/share/applications"
	"$HOME/.local/share/applications"
)

# Check if a .desktop file exists for each app
for app in "${apps[@]}"; do
	for dir in "${desktop_dirs[@]}"; do
		if [ -f "$dir/$app" ]; then
			installed_apps+=("$app")
			break
		fi
	done
done

# Convert the array to a format suitable for gsettings
favorites_list=$(printf "'%s'," "${installed_apps[@]}")
favorites_list="[${favorites_list%,}]"

# Set the favorite apps
gsettings set org.gnome.shell favorite-apps "$favorites_list"

# Configure default apps
sudo update-alternatives --config x-terminal-emulator
sudo update-alternatives --config x-www-browser
sudo update-alternatives --config gnome-www-browser
