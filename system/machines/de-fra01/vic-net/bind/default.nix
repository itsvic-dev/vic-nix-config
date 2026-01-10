{ pkgs, intranet, ... }:
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.bind = {
    enable = true;
    listenOn = [ "10.21.0.1" ];
    cacheNetworks = [ "10.21.0.0/16" ];
    ipv4Only = true;
    extraOptions = ''
      recursion yes;
    '';
    extraConfig = ''
      statistics-channels {
        inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
      };
    '';

    forwarders = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    forward = "only";

    zones."vic" = {
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

    zones."21.10.in-addr.arpa" = {
      master = true;
      file = pkgs.writeText "arpa.zone" (
        builtins.replaceStrings [ "[IPS]" ] [ (intranet.ipsAsRDNS) ] (builtins.readFile ./arpa.zone)
      );
    };
  };
}
