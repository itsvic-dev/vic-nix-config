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
    ./container-config.nix
  ];

  iw.networking.namespaces."intraweb".ipAddress = "10.0.0.1/24";

  systemd.services.bird = {
    requires = [ "netns-intraweb.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };

  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.0.0.1;
      define OWNNET = 10.0.0.0/24;
      define OWNAS = 4204200001;
      router id OWNIP;

      ${config.iw.birdSharedConfig}

      protocol bgp mil01 from iwpeers {
        multihop;
        neighbor 172.21.32.3 as OWNAS;

        ipv4 {
          next hop self;
        };
      }
    '';
  };
}
