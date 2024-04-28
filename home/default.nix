{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    blueman
    git
    nix-output-monitor
    pavucontrol
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
