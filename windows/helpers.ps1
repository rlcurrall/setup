function Write-Section
{
    param (
        [string]$message
    )

    $Separator = "".PadLeft(80, "=")
    Write-Host "`n${Separator}`n${message}`n${Separator}`n" -ForegroundColor DarkYellow
}

# Reload the $env object from the registry
function Sync-Environment
{
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Test-Admin
{
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-AsAdministrator
{
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
    $newProcess.UseShellExecute = $true
    $newProcess.Verb = "runas"
    $newProcess.Arguments = "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Definition + "`""

    [System.Diagnostics.Process]::Start($newProcess)

    exit
}

function Confirm-RegistryExists
{
    param (
        [string]$path,
        [string]$name
    )

    if (Test-Path $path)
    {
        $key = Get-Item -LiteralPath $path

        if ($null -ne $key.GetValue($name, $null))
        {
            return $true
        } else
        {
            return $false
        }
    } else
    {
        return $false
    }
}

function Set-RegistryValue
{
    param (
        [string]$path,
        [string]$name,
        [string]$value
    )

    if (Confirm-RegistryExists $path $name)
    {
        Set-ItemProperty -Path $path -Name $name -Value $value
    } else
    {
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType Dword
    }
}

function Clear-RegistryValue
{
    param (
        [string]$path,
        [string]$name
    )

    if (Test-Path $path)
    {
        try
        {
            Remove-ItemProperty -Path $path -Name $name -ErrorAction Stop
        } catch
        {
            # Do nothing
        }
    }
}

