{
  inputs,
  pkgs,
  ...
}:
let
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  imports = [
    "${inputs.self}/misc/intraweb"
  ];
  iw.networking.namespaces = [ "intraweb" ];

  systemd.services."wireguard-iw-ix-mil01".requires = [ "netns-intraweb.service" ];

  networking.wireguard.useNetworkd = false;
  networking.wireguard.interfaces = {
    # interconnect to mil01
    "iw-ix-mil01" = {
      listenPort = 52901;
      privateKey = "oHLI2s/anH/OiRIdxUwbp7vSCrvpZMXXCtLD19ifam0="; # REPLACE WITH FILE PLEASE
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "${ip} -n intraweb addr add dev iw-ix-mil01 172.16.32.0/32 peer 172.16.32.1/32"
        "${ip} -n intraweb link add dev br0 type bridge" # TODO: move to separate unit
        "${ip} -n intraweb addr add dev br0 10.21.0.1/16"
        "${ip} -n intraweb link set dev br0 up"
      ];
      preShutdown = [
        "${ip} -n intraweb link del dev br0"
      ];

      peers = [
        {
          name = "mil01";
          publicKey = "lKV6lAfnneY+dt2Pz9qAeWeTm2a7qnQNo22XFxFzjgE=";
          endpoint = "it-mil01.itsvic.dev:52901";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };

  systemd.services.bird = {
    requires = [ "netns-intraweb.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };

  services.bird = {
    package = pkgs.bird2;
    enable = true;
    config = ''
      define OWNIP = 10.21.0.1;
      define OWNNET = 10.21.0.0/16;
      define OWNAS = 65001;
      router id OWNIP;

      function is_net() -> bool {
         return net ~ OWNNET;
      }

      protocol device {
         scan time 60;
      }

      protocol kernel {
        scan time 20;

        ipv4 {
          import all;
          export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIP;
            accept;
          };
        };
      }

      protocol static {
        route OWNNET reject;

        ipv4 {
          import all;
          export none;
        };
      }

      protocol bgp BACKBONE_IT_MIL01 {
        local 172.16.32.0 as OWNAS;
        neighbor 172.16.32.1 as 65002;

        ipv4 {
          import filter { if !is_net() then accept; else reject; };
          export filter { if is_net() then accept; else reject; };
        };
      }
    '';
  };
}
