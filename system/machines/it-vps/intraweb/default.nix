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

  iw.networking.namespaces."intraweb".ipAddress = "10.72.0.1/24";

  systemd.services.bird = {
    requires = [ "netns-intraweb.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };

  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.72.0.1;
      define OWNNET = 10.72.0.0/24;
      define OWNAS = 4204200001;
      router id OWNIP;

      ${config.iw.birdSharedConfig}

      protocol bgp tastypi from iwpeers {
        neighbor 172.16.32.0 as 4204200002;
      }

      protocol bgp de_fra01 from iwpeers {
        neighbor 172.16.32.2 as 4204200001;
      }
    '';
  };
}
