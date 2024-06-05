#!/usr/bin/env bash
# nh os build --hostname=$2 && sudo nixos-rebuild $1 --target-host $2 --flake .
set -e
HOST=$2
OPERATION=$1
nom build -o /tmp/vic-nix-rebuild .\#nixosConfigurations.$HOST.config.system.build.toplevel
sudo nixos-rebuild $OPERATION --target-host $HOST --flake .
rm /tmp/vic-nix-rebuild
