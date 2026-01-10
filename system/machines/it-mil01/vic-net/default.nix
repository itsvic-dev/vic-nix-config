{
  config,
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    intranet.sysctls

    (intranet.wgXfrFor {
      host = "pl-waw01";
      ip = "172.21.123.3/31";
      endpoint = "109.122.28.203:52901";
    })
    (intranet.wgXfrFor {
      host = "de-fra01";
      ip = "172.21.123.7/31";
      endpoint = "de-fra01.itsvic.dev:52901";
      listenPort = 52901;
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
