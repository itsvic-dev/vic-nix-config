{ config, pkgs, ... }:
{
  boot = {
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };
}
