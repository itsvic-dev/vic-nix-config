{ lib, ... }:
{
  networking = {
    # we use static networking here
    networkmanager.enable = lib.mkForce false;

    firewall.allowedTCPPorts = [
      22
      80
    ];

    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "10.0.1.4";
          prefixLength = 24;
        }
      ];
      # ens18.ipv6.addresses = [
      #   {
      #     address = "2a05:4140:49:100:127::";
      #     prefixLength = 64;
      #   }
      # ];
    };
    defaultGateway = {
      address = "10.0.1.254";
      interface = "ens18";
    };
    # defaultGateway6 = {
    #   address = "2a05:4140:49:100::1";
    #   interface = "ens18";
    # };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
