{ lib, inputs, ... }: {
  networking = {
    # we use static networking here
    networkmanager.enable = lib.mkForce false;

    firewall.allowedTCPPorts = [ 22 80 443 ];

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "10.0.1.4";
        prefixLength = 24;
      }];
      ens19.ipv4.addresses = [{
        address = "185.184.221.104";
        prefixLength = 27;
      }];
    };

    defaultGateway = {
      address = "10.0.1.254";
      interface = "ens18";
    };

    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    wg-quick.interfaces.vic-net = {
      address = [ "10.21.0.2/32" ];
      dns = [ "10.21.0.1" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.vic-net-sk.path;
      peers = [{
        endpoint = "home.itsvic.dev:51820";
        publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
        allowedIPs = [ "10.21.0.0/16" ];
      }];
    };
  };

  sops.secrets.vic-net-sk.sopsFile = defaultSecretsFile;
  security.pki.certificateFiles = [ "${inputs.self}/ca/ca-cert.pem" ];
}
