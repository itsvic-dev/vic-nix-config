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

      protocol bgp waw01 from internalpeers {
        neighbor ${intranet.peers.pl-waw01.ip} as OWNAS;
      }

      ${intranet.getAllIBGP config}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
