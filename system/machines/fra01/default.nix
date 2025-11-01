{ lib, ... }: {
  imports =
    [ ./disko.nix ./hardware.nix ./vic-net.nix ./monitoring.nix ./hydra.nix ];

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

    firewall.allowedTCPPorts = [ 80 443 ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
}
