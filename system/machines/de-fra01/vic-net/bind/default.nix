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
    extraOptions = ''
      recursion yes;
      empty-zones-enable no;

      validate-except {
        "vic";
        "akos";
        "10.in-addr.arpa";
      };
    '';

    forwarders = lib.mkForce [
      "1.1.1.1"
      "1.0.0.1"
    ];
    forward = "only";

    extraConfig = ''
      zone "akos" IN {
        type forward;
        forward only;
        forwarders { 10.42.69.2; };
      };
    '';

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

    zones."10.in-addr.arpa" = {
      master = true;
      file = pkgs.writeText "arpa.zone" (
        builtins.replaceStrings [ "[IPS]" ] [ (intranet.ipsAsRDNS) ] (builtins.readFile ./arpa.zone)
      );
    };
  };
}
