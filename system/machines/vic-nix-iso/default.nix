{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix" ];

  vic-nix = {
    desktop = {
      enable = true;
      plymouth = false;
    };
    hardware.intel = true;
  };

  boot.plymouth.enable = lib.mkForce false;

  isoImage = {
    edition = "vic-nix";
    squashfsCompression = "gzip -Xcompression-level 1";
  };
}
