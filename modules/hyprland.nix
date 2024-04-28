{ pkgs, inputs, ... }:
let
  hlPkgs = inputs.hyprland.packages.${pkgs.system};
  package = hlPkgs.hyprland.override {
    wlroots-hyprland = hlPkgs.wlroots-hyprland.overrideAttrs {
      preConfigure = ''
        rm patches/nvidia-hardware-cursors.patch
      '';
    };
  };
in
{
  programs.hyprland.package = package;
}
