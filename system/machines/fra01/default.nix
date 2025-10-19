{ lib, ... }: {
  imports = [ ./disko.nix ./hardware.nix ];

  vic-nix = {
    server.enable = true;
    noSecrets = true;
  };

  networking = {
    useNetworkd = true;
    networkmanager.enable = lib.mkForce false;

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "37.114.50.122";
        prefixLength = 24;
      }];
    };

    defaultGateway = {
      address = "37.114.50.1";
      interface = "ens18";
    };

    nameservers = lib.mkForce [ "1.1.1.1" "1.0.0.1" ];
  };

  users.users.root.hashedPassword =
    "$y$j9T$pa4EgdgP3jUPyu/c7Iue.1$x9as1wf3LkJKElWGhFIxBEsFXdiRBhe3aDT7GIVAl./";
}
