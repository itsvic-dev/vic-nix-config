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

  sops.secrets.akos-ipv6-pk.sopsFile = ../../secrets/tastypi.yaml;

  networking.wireguard.interfaces = {
    akos-ipv6 = {
      ips = [ "2a0e:97c0:7c5::2/48" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.akos-ipv6-pk.path;
      peers = [
        {
          publicKey = "z0FLHeJGlkRlp+e5WXJuQz2O3xSCJs74s++4dWDlZ1s=";
          allowedIPs = [ "::/0" ];
          endpoint = "45.136.137.31:999";
          persistentKeepalive = 25;
        }
      ];
    };
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
}
