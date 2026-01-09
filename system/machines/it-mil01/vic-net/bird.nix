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
      define OWNAS = 64514;
      define OWNIP = ${intranet.ips.${config.networking.hostName}};
      router id OWNIP;

      include "${intranet.birdShared}";

      protocol bgp waw01 from vnxfr {
        neighbor 172.21.123.2 as 64512;
        ipv4 { cost 50; };
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
