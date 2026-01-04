{ lib, ... }:
{
  system.stateVersion = "25.11";
  imports = [ ./nginx.nix ];

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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
