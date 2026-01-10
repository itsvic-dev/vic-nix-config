{
  inputs,
  ...
}:
{
  sops.secrets.iw-wg-peer-sk = { };

  containers.intraweb = {
    specialArgs = { inherit (inputs) self; };

    config = {
      imports = [
        "${inputs.self}/misc/intraweb"
        ./wg.nix
        ./bird.nix
      ];

      systemd.network = {
        netdevs.iw-dummy = {
          netdevConfig = {
            Name = "iw-dummy";
            Kind = "dummy";
          };
        };
        networks.iw-dummy = {
          matchConfig.Name = "iw-dummy";
          networkConfig.Address = "10.0.1.1/24";
        };
      };

      networking.useNetworkd = true;
      networking.useHostResolvConf = false;
      system.stateVersion = "26.05";
    };

    bindMounts."/run/secrets/iw-wg-peer-sk" = { };

    autoStart = true;
    privateNetwork = true;
    hostAddress = "172.32.136.1";
    localAddress = "172.32.136.2";

    forwardPorts = [
      {
        hostPort = 51900;
        protocol = "udp";
      }
      {
        hostPort = 51901;
        protocol = "udp";
      }
    ];
  };
}
