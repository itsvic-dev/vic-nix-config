{ config, ... }: {
  sops.secrets.vic-net-sk = { };

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.3/32" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = [
      {
        endpoint = "home.itsvic.dev:51820";
        publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
        allowedIPs = [ "10.21.0.0/16" ];
      }
      {
        name = "it-vps";
        publicKey = "S2cSFcrvD4AzK7KuJTWpAzkYNMrdi2ojy8Owl+5VOU4=";
        allowedIPs = [ "10.21.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
