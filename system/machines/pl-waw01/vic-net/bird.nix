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

      protocol bgp isp_xfr from iwpeers {
        neighbor fe80::be24:11ff:febf:6dda%ens19 as 4266660003;
        enable extended messages on;

        ipv4 {
          extended next hop on;
          next hop self; # same iface, but unwanted behavior
        };
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
    listenAddresses = "${intranet.ips.${config.networking.hostName}}:60134";
  };

  networking.firewall.allowedTCPPorts = [
    179
    60134
  ];
}
