{ config, defaultSecretsFile, secretsPath, inputs, ... }: {
  sops.secrets = {
    vic-net-sk.sopsFile = defaultSecretsFile;
    tastypi-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/tastypi.vic.key";
      format = "binary";
    };
  };

  # trust ourselves
  security.pki.certificateFiles = [ ../../../../ca/ca-cert.pem ];

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.1/16" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = [
      ### servers
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
        inet 127.0.0.1 port 8053 allow { 127.0.0.1 };
      }
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

  services.nginx.virtualHosts."tastypi.vic" = {
    root = ./tastypi-nginx;
    forceSSL = true;
    sslCertificate = ../../../../ca/tastypi.vic/cert.pem;
    sslCertificateKey = config.sops.secrets.tastypi-vic-key.path;
  };
}
