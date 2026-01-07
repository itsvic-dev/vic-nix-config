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
      postSetup = "${ip} -n intraweb addr add dev iw-ix-mil01 172.16.32.0/32 peer 172.16.32.1/32";

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
}
