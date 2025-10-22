{ config, intranet, ... }: {
  sops.secrets.vic-net-sk = { };

  networking.wireguard.interfaces.vic-net = {
    ips = [ "10.21.0.3/32" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.vic-net-sk.path;
    peers = lib.mapAttrsToList (name: peer:
      peer // {
        inherit name;
        allowedIPs = [ "${intranet.ips.${name}}/32" ];
      }) (lib.removeAttrs intranet.wireguardPeers [ "fra01" ]);
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
