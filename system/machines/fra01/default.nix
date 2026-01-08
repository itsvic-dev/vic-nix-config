{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./vic-net.nix
    ./monitoring.nix
    ./hydra.nix
    ./ticket-bot.nix
    ./intraweb
  ];

  vic-nix = {
    server.enable = true;
    hardware.intel = true;
    software.docker = true;
  };

  networking = {
    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "37.114.50.122";
          prefixLength = 24;
        }
      ];
      ens18.ipv6.addresses = [
        {
          address = "2a0e:97c0:3e3:6a5::1";
          prefixLength = 64;
        }
      ];
    };

    defaultGateway = {
      address = "37.114.50.1";
      interface = "ens18";
    };

    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens18";
    };

    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."social.itsvic.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5254";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@itsvic.dev";
  };
}
