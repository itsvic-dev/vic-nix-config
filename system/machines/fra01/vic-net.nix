{ pkgs, lib, config, intranet, ... }: {
  sops.secrets.vic-net-sk = { };

  networking.wireguard.interfaces.vic-net = {
    ips = [ "${intranet.ips.fra01}/32" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = lib.mapAttrsToList (name: peer:
      peer // {
        inherit name;
        allowedIPs = [ "${intranet.ips.${name}}/32" ];
      }) (lib.removeAttrs intranet.wireguardPeers [ "fra01" ]);
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.interfaces.vic-net.allowedUDPPorts = [ 53 ]; # BIND

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

    forwarders = [ "1.1.1.1" "1.0.0.1" ];
    forward = "only";

    zones."vic" = {
      master = true;
      file = pkgs.writeText "vic.zone"
        (builtins.replaceStrings [ "[IPS]" "[CNAMES]" ] [
          (intranet.ipsAsDNS)
          (intranet.cnamesAsDNS)
        ] (builtins.readFile ./vic.zone));
      extraConfig = ''
        zone-statistics yes;
      '';
    };

    zones."21.10.in-addr.arpa" = {
      master = true;
      file = pkgs.writeText "arpa.zone"
        (builtins.replaceStrings [ "[IPS]" ] [ (intranet.ipsAsRDNS) ]
          (builtins.readFile ./arpa.zone));
    };
  };
}
