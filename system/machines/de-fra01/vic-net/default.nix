{
  config,
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    ./bind
    intranet.sysctls

    # broken!
    # (intranet.wgXfrFor {
    #   host = "pl-waw01";
    #   ip = "172.21.123.5/31";
    #   endpoint = "109.122.28.203:52902";
    # })
    (intranet.wgXfrFor {
      host = "it-mil01";
      ip = "172.21.123.6/31";
      listenPort = 52901;
    })

    (intranet.wgXfrFor {
      host = "tastypi";
      ip = "172.21.123.8/31";
      listenPort = 52902;
    })

    (intranet.wgClientNet {
      hosts = [
        "mbp"
        "iphone"
      ];
      ip = "10.21.1.6/29";
      listenPort = 51820;
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
      networkConfig.Address = intranet.ips.${config.networking.hostName} + "/32";
    };
  };

  sops.secrets.vic-net-sk = { };
}
