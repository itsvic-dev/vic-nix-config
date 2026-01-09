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

    extraOptions = ''
      recursion yes;
    '';

    zones."iw" = {
      master = true;
      file = ./zones/iw.zone;
    };

    zones."backbone.iw" = {
      master = true;
      file = ./zones/backbone.iw.db;
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
}
