#!/usr/bin/env bash
nh os build --hostname=$2 && sudo nixos-rebuild $1 --target-host $2 --flake .
