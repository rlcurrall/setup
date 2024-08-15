function Main
{
	$account = "rlcurrall"
	$repo    = "setup"
	$branch  = "main"

	$dotfilesTempDir = Join-Path $env:TEMP "dotfiles"

	if (![System.IO.Directory]::Exists($dotfilesTempDir))
	{
		[System.IO.Directory]::CreateDirectory($dotfilesTempDir)
	}

	$sourceFile = Join-Path $dotfilesTempDir "dotfiles.zip"
	$dotfilesInstallDir = Join-Path $dotfilesTempDir "$repo-$branch"

	Invoke-Download "https://github.com/$account/$repo/archive/$branch.zip" $sourceFile

	if ([System.IO.Directory]::Exists($dotfilesInstallDir))
	{
		[System.IO.Directory]::Delete($dotfilesInstallDir, $true)
	}

	Invoke-Unzip $sourceFile $dotfilesTempDir

	Push-Location $dotfilesInstallDir
	& .\bootstrap.ps1
	Pop-Location

	$newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
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

Main
