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

      ${intranet.getAllIBGP config}
    '';
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
