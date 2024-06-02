{ config, pkgs, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };
}
