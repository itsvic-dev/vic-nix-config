{ lib, ... }: {
  networking = {
    # we use static networking here
    networkmanager.enable = lib.mkForce false;

    firewall.allowedTCPPorts = [ 22 80 443 ];

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "10.0.1.4";
        prefixLength = 24;
      }];
      ens19.ipv4.addresses = [{
        address = "185.184.221.104";
        prefixLength = 27;
      }];
    };

    defaultGateway = {
      address = "10.0.1.254";
      interface = "ens18";
    };

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
}
