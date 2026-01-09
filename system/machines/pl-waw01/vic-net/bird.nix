{ pkgs, intranet, ... }:
{
  services.bird = {
    enable = true;
    package = pkgs.bird2;

    config = ''
      define OWNAS = 64512;
      define OWNIP = ${intranet.ips.pl-waw01};
      router id OWNIP;
      include "${intranet.birdShared}";
      protocol bgp tastypi from vnxfr {
        neighbor 172.21.123.1 as 64513;
        ipv4 { cost 32; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
