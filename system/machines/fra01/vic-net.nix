{ config, ... }: {
  sops.secrets.vic-net-sk = { };

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.3/32" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = [
      ### servers
      {
        name = "tastypi";
        publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
        allowedIPs = [ "10.21.0.1/32" ];
      }
      {
        name = "it-vps";
        publicKey = "S2cSFcrvD4AzK7KuJTWpAzkYNMrdi2ojy8Owl+5VOU4=";
        allowedIPs = [ "10.21.0.2/32" ];
      }
      ### clients
      {
        name = "mbp";
        publicKey = "fyujyTR/I56g3bO79gLtwn7YgSxxq6O/Ct4NH5nRqlk=";
        allowedIPs = [ "10.21.1.1/32" ];
      }
      {
        name = "iphone";
        publicKey = "AQqR0qBXROiHro05uJBbckiCWpuBzS8lTDsJIyhMxDI=";
        allowedIPs = [ "10.21.1.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
