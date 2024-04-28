{
  config,
  modulesPath,
  lib,
  ...
}:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  networking.firewall.allowedTCPPorts = [
    3000 # Nuxt dev services
    8443 # demo panel wings
  ];

  # hw scan
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f57f7bba-cd7b-4da2-b0b8-318aee2e5562";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6E6C-6102";
    fsType = "vfat";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/9bd7b992-65cc-4925-a7c6-50aa57509950"; } ];
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
