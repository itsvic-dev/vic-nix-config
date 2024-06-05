{
  config,
  modulesPath,
  lib,
  ...
}:
{
  imports = [ ../extras/ptero.nix ];

  vic-nix = {
    desktop = {
      enable = true;
      forGaming = true;
      forDev = true;
    };
    hardware = {
      intel = true;
      nvidia = true;
      bluetooth = true;
    };
  };

  services.wings = {
    enable = true;
    openFirewall = false;
  };

  services.ollama.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  nix.buildMachines = [
    {
      hostName = "tastypi";
      system = "aarch64-linux";
      protocol = "ssh-ng";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  # optional, useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  networking.firewall.allowedTCPPorts = [
    3000 # nuxt dev projects
  ];

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

  powerManagement.cpuFreqGovernor = "powersave";
}
