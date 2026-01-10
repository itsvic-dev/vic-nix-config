{ pkgs, intranet, ... }:
{
  services.bird = {
    enable = true;
    package = pkgs.bird2;

    config = ''
      define OWNAS = 64513;
      define OWNIP = ${intranet.ips.tastypi};
      router id OWNIP;

      include "${intranet.birdShared}";

      protocol bgp waw01 from vnxfr {
        neighbor 172.21.123.0 as 64512;
        ipv4 { cost 32; };
      }

      protocol bgp fra01 from vnxfr {
        neighbor 172.21.123.8 as 64515;
        ipv4 { cost 33; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
