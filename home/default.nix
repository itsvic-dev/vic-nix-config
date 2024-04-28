{ config, pkgs, ... }:
{
  home.stateVersion = "23.11";
  home.packages = with pkgs; [ nix-output-monitor ];

  imports = [
    ./hyprland.nix
    ./gtk.nix
    ./ime.nix
  ];
}
