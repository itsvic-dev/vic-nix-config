{ pkgs, inputs, ... }:
let
  hlPkgs = inputs.hyprland.packages.${pkgs.system};
in
hlPkgs.hyprland.override {
  wlroots-hyprland = hlPkgs.wlroots-hyprland.overrideAttrs {
    preConfigure = ''
      rm patches/nvidia-hardware-cursors.patch
    '';
  };
}
