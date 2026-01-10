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

      protocol bgp waw01 from vnxfr {
        neighbor 172.21.123.0 as OWNAS;
        ipv4 { cost 32; };
      }

      protocol bgp fra01 from vnxfr {
        neighbor 172.21.123.8 as OWNAS;
        ipv4 { cost 33; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
