{ lib, ... }: {
  imports = [ ./disko.nix ./hardware.nix ./vic-net.nix ./monitoring.nix ];

  vic-nix = {
    server.enable = true;
    hardware.intel = true;
  };

  networking = {
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
  };

  users.users.nixremote = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Y1OlIZoZwu7XhxwD7O+R6ua99raUdZi+Ftqr00//X root@tastypi"
    ];
    group = "nixremote";
  };
  users.groups.nixremote = { };

  nix.settings.trusted-users = [ "nixremote" ];
}
