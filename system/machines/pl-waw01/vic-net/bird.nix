{
  config,
  pkgs,
  intranet,
  ...
}:
{
  services.bird = {
    enable = true;
    package = pkgs.bird2;

    config = ''
      define OWNIP = ${intranet.ips.${config.networking.hostName}};
      router id OWNIP;

      include "${intranet.birdShared}";

      protocol bgp akos_xfr from iwpeers {
        neighbor 192.168.255.2 as 4266660002;
      }

      ${intranet.getAllIBGP config}
    '';
  };

  systemd.network.networks."50-akos-xfr" = {
    matchConfig.Name = "ens19";
    networkConfig.Address = "192.168.255.1/30";
  };

  services.bird-lg.proxy = {
    enable = true;
    allowedIPs = [ "10.0.0.0/8" ];
    listenAddresses = "10.21.0.1:60134";
  };

  networking.firewall.allowedTCPPorts = [
    179
    60134
  ];
}
