{
  pkgs,
  intranet,
  config,
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

      protocol bgp waw01 from vnxfr {
        neighbor 172.21.123.2 as OWNAS;
        ipv4 { cost 50; };
      }

      protocol bgp fra01 from vnxfr {
        neighbor 172.21.123.6 as OWNAS;
        ipv4 { cost 18; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
