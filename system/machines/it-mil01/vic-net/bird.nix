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

  services.bird-lg.proxy = {
    enable = true;
    allowedIPs = [ "10.0.0.0/8" ];
    listenAddresses = "10.21.0.1:60134";
  };

  networking.firewall.allowedTCPPorts = [
    179
    60134
  ];
}
