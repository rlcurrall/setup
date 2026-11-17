#!/bin/bash
set -euo pipefail

mac_account=$(id -un)
mac_profile=${1:-}
if [ "$#" -gt 0 ]; then
    shift
fi
if [ -z "$mac_profile" ]; then
    case "$mac_account" in
        robb) mac_profile=personal ;;
        robcurrall) mac_profile=work ;;
        *) printf 'Usage: bash mac/rebuild.sh personal|work\n' >&2; exit 1 ;;
    esac
fi
case "$mac_profile" in
    personal) expected_account=robb ;;
    work) expected_account=robcurrall ;;
    *) printf 'Unknown profile: %s (expected personal or work)\n' "$mac_profile" >&2; exit 1 ;;
esac
if [ "$mac_account" != "$expected_account" ]; then
    printf 'Profile %s requires account %s; run this script as that user.\n' "$mac_profile" "$expected_account" >&2
    exit 1
fi

mac_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build_dir=$(mktemp -d "${TMPDIR:-/tmp}/setup-rebuild.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT

# Evaluate the user-owned Git checkout before requesting root privileges.
nix --extra-experimental-features 'nix-command flakes' build \
    --out-link "$build_dir/system" \
    "$mac_dir#darwinConfigurations.$mac_profile.system" "$@"
built_system=$(readlink "$build_dir/system")

# Match darwin-rebuild switch: select the generation, then activate it.
sudo -H "$built_system/sw/bin/nix-env" \
    --profile /nix/var/nix/profiles/system --set "$built_system"
sudo -H "$built_system/sw/bin/darwin-rebuild" activate
