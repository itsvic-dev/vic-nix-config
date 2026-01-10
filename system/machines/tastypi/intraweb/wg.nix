{
  networking.wireguard.interfaces = {
    "iw-ix-mil01" = {
      listenPort = 51900;
      privateKeyFile = "/run/secrets/iw-wg-peer-sk";
      allowedIPsAsRoutes = false;
      ips = [ "172.21.32.0/31" ];

      peers = [
        {
          name = "mil01";
          publicKey = "O1JP4HVTRz2IZla3W0ybbEgz72etJFC097dicdBkADo=";
          endpoint = "it-mil01.itsvic.dev:51900";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}
