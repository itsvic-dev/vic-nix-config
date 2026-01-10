{
  config,
  intranet,
  lib,
  ...
}:
{
  imports = [
    ./bird.nix

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

  # TEMP until we get fra01 on the network
  networking.nameservers = lib.mkForce [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
