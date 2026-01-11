{
  imports = [
    ./hardware.nix
    ./disko.nix
    ./hydra.nix
    ./monitoring.nix
    ./free-media.nix
    ./vic-net
  ];

  vic-nix = {
    server.enable = true;
  };
  services.qemuGuest.enable = true;

  services.nginx = {
    enable = true;
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

    defaultGateway = {
      address = "109.122.28.1";
      interface = "ens18";
    };
  };
}
