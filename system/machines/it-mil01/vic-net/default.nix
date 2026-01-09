{
  config,
  intranet,
  lib,
  ...
}:
{
  imports = [ ./bird.nix ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
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
      networkConfig.Address = intranet.ips.${config.networking.hostName} + "/32";
    };
  };

  sops.secrets.vic-net-sk = { };
  networking.wireguard.interfaces = {
    "vn-xfr-pl-waw01" = {
      listenPort = 52900;
      privateKeyFile = config.sops.secrets.vic-net-sk.path;
      allowedIPsAsRoutes = false;
      ips = [ "172.21.123.3/31" ];

      peers = [
        {
          name = "pl-waw01";
          publicKey = intranet.wireguardPeers.pl-waw01.publicKey;
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "109.122.28.203:52901";
        }
      ];
    };
  };

  # TEMP until we get fra01 on the network
  networking.nameservers = lib.mkForce [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
