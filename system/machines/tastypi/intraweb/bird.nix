{ self, pkgs, ... }:
{
  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.21.0.1;
      define OWNNET = 10.21.0.0/24;
      define OWNAS = 4204200002;
      router id OWNIP;

      include "${toString self}/misc/intraweb/bird-shared.conf";

      protocol bgp it_mil01 from iwpeers {
        neighbor 172.21.32.1 as 4204200001;
      }
    '';
  };
}
