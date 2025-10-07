{ pkgs, lib, defaultSecretsFile, config, inputs, ... }: {
  sops.secrets.altweb-wg-sk.sopsFile = defaultSecretsFile;

  containers.altweb = {
    autoStart = true;
    privateNetwork = true;
    localAddress = "2.0.0.1";

    bindMounts = {
      "/etc/ssh/ssh_host_ed25519_key" = {
        hostPath = "/etc/ssh/ssh_host_ed25519_key";
        isReadOnly = true;
      };
    };

    extraVeths.pi-ix = {
      localAddress = "192.168.169.2";
      hostAddress = "192.168.169.1";
    };

    config = { config, pkgs, ... }: {
      networking.useHostResolvConf = false;
      systemd.network.enable = true;
      systemd.network.networks = {
        "10-lan" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            DHCP = "no";
            Address = "20.0.0.1/16";
          };
        };
        "20-pi-ix" = {
          matchConfig.Name = "pi-ix";
          networkConfig = { DHCP = "no"; };
          addresses = [{
            Address = "192.168.169.2/32";
            Peer = "192.168.169.1/32";
          }];
          routes = [{
            Gateway = "192.168.169.1";
            Destination = "192.168.170.0/24";
            GatewayOnLink = "yes";
          }];
        };
      };

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
