{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ nix-output-monitor ];

  imports = [
    ./hyprland.nix
    ./gtk.nix
    ./ime.nix
    ./zsh.nix
  ];
}
