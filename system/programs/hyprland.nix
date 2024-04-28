{ pkgs, inputs, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.callPackage ../../packages/hyprland.nix { inherit inputs; };
  };
}
