# ==========================================================================
# Windows Development Environment Setup
#
# This script sets up a complete Windows development environment using
# winget configure for declarative package management and PowerShell for
# system configuration.
#
# Usage: Run as Administrator
# ==========================================================================

# Import helper functions
. "$PsScriptRoot\helpers.ps1"

# Check for administrator privileges
if (-not (Test-Admin))
{
    Write-Error "This script must be run as an administrator"
    exit
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Windows Development Environment Setup" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "This will install and configure your complete development environment." -ForegroundColor Green
Write-Host "All packages will be installed automatically using winget configure." -ForegroundColor Green
Write-Host ""

# Run the new configure script
& "$PSScriptRoot\configure.ps1"

