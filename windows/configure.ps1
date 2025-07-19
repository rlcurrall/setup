. "$PsScriptRoot\helpers.ps1"

if (-not (Test-Admin))
{
    Write-Error "This script must be run as an administrator"
    exit
}

# ==========================================================================
# Install Packages via WinGet Configure
#
# This section uses winget configure to declaratively install all packages
# ==========================================================================
Write-Section "Installing Packages via WinGet Configure"

$configFile = Join-Path $PSScriptRoot "configuration.dsc.yaml"
winget configure -f $configFile --accept-configuration-agreements

# Refresh the environment so new tools are available in the current shell session
Sync-Environment

# ==========================================================================
# PowerShell 7 Modules
#
# This section installs the necessary PowerShell modules for integrating with
# Git and FZF.
# ==========================================================================
Write-Section "Installing PowerShell 7 Modules"

pwsh -c 'PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force'
pwsh -c 'Install-Module -Name PSFzf -Scope CurrentUser -Force'

# ==========================================================================
# Node.js Setup
#
# This section sets up Node.js using NVM
# ==========================================================================
Write-Section "Setting Up Node.js"

nvm install 18
nvm use 18

# ==========================================================================
# Configure Tools
#
# This section configures the tools that were installed in the previous steps.
# This includes setting up Git, PowerShell, and other tools.
# ==========================================================================
Write-Section "Configuring Tools"

git config --global core.editor "nvim"

$GitName = Read-Host "What is your name for git?"
git config --global user.name $GitName

$GitEmail = Read-Host "What is your email for git?"
git config --global user.email $GitEmail

# ==========================================================================
# Windows Configuration
#
# This section will configure windows registry values to sane defaults.
# ==========================================================================
Write-Section "Configuring Windows Settings"

$base = "HKCU:\Software\Microsoft\Windows\CurrentVersion\"

# Declutter the taskbar
Set-RegistryValue ($base + "Explorer\Advanced")   "TaskbarAl"            "0"
Set-RegistryValue ($base + "Explorer\Advanced")   "TaskbarDa"            "0"
Set-RegistryValue ($base + "Explorer\Advanced")   "TaskbarMn"            "0"
Set-RegistryValue ($base + "Explorer\Advanced")   "TaskbarSd"            "1"
Set-RegistryValue ($base + "Explorer\Advanced")   "ShowCopilotButton"    "0"
Set-RegistryValue ($base + "Explorer\Advanced")   "ShowTaskViewButton"   "0"
Set-RegistryValue ($base + "Search")              "SearchboxTaskbarMode" "0"
Clear-RegistryValue ($base + "Explorer\Taskband") "Favorites"
Clear-RegistryValue ($base + "Explorer\Taskband") "FavoritesResolve"

# Declutter the Start Menu
Set-RegistryValue ($base + "Explorer\Advanced") "Start_AccountNotifications" "0"
Set-RegistryValue ($base + "Explorer\Advanced") "Start_IrisRecommendations"  "0"
Set-RegistryValue ($base + "Explorer\Advanced") "Start_Layout"               "1"
Set-RegistryValue ($base + "Start")             "ShowFrequentList"           "0"
Set-RegistryValue ($base + "Start")             "ShowRecentList"             "0"

# Set Personal User Shell Folder to Documents folder
Set-RegistryValue ($base + "Explorer\User Shell Folders") "Personal" "$HOME\Documents"

# Set theme
Set-RegistryValue ($base + "Themes") "CurrentTheme" "C:\Windows\resources\Themes\themeB.theme"

# Clean up desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcuts = Get-ChildItem -Path $desktopPath -Filter "*.lnk"
foreach ($shortcut in $shortcuts)
{
    Remove-Item -Path $shortcut.FullName -Force
}

# ==========================================================================
# Link Configuration Files
#
# This section creates symbolic links to configuration files
# ==========================================================================
Write-Section "Linking Configuration Files"

$installLocation = Split-Path $PSScriptRoot -Parent

# PowerShell profile
$profileDir = "$HOME\Documents\PowerShell"
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}
New-Item `
    -Force `
    -ItemType SymbolicLink `
    -Value "$installLocation\windows\profile.ps1" `
    -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# Neovim config
$nvimConfigDir = "$env:localappdata\nvim"
if (Test-Path $nvimConfigDir) {
    Remove-Item -Path $nvimConfigDir -Recurse -Force
}
New-Item `
    -Force `
    -ItemType SymbolicLink `
    -Value "$installLocation\config\nvim" `
    -Path "$env:localappdata\nvim"

Write-Host "`n" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "All packages have been installed and configured." -ForegroundColor Green
Write-Host "Please restart your terminal to ensure all changes take effect." -ForegroundColor Green