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

    wireguard.interfaces.vic-net = {
      ips = [ "10.21.0.2/32" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.vic-net-sk.path;
      peers = [{
        endpoint = "fra01.itsvic.dev:51820";
        publicKey = "DGNfHXE4BWJJcDAxZRxBB5PIiCiSMFw2q7zNBQLEWBw=";
        allowedIPs = [ "10.21.0.0/16" ];
      }];
    };
  };

  sops.secrets.vic-net-sk = { };
}
