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
    software = {
      libvirt = true;
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
          endpoint = "70.34.254.174:999";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  environment.etc."gai.conf".text = ''
    label  ::1/128       0
    label  ::/0          1
    label  2002::/16     2
    label ::/96          3
    label ::ffff:0:0/96  4
    precedence  ::1/128       50
    precedence  ::/0          40
    precedence  2002::/16     30
    precedence ::/96          20
    precedence ::ffff:0:0/96  100
  '';

  services.wings = {
    enable = true;
    port = 8443;
  };
  sops.secrets.cf-creds.sopsFile = ../../secrets/tastypi.yaml;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@itsvic.dev";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cf-creds.path;
    };
    certs."wings.itsvic.dev".postRun = ''
      systemctl restart wings
    '';
  };
  systemd.services.wings.requires = [ "acme-finished-wings.itsvic.dev.target" ];

  services.nginx.enable = true;
  services.bob-website = {
    enable = true;
    domain = "bob.itsvic.dev";
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.vncpy = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://static1.e621.net/data/sample/fa/f2/faf2cbcd6aa88473391af7b145a79690.jpg";
      hash = "sha256-80c4ycrJIkdb18BeklOopwunWmFTAGSeEcW6GJegNkU=";
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

  fileSystems."/boot/firmware" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];
  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = "ondemand";
}
