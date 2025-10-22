{ lib, config, inputs, ... }: {
  networking = {
    firewall.allowedTCPPorts = [ 22 80 443 ];

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "10.0.1.4";
        prefixLength = 24;
      }];
    };

    defaultGateway = {
      address = "10.0.1.254";
      interface = "ens18";
    };
  };
}
