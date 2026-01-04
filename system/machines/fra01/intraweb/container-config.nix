{ lib, ... }:
{
  system.stateVersion = "25.11";

  networking = {
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 ];
    };
    useHostResolvConf = lib.mkForce false;
  };

  services.bind = {
    enable = true;
    listenOn = [ "10.0.0.1" ];
    cacheNetworks = [ "10.0.0.0/8" ];
    ipv4Only = true;
    forward = "only";

    extraOptions = ''
      recursion yes;
    '';

    zones."com" = {
      master = true;
      file = ./zones/com.zone;
    };

    zones."10.in-addr.arpa" = {
      master = true;
      file = ./zones/arpa.zone;
    };

    zones."." = {
      master = true;
      file = ./zones/root.zone;
    };
  };

  services.openntpd = {
    enable = true;
    servers = lib.mkForce [
      "10.100.0.1"
    ];
    extraConfig = ''
      listen on 10.100.0.2
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    virtualHosts = {
      "intraweb.com" = {
        root = ./www/intraweb.com;
      };
    };
  };
}
