{ inputs, ... }:
{
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.kernelPackages = inputs.nixpkgs-old.legacyPackages.aarch64-linux.linuxPackages_rpi4;
  boot.extraModulePackages = [ ];

  # Okay.
  boot.initrd.systemd.tpm2.enable = false;

  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/6c67eb27-a188-4cd8-9540-8982eb2bfeb6";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "nofail"
      "noatime"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
}
