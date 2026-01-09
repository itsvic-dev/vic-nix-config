{ intranet, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
    intranet.wireguardConfig
  ];

  vic-nix = {
    server.enable = true;
  };

  networking = {
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
