{
  networking.wireguard.interfaces = {
    "iw-ix-tastypi" = {
      listenPort = 51900;
      privateKeyFile = "/run/secrets/iw-wg-peer-sk";
      allowedIPsAsRoutes = false;
      ips = [ "172.21.32.1/31" ];

      peers = [
        {
          name = "tastypi";
          publicKey = "p6ol80qOigoAA+Rg+oVMMzLLKyUWDxVxEQbf5P1lsz4=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };

    "iw-ix-de-fra01" = {
      listenPort = 51901;
      privateKeyFile = "/run/secrets/iw-wg-peer-sk";
      allowedIPsAsRoutes = false;
      ips = [ "172.21.32.3/31" ];

      peers = [
        {
          name = "de-fra01";
          publicKey = "LmXg87zKYIeLxiOqG5vzu3Xo50MUoqkfQ2PBII+vkWM=";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [
    51900
    51901
  ];
}
