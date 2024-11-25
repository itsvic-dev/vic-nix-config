{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader.efi.canTouchEfiVariables = config.vic-nix.hardware.hasEFI;
    kernelPackages = lib.mkDefault pkgs.linuxKernel.packages.linux_6_12;
  };
}
