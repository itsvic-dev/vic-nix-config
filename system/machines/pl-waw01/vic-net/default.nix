{
  config,
  intranet,
  lib,
  ...
}:
{
  imports = [ ./bird.nix ];
  # dummy device with intranet ip
  systemd.network = {
    netdevs.vn-dummy = {
      netdevConfig = {
        Name = "vn-dummy";
        Kind = "dummy";
      };
    };
    networks.vn-dummy = {
      matchConfig.Name = "vn-dummy";
      networkConfig.Address = intranet.ips.pl-waw01 + "/32";
    };
  };

  sops.secrets.vic-net-sk = { };
  networking.wireguard.interfaces = {
    "vn-xfr-tastypi" = {
      listenPort = 52900;
      privateKeyFile = config.sops.secrets.vic-net-sk.path;
      allowedIPsAsRoutes = false;
      ips = [ "172.21.123.0/31" ];

      peers = [
        {
          name = "tastypi";
          publicKey = intranet.wireguardPeers.tastypi.publicKey;
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ 52900 ];

  # TEMP until we get fra01 on the network
  networking.nameservers = lib.mkForce [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
