{
  pkgs,
  intranet,
  lib,
  ...
}:
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
      file = ./vic.iw.db;
    };

    # TODO: generate from intraweb-registry and move ours to 0.21.10.in-addr.arpa.
    zones."10.in-addr.arpa." = {
      master = true;
      file = pkgs.writeText "arpa.zone" (
        builtins.replaceStrings [ "[IPS]" ] [ (intranet.ipsAsRDNS) ] (builtins.readFile ./arpa.zone)
      );
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
  };
}
