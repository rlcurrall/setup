function Main
{
	if (-not (Test-Admin))
	{
		Write-Error "Please run this as an admin"
		exit
	}

	$account = "rlcurrall"
	$repo    = "setup"
	$branch  = "main"

	$setupDir = Join-Path $HOME ".setup"
	$sourceFile = Join-Path $HOME "Downloads" "setup.zip"
	$setupInstallDir = Join-Path $setupDir "$repo-$branch"

	if (![System.IO.Directory]::Exists($setupDir))
	{
		[System.IO.Directory]::CreateDirectory($setupDir)
	}

	if ([System.IO.Directory]::Exists($setupInstallDir))
	{
		[System.IO.Directory]::Delete($setupInstallDir, $true)
	}

	Invoke-Download "https://github.com/$account/$repo/archive/$branch.zip" $sourceFile
	Invoke-Unzip $sourceFile $setupDir

	Push-Location $setupInstallDir
	& .\windows\install.ps1
	Pop-Location

	$newProcess = New-Object System.Diagnostics.ProcessStartInfo "pwsh";
	$newProcess.Arguments = "-nologo";

	[System.Diagnostics.Process]::Start($newProcess);

	exit
}

function Invoke-Download
{
	param (
		[string]$url,
		[string]$file
	)
	Write-Host "Downloading $url to $file"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri $url -OutFile $file

}

function Invoke-Unzip
{
	param (
		[string]$File,
		[string]$Destination = (Get-Location).Path
	)

	$filePath = Resolve-Path $File
	$destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

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
			Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
		}
	} else
	{
		try
		{
			$shell = New-Object -ComObject Shell.Application
			$shell.Namespace($destinationPath).copyhere(($shell.NameSpace($filePath)).items())
		} catch
		{
			Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
		}
	}
}

function Test-Admin
{
	$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Main
