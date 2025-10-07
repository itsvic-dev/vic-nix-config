{ lib, defaultSecretsFile, config, ... }: {
  sops.secrets.altweb-wg-sk.sopsFile = defaultSecretsFile;

  networking.wireguard.interfaces.wg-aw-pl = {
    ips = [ "192.168.170.1/24" ];
    listenPort = 51822;
    privateKeyFile = config.sops.secrets.altweb-wg-sk.path;

    peers = [{
      publicKey = "1EhjMgu5HobrdK1Vg1W28ze0REARZTcexNpQRoq30gY=";
      allowedIPs = [ "192.168.170.0/24" ];
    }];
  };

  networking.firewall.allowedUDPPorts = [ 51822 ];
}
