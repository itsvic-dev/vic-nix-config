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
      define OWNNET = ${intranet.ips.${config.networking.hostName}}/32;
      router id OWNIP;

      include "${intranet.birdShared}";

      protocol bgp tastypi from vnxfr {
        neighbor 172.21.123.1 as OWNAS;
        ipv4 { cost 132; };
      }

      protocol bgp mil01 from vnxfr {
        neighbor 172.21.123.3 as OWNAS;
        ipv4 { cost 50; };
      }

      protocol bgp fra01 from vnxfr {
        neighbor 172.21.123.5 as OWNAS;
        ipv4 { cost 44; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
