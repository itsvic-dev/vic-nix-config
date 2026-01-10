{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    (intranet.wgXfrFor {
      host = "pl-waw01";
      ip = "172.21.123.1/31";
      endpoint = "109.122.28.203:52900";
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
      networkConfig.Address = intranet.ips.tastypi + "/32";
    };
  };

  sops.secrets.vic-net-sk = { };
}
