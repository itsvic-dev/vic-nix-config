{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8e98eecd-730d-40bd-a11d-2177f0076369";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5BB0-B1D6";
    fsType = "vfat";
  };

  fileSystems."/mnt/hdd".device = "/dev/disk/by-uuid/c62aa149-e7f2-4186-8b06-476eef523124";

  swapDevices = [ { device = "/dev/disk/by-uuid/c0de789d-a3de-42da-a389-a3e9bdec61e9"; } ];
}
