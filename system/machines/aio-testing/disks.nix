{
  fileSystems."/persist" = {
    device = "/dev/sda2";
    neededForBoot = true;
    fsType = "btrfs";
    options = [ "subvol=persist" ];
  };

  fileSystems."/nix" = {
    device = "/dev/sda2";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };
}
