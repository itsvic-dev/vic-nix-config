{ config, secretsPath, inputs, ... }: {
  sops.secrets = {
    vic-net-sk = { };
    tastypi-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/tastypi.vic.key";
      format = "binary";
    };
  };

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.1/16" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = [{
      endpoint = "37.114.50.122:51820";
      publicKey = "DGNfHXE4BWJJcDAxZRxBB5PIiCiSMFw2q7zNBQLEWBw=";
      allowedIPs = [ "10.21.0.0/16" ];
    }];
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];

    interfaces.vic-net = {
      allowedUDPPorts = [ 53 ]; # BIND
    };
  };

  networking.nameservers = [ "10.21.0.1" ];

  services.bind = {
    enable = true;
    listenOn = [ "10.21.0.1" ];
    cacheNetworks = [ "10.21.0.0/16" ];
    ipv4Only = true;
    extraOptions = ''
      recursion yes;
    '';
    extraConfig = ''
      statistics-channels {
        inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
      };
    '';

    forwarders = [ "1.1.1.1" "1.0.0.1" ];
    forward = "only";

    zones."vic" = {
      master = true;
      file = ./vic.zone;
      extraConfig = ''
        zone-statistics yes;
      '';
    };

    zones."21.10.in-addr.arpa" = {
      master = true;
      file = ./arpa.zone;
    };
  };

  services.nginx.virtualHosts."tastypi.vic" = {
    root = ./tastypi-nginx;
    forceSSL = true;
    sslCertificate = ../../../../ca/tastypi.vic/cert.pem;
    sslCertificateKey = config.sops.secrets.tastypi-vic-key.path;
  };
}
