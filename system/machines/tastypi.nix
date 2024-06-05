{
  config,
  lib,
  pkgs,
  ...
}:
{
  vic-nix = {
    server = {
      enable = true;
    };
    hardware.bluetooth = true;
  };

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = "ondemand";
}
