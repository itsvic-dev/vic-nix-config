{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    "${inputs.self}/misc/intraweb"
    ./wg.nix
  ];
  iw.networking.namespaces."intraweb".ipAddress = "10.0.0.1/16";

  systemd.services.frr = {
    requires = [ "netns-intraweb.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };

  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.0.0.1;
      define OWNNET = 10.0.0.0/16;
      define OWNAS = 4204200001;
      router id OWNIP;

      ${config.iw.birdSharedConfig}

      protocol bgp it_mil01 from iwpeers {
        neighbor 172.16.32.3 as 4204200001;
      }
    '';
  };
}
