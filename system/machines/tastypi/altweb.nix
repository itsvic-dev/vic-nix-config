{ lib, defaultSecretsFile, config, ... }: {
  sops.secrets.altweb-wg-sk.sopsFile = defaultSecretsFile;

  systemd.network = {
    enable = true;
    netdevs = {
      "20-altweb" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-altweb";
        };
      };

      "20-altweb-dummy" = {
        netdevConfig = {
          Kind = "dummy";
          Name = "br-altwebp0";
        };
      };
    };

    networks = {
      "20-altweb" = {
        matchConfig.Name = "br-altweb";
        networkConfig = {
          DHCP = "no";
          Address = "192.168.169.1/24";
        };
        linkConfig.RequiredForOnline = "no";
      };

      "20-altweb-dummy" = {
        matchConfig.Name = "br-altwebp0";
        networkConfig.Bridge = "br-altweb";
        linkConfig.RequiredForOnline = "no";
      };

      "10-eth" = {
        matchConfig.Name = "end0";
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "yes";
      };
    };
  };

  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = lib.mkForce false;

  containers.altweb = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br-altweb";
    localAddress = "192.168.169.2/24";

    extraVeths."ve-altweb-nat" = {
      localAddress = "1.1.0.1/16";
      hostBridge = "br-altweb";
    };

    config = { lib, ... }: {
      networking.useHostResolvConf = lib.mkForce false;
      system.stateVersion = "25.05";
    };
  };

  networking.wireguard.interfaces.wg-aw-pl = {
    ips = [ "192.168.170.1/24" ];
    listenPort = 51822;
    privateKeyFile = config.sops.secrets.altweb-wg-sk.path;

    peers = [{
      publicKey = "1EhjMgu5HobrdK1Vg1W28ze0REARZTcexNpQRoq30gY=";
      allowedIPs = [ "192.168.170.0/24" ];
    }];
  };

  networking.firewall.allowedUDPPorts = [ 51822 ];
}
