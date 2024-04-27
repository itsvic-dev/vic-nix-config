{ config, pkgs, ... }:
{
  home.stateVersion = "23.11";

  imports = [
    ./hyprland.nix
    ./gtk.nix
  ];
}
