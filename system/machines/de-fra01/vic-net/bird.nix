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
      define OWNAS = 64515;
      define OWNIP = ${intranet.ips.${config.networking.hostName}};
      router id OWNIP;
      include "${intranet.birdShared}";

      protocol bgp waw01 from vnxfr {
        neighbor 172.21.123.4 as 64512;
        ipv4 { cost 44; };
      }

      protocol bgp mil01 from vnxfr {
        neighbor 172.21.123.7 as 64514;
        ipv4 { cost 18; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
