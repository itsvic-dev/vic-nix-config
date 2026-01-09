{ config, ... }:
{
  sops.secrets.iw-wg-peer-sk = { };

  networking.wireguard.useNetworkd = false;
  networking.wireguard.interfaces = {
    "iw-ix-tastypi" = {
      listenPort = 52901;
      privateKeyFile = config.sops.secrets.iw-wg-peer-sk.path;
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "ip -n intraweb addr add dev iw-ix-tastypi 172.21.32.1/32 peer 172.21.32.0/32"
      ];

      peers = [
        {
          name = "tastypi";
          publicKey = "p6ol80qOigoAA+Rg+oVMMzLLKyUWDxVxEQbf5P1lsz4=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };

    "iw-ix-de-fra01" = {
      listenPort = 52902;
      privateKeyFile = config.sops.secrets.iw-wg-peer-sk.path;
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "ip -n intraweb addr add dev iw-ix-de-fra01 172.21.32.3/32 peer 172.21.32.2/32"
      ];

      peers = [
        {
          name = "de-fra01";
          publicKey = "LmXg87zKYIeLxiOqG5vzu3Xo50MUoqkfQ2PBII+vkWM=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };

  systemd.services."wireguard-iw-ix-tastypi".requires = [ "netns-intraweb.service" ];
  systemd.services."wireguard-iw-ix-fra01".requires = [ "netns-intraweb.service" ];

  networking.firewall.allowedUDPPorts = [
    52901
    52902
  ];
}
