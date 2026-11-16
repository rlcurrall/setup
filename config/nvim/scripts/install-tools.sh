#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
pins="$script_dir/tool-versions.json"
roslyn_version=$(sed -n 's/^[[:space:]]*"roslyn":[[:space:]]*"\([^"]*\)".*/\1/p' "$pins")
debugger_version=$(sed -n 's/^[[:space:]]*"netcoredbg":[[:space:]]*"\([^"]*\)".*/\1/p' "$pins")
[ -n "$roslyn_version" ] && [ -n "$debugger_version" ]
nvim_data_dir=${NVIM_TOOLS_DATA:-${XDG_DATA_HOME:-"$HOME/.local/share"}/nvim}
tools_dir="$nvim_data_dir/tools"
kind=${1:-all}
case "$kind" in roslyn|debugger|all) ;; *) echo "Usage: $0 [all|roslyn|debugger]" >&2; exit 2 ;; esac
if [ "$kind" = roslyn ] || [ "$kind" = all ]; then
  if ! dotnet tool list --tool-path "$tools_dir/roslyn" | rg -q "roslyn-language-server[[:space:]]+$roslyn_version[[:space:]]"; then
    dotnet tool update --tool-path "$tools_dir/roslyn" roslyn-language-server \
      --version "$roslyn_version" \
      --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
  fi
  printf '%s\n' "$roslyn_version" > "$tools_dir/roslyn/.version"
fi
if [ "$kind" = debugger ] || [ "$kind" = all ]; then
  case "$(uname -s):$(uname -m)" in
    Darwin:arm64) rid=osx-arm64; asset=netcoredbg-osx-arm64.zip ;;
    Linux:x86_64|Linux:amd64) rid=linux-x64; asset=netcoredbg-linux-amd64.tar.gz ;;
    Linux:aarch64|Linux:arm64) rid=linux-arm64; asset=netcoredbg-linux-arm64.tar.gz ;;
    *) echo 'No official NetCoreDbg build configured for this OS/architecture.' >&2; exit 1 ;;
  esac
  version_dir="$tools_dir/netcoredbg/$debugger_version-$rid"
  if [ ! -x "$version_dir/netcoredbg/netcoredbg" ]; then
    archive=$(mktemp -t nvim-netcoredbg.XXXXXX)
    trap 'rm -f "$archive"' EXIT HUP INT TERM
    curl --fail --location --silent --show-error \
      "https://github.com/Samsung/netcoredbg/releases/download/$debugger_version/$asset" \
      --output "$archive"
    mkdir -p "$version_dir"
    case "$asset" in
      *.zip) unzip -q -o "$archive" -d "$version_dir" ;;
      *.tar.gz) tar -xzf "$archive" -C "$version_dir" ;;
    esac
    test -f "$version_dir/netcoredbg/netcoredbg"
    chmod +x "$version_dir/netcoredbg/netcoredbg"
  fi
  printf '%s\n' "$debugger_version" > "$version_dir/netcoredbg/.version"
  ln -sfn "$debugger_version-$rid/netcoredbg" "$tools_dir/netcoredbg/current"
fi
