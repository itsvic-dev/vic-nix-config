{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    blueman
    git
    nix-output-monitor
    telegram-desktop
    vesktop
  ];

  imports = [
    ./hyprland.nix
    ./gtk.nix
    ./ime.nix
    ./zsh.nix
  ];
}
