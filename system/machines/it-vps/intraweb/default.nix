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

  networking.firewall.allowedUDPPorts = [
    52901
    52902
  ];

  systemd.services."wireguard-iw-ix-tastypi".requires = [ "netns-intraweb.service" ];

  networking.wireguard.useNetworkd = false;
  networking.wireguard.interfaces = {
    # interconnect to tastypi
    "iw-ix-tastypi" = {
      listenPort = 52901;
      privateKey = "SEKyTmkasXfyQzOlBgDDx4XbLqWlmgW1QYbPZcp8sHw="; # REPLACE WITH FILE PLEASE
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "${ip} -n intraweb addr add dev iw-ix-tastypi 172.16.32.1/32 peer 172.16.32.0/32"
        "${ip} -n intraweb link add dev br0 type bridge" # TODO: move to separate unit
        "${ip} -n intraweb addr add dev br0 10.72.0.1/16"
        "${ip} -n intraweb link set dev br0 up"
      ];
      preShutdown = [
        "${ip} -n intraweb link del dev br0"
      ];

      peers = [
        {
          name = "tastypi";
          publicKey = "nSmx0OTq6K+2QvqJ2vwoEopsqifbwdRK9lPPNEHP3gQ=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };

    # interconnect to de-fra01
    "iw-ix-fra01" = {
      listenPort = 52902;
      privateKey = "KDlpSbh9/jG1WykLMtPXaAQxWROdQCTT/VaGoKnlNEg="; # REPLACE WITH FILE PLEASE
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "${ip} -n intraweb addr add dev iw-ix-fra01 172.16.32.3/32 peer 172.16.32.2/32"
      ];

      peers = [
        {
          name = "fra01";
          publicKey = "MCtMEbgAMo6uL+Tgl4TGPYdFEADpseFJ6Q6V2rEUTC8=";
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
      ip prefix-list ANY permit 0.0.0.0/0 le 32
      route-map intraweb permit 5
        match ip address prefix-list ANY
        set src 10.72.0.1
      exit
      !
      router bgp 65002
        bgp log-neighbor-changes
        no bgp ebgp-requires-policy
        no bgp suppress-duplicates
        no bgp hard-administrative-reset
        no bgp default ipv4-unicast
        no bgp graceful-restart notification
        bgp graceful-restart
        no bgp network import-check
        !
        neighbor 172.16.32.0 remote-as 65001
        neighbor 172.16.32.0 description USER-TASTYPI
        neighbor 172.16.32.2 remote-as 65003
        neighbor 172.16.32.2 description BACKBONE-DE-FRA01
        !
        address-family ipv4 unicast
          network 10.72.0.0/16
          neighbor 172.16.32.0 activate
          neighbor 172.16.32.0 route-map intraweb in
          neighbor 172.16.32.0 route-map intraweb out
          neighbor 172.16.32.2 activate
          neighbor 172.16.32.2 route-map intraweb in
          neighbor 172.16.32.2 route-map intraweb out
        exit-address-family
      exit
    '';
  };
}
