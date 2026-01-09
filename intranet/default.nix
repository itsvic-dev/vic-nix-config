{ lib }:
rec {
  caCert = ./certs/ca-cert.pem;
  nameserver = "10.21.0.1";

  wireguardPeers = {
    tastypi = {
      publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
    };
    it-mil01 = {
      publicKey = "S2cSFcrvD4AzK7KuJTWpAzkYNMrdi2ojy8Owl+5VOU4=";
    };
    de-fra01 = {
      publicKey = "DGNfHXE4BWJJcDAxZRxBB5PIiCiSMFw2q7zNBQLEWBw=";
    };
    mbp = {
      publicKey = "fyujyTR/I56g3bO79gLtwn7YgSxxq6O/Ct4NH5nRqlk=";
    };
    iphone = {
      publicKey = "AQqR0qBXROiHro05uJBbckiCWpuBzS8lTDsJIyhMxDI=";
    };
  };
  mainPeer = wireguardPeers.de-fra01 // {
    endpoint = "37.114.50.122:51820";
  };

  ips = {
    de-fra01 = "10.21.0.1";
    tastypi = "10.21.0.2";
    it-mil01 = "10.21.0.3";

    mbp = "10.21.1.1";
    iphone = "10.21.1.2";
  };

  cnames = {
    "grafana" = "tastypi";
    "torrents" = "tastypi";
    "flood" = "tastypi";

    "hydra" = "de-fra01";
    "cache" = "de-fra01";

    "git" = "it-mil01";
  };

  ipsAsDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (name: ip: "${name}.vic. IN A ${ip}") ips
  );

  cnamesAsDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (name: target: "${name}.vic. IN CNAME ${target}.vic.") cnames
  );

  ipsAsRDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: ip:
      let
        octets = lib.splitString "." ip;
        reversed = lib.concatStringsSep "." (lib.sublist 0 2 (lib.reverseList octets));
      in
      "${reversed} IN PTR ${name}.vic."
    ) ips
  );

  # returns a NixOS module wireguard config for this host (not applicable to the main peer)
  wireguardConfig =
    { config, ... }:
    let
      host = config.networking.hostName;
    in
    {
      sops.secrets.vic-net-sk = { };
      networking.wireguard.interfaces.vic-net = {
        ips = [ "${ips.${host}}/32" ];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.vic-net-sk.path;
        peers = [ (mainPeer // { allowedIPs = [ "10.21.0.0/16" ]; }) ];
      };
    };

  getCert = host: domain: ./certs/${host}/${domain}/cert.pem;
  getKey = host: domain: ./certs/${host}/${domain}/key.pem;

  nginxCertFor =
    domain:
    { config, ... }:
    let
      host = config.networking.hostName;
    in
    {
      sops.secrets."${domain}.key" = {
        owner = config.services.nginx.user;
        sopsFile = getKey host domain;
        format = "binary";
      };
      services.nginx.virtualHosts."${domain}" = {
        sslCertificate = getCert host domain;
        sslCertificateKey = config.sops.secrets."${domain}.key".path;
      };
    };
}
