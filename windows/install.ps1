function Main() {
    # ==========================================================================
    # CLI Tools
    #
    # This section installs command-line tools that are commonly used.
    # ==========================================================================
    #region cli tools
    printSectionMessage("Installing CLI Tools")

    # see: https://git-scm.com/doc
    winget install Git.MinGit.BusyBox

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

    # see: https://github.com/junegunn/fzf
    winget install junegunn.fzf

    # see: https://learn.microsoft.com/en-us/powershell/
    winget install Microsoft.PowerShell

    # see: https://github.com/gerardog/gsudo
    winget install gerardog.gsudo

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    #endregion

    # ==========================================================================
    # PowerShell 7
    #
    # This section installs the necessary PowerShell modules for integrating with
    # Git and FZF.
    # ==========================================================================
    #region powershell 7
    printSectionMessage("Installing PowerShell 7 Modules")

    pwsh -c 'PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force'
    pwsh -c 'Install-Module -Name PSFzf -Scope CurrentUser -Force'
    #endregion

    # ==========================================================================
    # Languages
    #
    # This section installs programming languages that are commonly.
    # ==========================================================================
    #region languages
    printSectionMessage("Installing Languages")

    winget install Python.Python.3.12
    winget install Microsoft.DotNet.SDK.8
    winget install Microsoft.DotNet.SDK.6
    winget install Microsoft.DotNet.Framework.DeveloperPack_4 -v 4.6.2

    # todo: figure out how to install Node.js through nvm without restarting the shell
    # nvm install 18
    #endregion

    # ==========================================================================
    # Dev Tools
    #
    # This section installs development tools that are commonly used.
    # ==========================================================================
    #region dev tools
    printSectionMessage("Installing Development Tools")

    winget install Microsoft.VisualStudioCode
    winget install Microsoft.VisualStudio.2022.Professional
    winget install Microsoft.VisualStudio.2022.BuildTools
    winget install Docker.DockerDesktop
    winget install Microsoft.Azure.StorageExplorer
    winget install Postman.Postman

    do {
        if (!($WezTerm = Read-Host "`nWould you like to install the WezTerm terminal? (y/N)")) {
            $WezTerm = "n"
        }
    } while ($WezTerm -notin @("y", "n"))

    if ($WezTerm -eq "y") {
        # see: https://wezfurlong.org/wezterm/index.html
        winget install wez.wezterm
    }

    do {
        if (!($Rider = Read-Host "`nWould you like to install Rider? (y/N)")) {
            $Rider = "n"
        }
    } while ($Rider -notin @("y", "n"))

    if ($Rider -eq "y") {
        winget install JetBrains.Rider
    }

    do {
        if (!($SSMS = Read-Host "`nWould you like to install SQL Server Management Studio? (y/N)")) {
            $SSMS = "n"
        }
    } while ($SSMS -notin @("y", "n"))

    if ($SSMS -eq "y") {
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
    printSectionMessage("Installing Applications")

    winget install 9NP355QT2SQB # Azure VPN Client
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
    do {
        if (!($LazyTui = Read-Host "`nWould you like to install lazy TUIs? (y/N)")) {
            $LazyTui = "n"
        }
    } while ($LazyTui -notin @("y", "n"))

    if ($LazyTui -eq "y") {
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
    printSectionMessage("Installing Browsers")

    do {
        if (!($Vivaldi = Read-Host "`nWould you like to install Vivaldi? (y/N)")) {
            $Vivaldi = "n"
        }
    } while ($Vivaldi -notin @("y", "n"))

    if ($Vivaldi -eq "y") {
        winget install Vivaldi.Vivaldi
    }

    do {
        if (!($Chrome = Read-Host "`nWould you like to install Google Chrome? (y/N)")) {
            $Chrome = "n"
        }
    } while ($Chrome -notin @("y", "n"))

    if ($Chrome -eq "y") {
        winget install Google.Chrome
    }

    do {
        if (!($Firefox = Read-Host "`nWould you like to install Mozilla Firefox? (y/N)")) {
            $Firefox = "n"
        }
    } while ($Firefox -notin @("y", "n"))

    if ($Firefox -eq "y") {
        winget install Mozilla.Firefox
    }
    #endregion

    # ==========================================================================
    # Password Managers
    #
    # This section allows the user to install 1Password if they would like to use
    # it as their password manager.
    #
    # NOTE: LastPass does not work through winget, so it is not included here.
    # ==========================================================================
    #region password managers
    printSectionMessage("Installing Password Managers")

    do {
        if (!($1Password = Read-Host "`nWould you like to install 1Password? (y/N)")) {
            $1Password = "n"
        }
    } while ($1Password -notin @("y", "n"))

    if ($1Password -eq "y") {
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
    printSectionMessage("Installing Screen Recording Tools")

    do {
        if (!($Recording = Read-Host "`nWould you like to install recording tools? (y/N)")) {
            $Recording = "n"
        }
    } while ($Recording -notin @("y", "n"))

    if ($Recording -eq "y") {
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
    printSectionMessage("Configuring Tools")

    git config --global core.editor "nvim"
    git config --global core.pager "less"

    $GitName = Read-Host "What is your name for git?"
    git config --global user.name $GitName

    $GitEmail = Read-Host "What is your email for git?"
    git config --global user.email $GitEmail

    # Set sslcainfo configuration so cloning over HTTPS resolves correctly
    git config --global http.sslcainfo "$env:localappdata\Microsoft\WinGet\Packages\Git.MinGit.BusyBox_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\etc\ssl\certs\ca-bundle.crt"

    do {
        if (!($UseHomeDir = Read-Host "`nWould you like to use your home directory for your PowerShell profile? (y/N)")) {
            $UseHomeDir = "n"
        }
    } while ($UseHomeDir -notin @("y", "n"))

    if ($UseHomeDir -eq "y") {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value "$HOME\Documents"
    }
    #endregion

    # ==========================================================================
    # Setup NeoVim
    #
    # This section sets up NeoVim with the necessary configuration if the user
    # chooses to use it as their editor.
    # ==========================================================================
    #region setup neovim
    # printSectionMessage("Setting Up NeoVim")

    # todo: this is not working yet, requires manual installation of the C++ build
    # tools through Visual Studio Installer. Need to figure out how to automate.

    # do {
    #     if (!($SetupNvim = Read-Host "Would you like to setup NeoVim? (y/N)")) {
    #         $SetupNvim = "n"
    #     }
    # } while ($SetupNvim -notin @("y", "n"))

    # if ($SetupNvim -eq "y") {
    #     Read-Host "Installing dependencies for NeoVim.`nBe sure select the option to add LLVM to your PATH when prompted.`n`nPress Enter to continue."
    #     winget install llvm.llvm -i
    #     winget install Kitware.CMake
    #     winget install ezwinports.make

    #     # Reload path to get access to new tools
    #     $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    #     git clone https://github.com/nvim-lua/kickstart.nvim.git $env:LOCALAPPDATA\nvim\
    # }
    #endregion
}

function printSectionMessage($message) {
    $Separator = "".PadLeft(80, "=")
    Write-Host "`n${Separator}`n${message}`n${Separator}`n" -ForegroundColor DarkYellow
}

Main
