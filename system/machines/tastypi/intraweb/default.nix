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

  systemd.services.frr = {
    requires = [ "netns-intraweb.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };
  services.frr = {
    bgpd.enable = true;
    config = ''
      router bgp 65001
        bgp log-neighbor-changes
        no bgp ebgp-requires-policy
        no bgp suppress-duplicates
        no bgp hard-administrative-reset
        no bgp default ipv4-unicast
        no bgp graceful-restart notification
        bgp graceful-restart
        no bgp network import-check
        !
        neighbor 172.16.32.1 remote-as 65002
        neighbor 172.16.32.1 description BACKBONE-IT-MIL01
        !
        bgp fast-convergence
        !
        address-family ipv4 unicast
          network 10.21.0.0/16
          network 172.16.32.0/31
          redistribute static
          neighbor 172.16.32.1 activate
          neighbor 172.16.32.1 addpath-tx-all-paths
        exit-address-family
      exit
    '';
  };
}
