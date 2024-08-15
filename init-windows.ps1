<#
.SYNOPSIS
    This script downloads, extracts, and sets up a repository from GitHub into the user's home directory.

.DESCRIPTION
    The script performs the following steps:
    1. Checks if the script is being run with administrative privileges.
    2. Downloads a specified repository from GitHub as a zip file.
    3. Extracts the contents of the zip file to a temporary directory.
    4. Copies the extracted contents to the `~/.setup` directory.
    5. Runs an installation script located in the `windows` subdirectory of the extracted contents.
    6. Starts a new PowerShell session with no logo.

.PARAMETER None
    This script does not accept any parameters.

.EXAMPLE
    .\setup.ps1
    Runs the script to download, extract, and set up the repository.

.NOTES
    Author: Robb Currall
    Date: 2024-08-15
    Version: 1.0

.LINK
    https://github.com/rlcurrall/setup
#>

$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin)
{
	Write-Error "Please run this as an admin"
	exit
}

$account = "rlcurrall"
$repo    = "setup"
$branch  = "main"
$downloadUrl = "https://github.com/$account/$repo/archive/$branch.zip"

$setupDir = Join-Path $HOME ".setup"
$downloadsDir = Join-Path $HOME "Downloads"
$sourceFile = Join-Path $downloadsDir "setup.zip"
$extractDir = Join-Path $downloadsDir "$repo-$branch"

if (![System.IO.Directory]::Exists($setupDir))
{
	[System.IO.Directory]::CreateDirectory($setupDir)
}

# Download zip of repository
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $downloadUrl -OutFile $sourceFile

# Unzip the repository
$filePath = Resolve-Path $sourceFile
$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($downloadsDir)

If (($PSVersionTable.PSVersion.Major -ge 3) -and
	(
		[version](Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -ge [version]"4.5" -or
		[version](Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -ge [version]"4.5"
	))
{
	try
	{
		[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$filePath", "$destinationPath")
	} catch
	{
		Write-Error -Message "Unexpected Error. Error details: $_.Exception.Message"
		exit
	}
} else
{
	try
	{
		$shell = New-Object -ComObject Shell.Application
		$shell.Namespace($destinationPath).copyhere(($shell.NameSpace($filePath)).items())
	} catch
	{
		Write-Error -Message "Unexpected Error. Error details: $_.Exception.Message"
		exit
	}
}

# Copy files to the `~/.setup` folder
Push-Location $extractDir
Copy-Item * -Destination $setupDir -Recurse -Force
Pop-Location

# Run install script
Push-Location $setupDir
& .\windows\install.ps1
Pop-Location

$newProcess = New-Object System.Diagnostics.ProcessStartInfo "pwsh";
$newProcess.Arguments = "-nologo";

[System.Diagnostics.Process]::Start($newProcess);

exit
