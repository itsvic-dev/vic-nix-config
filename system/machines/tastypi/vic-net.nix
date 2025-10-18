{ config, defaultSecretsFile, ... }: {
  sops.secrets.vic-net-sk.sopsFile = defaultSecretsFile;

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.1/16" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = [
      # mbp
      {
        publicKey = "fyujyTR/I56g3bO79gLtwn7YgSxxq6O/Ct4NH5nRqlk=";
        allowedIPs = [ "10.21.1.1/32" ];
      }
    ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];

    interfaces.vic-net = {
      allowedUDPPorts = [ 53 ]; # BIND
    };
  };

  services.bind = {
    enable = true;
    listenOn = [ "10.21.0.1" ];
    cacheNetworks = [ "10.21.0.0/16" ];
    ipv4Only = true;
    extraOptions = ''
      recursion yes;
    '';

    forwarders = [ "1.1.1.1" "1.0.0.1" ];
    forward = "only";

    zones."vic" = {
      master = true;
      file = ./vic.zone;
    };

    zones."21.10.in-addr.arpa" = {
      master = true;
      file = ./arpa.zone;
    };
  };
}
