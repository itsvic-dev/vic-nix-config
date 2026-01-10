{ self, pkgs, ... }:
{
  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.0.1.1;
      define OWNNET = 10.0.1.0/24;
      define OWNAS = 4204200001;
      router id OWNIP;

      include "${toString self}/misc/intraweb/bird-shared.conf";

      protocol bgp tastypi from iwpeers {
        neighbor 172.21.32.0 as 4204200002;
      }

      protocol bgp fra01 from iwpeers {
        multihop;
        neighbor 172.21.32.2 as OWNAS;

        ipv4 {
          next hop self;
        };
      }
    '';
  };
}
