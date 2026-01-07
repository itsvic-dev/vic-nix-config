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

  networking.firewall.allowedUDPPorts = [ 52901 ];

  systemd.services."wireguard-iw-ix-tastypi".requires = [ "netns-intraweb.service" ];

  networking.wireguard.useNetworkd = false;
  networking.wireguard.interfaces = {
    # interconnect to tastypi
    "iw-ix-tastypi" = {
      listenPort = 52901;
      privateKey = "SEKyTmkasXfyQzOlBgDDx4XbLqWlmgW1QYbPZcp8sHw="; # REPLACE WITH FILE PLEASE
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = "${ip} -n intraweb addr add dev iw-ix-tastypi 172.16.32.1/32 peer 172.16.32.0/32";

      peers = [
        {
          name = "tastypi";
          publicKey = "nSmx0OTq6K+2QvqJ2vwoEopsqifbwdRK9lPPNEHP3gQ=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}
