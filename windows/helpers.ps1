function Write-Section($message)
{
    $Separator = "".PadLeft(80, "=")
    Write-Host "`n${Separator}`n${message}`n${Separator}`n" -ForegroundColor DarkYellow
}

# Reload the $env object from the registry
function Refresh-Environment
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

function Check-Registry($path, $name)
{
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

function Set-Registry-Value($path, $name, $value)
{
    if (Check-Registry $path $name)
    {
        Set-ItemProperty -Path $path -Name $name -Value $value
    } else
    {
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType Dword
    }
}

