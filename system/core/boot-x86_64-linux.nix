{ config, pkgs, ... }:
{
  boot = {
    loader.efi.canTouchEfiVariables = config.vic-nix.hardware.hasEFI;
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };
}
