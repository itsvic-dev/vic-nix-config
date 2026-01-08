{ config, ... }:
{
  sops.secrets.iw-wg-peer-sk = { };

  networking.wireguard.useNetworkd = false;
  networking.wireguard.interfaces = {
    "iw-ix-mil01" = {
      listenPort = 52901;
      privateKeyFile = config.sops.secrets.iw-wg-peer-sk.path;
      interfaceNamespace = "intraweb";
      allowedIPsAsRoutes = false;
      postSetup = [
        "ip -n intraweb addr add dev iw-ix-mil01 172.21.32.0/32 peer 172.21.32.1/32"
      ];

      peers = [
        {
          name = "mil01";
          publicKey = "O1JP4HVTRz2IZla3W0ybbEgz72etJFC097dicdBkADo=";
          endpoint = "it-mil01.itsvic.dev:52901";
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}
