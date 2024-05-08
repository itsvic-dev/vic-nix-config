{ pkgs, inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: { hyprland = pkgs.callPackage ../../packages/hyprland.nix { inherit inputs; }; })
  ];
  programs.hyprland = {
    enable = true;
  };
}
