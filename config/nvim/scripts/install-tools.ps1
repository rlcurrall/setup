param(
    [ValidateSet('all', 'roslyn', 'debugger')]
    [string]$Kind = 'all'
)
$ErrorActionPreference = 'Stop'
$pins = Get-Content (Join-Path $PSScriptRoot 'tool-versions.json') -Raw | ConvertFrom-Json
if ($env:NVIM_TOOLS_DATA) { $dataDir = $env:NVIM_TOOLS_DATA }
elseif ($env:XDG_DATA_HOME) { $dataDir = Join-Path $env:XDG_DATA_HOME 'nvim-data' }
else { $dataDir = Join-Path $env:LOCALAPPDATA 'nvim-data' }
$toolsDir = Join-Path $dataDir 'tools'
if ($Kind -in @('roslyn', 'all')) {
    $roslynDir = Join-Path $toolsDir 'roslyn'
    $installed = & dotnet tool list --tool-path $roslynDir
    if ($LASTEXITCODE -ne 0) { throw 'Unable to query installed .NET tools.' }
    $pattern = 'roslyn-language-server\s+' + [regex]::Escape($pins.roslyn) + '\s'
    if (-not ($installed -match $pattern)) {
        & dotnet tool update --tool-path $roslynDir roslyn-language-server --version $pins.roslyn --source 'https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json'
        if ($LASTEXITCODE -ne 0) { throw 'Roslyn installation failed.' }
    }
    [IO.File]::WriteAllText((Join-Path $roslynDir '.version'), $pins.roslyn + "`n")
}
if ($Kind -in @('debugger', 'all')) {
    $arch = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    if ($arch -ne 'AMD64') { throw 'The pinned official Windows NetCoreDbg build requires x64 Windows.' }
    $versionDir = Join-Path $toolsDir ('netcoredbg\' + $pins.netcoredbg + '-win-x64')
    $exe = Join-Path $versionDir 'netcoredbg\netcoredbg.exe'
    if (-not (Test-Path $exe)) {
        $archive = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName() + '.zip')
        try {
            $url = 'https://github.com/Samsung/netcoredbg/releases/download/' + $pins.netcoredbg + '/netcoredbg-win64.zip'
            Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing
            New-Item -ItemType Directory -Path $versionDir -Force | Out-Null
            Expand-Archive -LiteralPath $archive -DestinationPath $versionDir -Force
            if (-not (Test-Path $exe)) { throw 'NetCoreDbg archive did not contain the expected executable.' }
        } finally { Remove-Item -LiteralPath $archive -Force -ErrorAction SilentlyContinue }
    }
    # Use a regular directory: Windows symlink privileges / Developer Mode are not required.
    $current = Join-Path $toolsDir 'netcoredbg\current'
    $currentStamp = Join-Path $current '.version'
    $installedVersion = if (Test-Path $currentStamp) { (Get-Content $currentStamp -Raw).Trim() } else { '' }
    if ($installedVersion -ne $pins.netcoredbg -or -not (Test-Path (Join-Path $current 'netcoredbg.exe'))) {
        $stage = Join-Path $toolsDir ('netcoredbg\current-' + [guid]::NewGuid().ToString('N'))
        Copy-Item -LiteralPath (Join-Path $versionDir 'netcoredbg') -Destination $stage -Recurse
        if (Test-Path $current) { Remove-Item -LiteralPath $current -Recurse -Force }
        Move-Item -LiteralPath $stage -Destination $current
    }
    [IO.File]::WriteAllText($currentStamp, $pins.netcoredbg + "`n")
}
