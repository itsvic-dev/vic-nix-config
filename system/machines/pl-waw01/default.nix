{
  imports = [
    ./hardware.nix
    ./disko.nix
    ./hydra.nix
    ./monitoring.nix
    ./free-media.nix
    ./vic-net
    ./forgejo-runner.nix
  ];

  vic-nix = {
    server.enable = true;
  };
  services.qemuGuest.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
  };

  networking = {
    firewall.allowedTCPPorts = [
      80
      443
    ];

    interfaces.ens18.ipv4.addresses = [
      {
        address = "109.122.28.203";
        prefixLength = 24;
      }
    ];

    interfaces.ens20.ipv4.addresses = [
      {
        address = "192.168.254.1";
        prefixLength = 30;
      }
    ];

    defaultGateway = {
      address = "109.122.28.1";
      interface = "ens18";
    };
  };

  security.acme.defaults.email = "contact@itsvic.dev";
  security.acme.acceptTerms = true;
  networking.firewall.logRefusedConnections = false;
}
