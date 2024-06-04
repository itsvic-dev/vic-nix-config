{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/de43a149-9439-4560-b656-270b8ecf7717";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/160B-83C7";
    fsType = "vfat";
  };
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;

  # needed by... vscode extensions??? wtf?
  nixpkgs.config.allowUnsupportedSystem = true;
}
