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
        neighbor 172.21.32.0 as 4204200002;
      }

      protocol ospf fra01-internal {
        ipv4 {
          import filter {
            if is_valid_network() && !is_self_net() then accept;
            else reject;
          };

          export filter {
            if is_valid_network() then accept;
            else reject;
          };
        };
        area 42069 {
          networks {
            OWNNET;
          };
          interface "iw-ix-fra01" {
            cost 1;
            hello 1;
            priority 100;
            authentication none;
            neighbors {
              172.21.32.2 eligible;
            };
          };
        };
      }
    '';
  };
}
