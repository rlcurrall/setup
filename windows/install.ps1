. "$PsScriptRoot\helpers.ps1"

if (-not (Test-Admin))
{
    Invoke-AsAdministrator
    exit
}

# ==========================================================================
# CLI Tools
#
# This section installs command-line tools that are commonly used.
# ==========================================================================
#region cli tools
Write-Section "Installing CLI Tools"

# see: https://git-scm.com/doc
winget install Git.Git

# see: https://github.com/coreybutler/nvm-windows
winget install CoreyButler.NVMforWindows

# see: https://learn.microsoft.com/en-us/cli/azure
winget install Microsoft.AzureCLI

# see: https://docs.stripe.com/stripe-cli
winget install Stripe.StripeCLI

# see: https://www.terraform.io
winget install Hashicorp.Terraform

# see: https://jqlang.github.io/jq
winget install jqlang.jq

# see: https://github.com/eza-community/eza -- use older version to fix bug
winget install eza-community.eza -v 0.18.21

# see: https://github.com/BurntSushi/ripgrep
winget install BurntSushi.ripgrep.MSVC

# see: https://neovim.io
winget install Neovim.Neovim

# see: https://github.com/jftuga/less-Windows
winget install jftuga.less

# see: https://github.com/dandavison/delta
winget install dandavison.delta

# see: https://github.com/junegunn/fzf
winget install junegunn.fzf

# see: https://learn.microsoft.com/en-us/powershell/
winget install Microsoft.PowerShell
#endregion

# Refresh the environment so new tools are
# available in the current shell session.
Sync-Environment

# ==========================================================================
# PowerShell 7
#
# This section installs the necessary PowerShell modules for integrating with
# Git and FZF.
# ==========================================================================
#region powershell 7
Write-Section "Installing PowerShell 7 Module"

pwsh -c 'PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force'
pwsh -c 'Install-Module -Name PSFzf -Scope CurrentUser -Force'
#endregion

# ==========================================================================
# Languages
#
# This sectioe installs programming languages that are commonly.
# ==========================================================================
#region languages
Write-Section "Installing Languages"

winget install Python.Python.3.12
winget install Microsoft.DotNet.SDK.8
winget install Microsoft.DotNet.SDK.6
winget install Microsoft.DotNet.Framework.DeveloperPack_4 -v 4.6.2

nvm install 18
nvm use 18
#endregion

# ==========================================================================
# Dev Tools
#
# This section installs development tools that are commonly used.
# ==========================================================================
#region dev tools
Write-Section "Installing Development Tools"

winget install Microsoft.VisualStudioCode
winget install Microsoft.VisualStudio.2022.Professional
winget install Microsoft.VisualStudio.2022.BuildTools
winget install Docker.DockerDesktop
winget install Microsoft.Azure.StorageExplorer
winget install Postman.Postman

do
{
    if (!($WezTerm = Read-Host "`nWould you like to install the WezTerm terminal? (y/N)"))
    {
        $WezTerm = "n"
    }
} while ($WezTerm -notin @("y", "n"))

if ($WezTerm -eq "y")
{
    # see: https://wezfurlong.org/wezterm/index.html
    winget install wez.wezterm
}

do
{
    if (!($Rider = Read-Host "`nWould you like to install Rider? (y/N)"))
    {
        $Rider = "n"
    }
} while ($Rider -notin @("y", "n"))

if ($Rider -eq "y")
{
    winget install JetBrains.Rider
}

do
{
    if (!($SSMS = Read-Host "`nWould you like to install SQL Server Management Studio? (y/N)"))
    {
        $SSMS = "n"
    }
} while ($SSMS -notin @("y", "n"))

if ($SSMS -eq "y")
{
    winget install Microsoft.SQLServerManagementStudio
}
#endregion

# ==========================================================================
# Apps
#
# This section installs applications that are commonly used by developers at
# Vantaca that are not development tools.
# ==========================================================================
#region apps
Write-Section "Installing Applications"

# Azure VPN Client
winget install 9NP355QT2SQB --silent --accept-package-agreements --accept-source-agreements

winget install Microsoft.Teams
winget install Microsoft.PowerToys
#endregion

# ==========================================================================
# Lazy TUI Tools
#
# This section installs lazy TUI tools that might be useful for command-line
# users.
# ==========================================================================
#region lazy tui tools
Write-Section "Installing Lazy TUI Tools"

do
{
    if (!($LazyTui = Read-Host "`nWould you like to install lazy TUIs? (y/N)"))
    {
        $LazyTui = "n"
    }
} while ($LazyTui -notin @("y", "n"))

if ($LazyTui -eq "y")
{
    winget install JesseDuffield.lazygit
    winget install JesseDuffield.Lazydocker
}
#endregion

# ==========================================================================
# Browsers
#
# This section allows the user to install browsers they would like to use.
# ==========================================================================
#region browsers
Write-Section "Installing Browsers"

do
{
    if (!($Vivaldi = Read-Host "`nWould you like to install Vivaldi? (y/N)"))
    {
        $Vivaldi = "n"
    }
} while ($Vivaldi -notin @("y", "n"))

if ($Vivaldi -eq "y")
{
    winget install Vivaldi.Vivaldi
}

do
{
    if (!($Chrome = Read-Host "`nWould you like to install Google Chrome? (y/N)"))
    {
        $Chrome = "n"
    }
} while ($Chrome -notin @("y", "n"))

if ($Chrome -eq "y")
{
    winget install Google.Chrome
}

do
{
    if (!($Firefox = Read-Host "`nWould you like to install Mozilla Firefox? (y/N)"))
    {
        $Firefox = "n"
    }
} while ($Firefox -notin @("y", "n"))

if ($Firefox -eq "y")
{
    winget install Mozilla.Firefox
}
#endregion

# ==========================================================================
# Password Managers
#
# This section allows the user to install 1Password if they would like to use
# it as their password manager.
#
#  NOTE: LastPass does not work through winget, so it is not included here.
#
# ==========================================================================
#region password managers
Write-Section "Installing Password Managers"

do
{
    if (!($1Password = Read-Host "`nWould you like to install 1Password? (y/N)"))
    {
        $1Password = "n"
    }
} while ($1Password -notin @("y", "n"))

if ($1Password -eq "y")
{
    winget install AgileBits.1Password
    winget install AgileBits.1Password.CLI
}
#endregion

# ==========================================================================
# Screen Recording Tools
#
# This section allows the user to install screen recording tools if they would
# like to use them.
# ==========================================================================
#region screen recording tools
Write-Section "Installing Screen Recording Tools"

do
{
    if (!($Recording = Read-Host "`nWould you like to install video & recording tools? (y/N)"))
    {
        $Recording = "n"
    }
} while ($Recording -notin @("y", "n"))

if ($Recording -eq "y")
{
    winget install OBSProject.OBSStudio
    winget install VideoLAN.VLC
    winget install Gyan.FFmpeg
}
#endregion

# ==========================================================================
# Configure Tools
#
# This section configures the tools that were installed in the previous steps.
# This includes setting up Git, PowerShell, and other tools.
# ==========================================================================
#region configure tools
Write-Section "Configuring Tools"

git config --global core.editor "nvim"
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global diff.colorMoved "default"

$GitName = Read-Host "What is your name for git?"
git config --global user.name $GitName

$GitEmail = Read-Host "What is your email for git?"
git config --global user.email $GitEmail
#endregion

# ==========================================================================
# Setup NeoVim
#
# This section sets up NeoVim with the necessary configuration if the user
# chooses to use it as their editor.
# ==========================================================================
#region setup neovim
# Write-Section "Setting Up NeoVim"

# do {
#     if (!($SetupNvim = Read-Host "Would you like to setup NeoVim? (y/N)")) {
#         $SetupNvim = "n"
#     }
# } while ($SetupNvim -notin @("y", "n"))

# if ($SetupNvim -eq "y") {
#     # TODO: figure out how to automate this
# }
#endregion

# ==========================================================================
# Windows Configuration
#
# This section will configure windows registry values to sane defaults.
# ==========================================================================
#region windows configuration
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

# Link config files
$installLocation = Split-Path $PSScriptRoot -Parent
New-Item `
    -Force `
    -ItemType SymbolicLink `
    -Value "$installLocation\windows\profile.ps1" `
    -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Item `
    -Force `
    -ItemType SymbolicLink `
    -Value "$installLocation\config\wezterm" `
    -Path "$HOME\.config\wezterm"
New-Item `
    -Force `
    -ItemType `
    -Value "$installLocation\config\nvim" `
    -Path "$env:localappdata\nvim"
#endregion

