{
  networking = {
    firewall.allowedTCPPorts = [
      22
      80
      443
    ];

    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "10.0.1.4";
          prefixLength = 24;
        }
      ];

      ens20.ipv4.addresses = [
        {
          address = "5.231.80.191";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "5.231.80.254";
      interface = "ens20";
    };
  };
}
