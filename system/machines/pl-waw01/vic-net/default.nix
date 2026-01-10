{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    intranet.sysctls

    (intranet.wgXfrFor {
      host = "tastypi";
      ip = "172.21.123.0/31";
      listenPort = 52900;
    })
    (intranet.wgXfrFor {
      host = "it-mil01";
      ip = "172.21.123.2/31";
      listenPort = 52901;
    })
    (intranet.wgXfrFor {
      host = "de-fra01";
      ip = "172.21.123.4/31";
      listenPort = 52902;
    })
  ];

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
}
