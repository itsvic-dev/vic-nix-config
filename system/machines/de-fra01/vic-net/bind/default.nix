{
  pkgs,
  intranet,
  lib,
  ...
}:
let
  wawRDNS = import ./wawRDNS.nix;
in
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.bind = {
    enable = true;
    listenOn = [ "10.21.0.1" ];
    cacheNetworks = [ "10.0.0.0/8" ];
    forwarders = lib.mkForce [ ];
    extraOptions = ''
      recursion yes;
      dnssec-validation no;
    '';

    # LEGACY - MOVE OUT ASAP!
    zones."vic." = {
      master = true;
      file = pkgs.writeText "vic.zone" (
        builtins.replaceStrings
          [ "[IPS]" "[CNAMES]" ]
          [
            (intranet.ipsAsDNS)
            (intranet.cnamesAsDNS)
          ]
          (builtins.readFile ./vic.zone)
      );
      extraConfig = ''
        zone-statistics yes;
      '';
    };

    zones."vic.iw." = {
      master = true;
      file = pkgs.writeText "vic.iw.db" (
        builtins.replaceStrings
          [ "[CNAMES]" ]
          [
            (intranet.cnamesAsIWDNS)
          ]
          (builtins.readFile ./vic.iw.db)
      );
    };

    zones."acme.iw." = {
      master = true;
      file = ./acme.iw.db;
    };

    zones."wiki.iw." = {
      master = true;
      file = ./wiki.iw.db;
    };

    zones."search.iw." = {
      master = true;
      file = ./search.iw.db;
    };

    zones."0.21.10.in-addr.arpa." = {
      master = true;
      file = pkgs.writeText "arpa.zone" (
        builtins.replaceStrings [ "[IPS]" ] [ (intranet.ipsAsRDNS) ] (builtins.readFile ./arpa.zone)
      );
    };

    # ISP (WAW) RDNS zone, will be dynamically generated with Nix
    zones."0.32.10.in-addr.arpa." = {
      master = true;
      file = pkgs.writeText "waw-rdns.db" wawRDNS;
    };

    # intraweb zones
    zones."." = {
      master = true;
      file = "/opt/registry/root.db";
    };

    zones."iw." = {
      master = true;
      file = "/opt/registry/iw.db";
    };

    zones."10.in-addr.arpa." = {
      master = true;
      file = "/opt/registry/rdns.db";
    };
  };
}
